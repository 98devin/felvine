
(local ast (require :ast))
(local base (require :base))
(local spirv (require :spirv))
(local types (require :types))
(local requirements (require :requirements))
(local fennel (require :fennel))

(local
  { : Node : node?
    : Type : type?
    : enum?
  } ast)

(local
  { : ExecutionEnvironment
  } requirements)

(local
  { : Op
    : AddressingModel
    : Capability
    : Decoration
    : ExecutionMode
    : ExecutionModel
    : FunctionControl
    : SelectionControl
    : StorageClass
    : LoopControl
    : MemoryModel
    : MemorySemantics
    : MemoryAccess
  } spirv)

(local Env { :mt {} })
(local Runtime { :mt {} })
(local BlockContext { :mt {} :response {} })
(local Function { :mt {} })
(local Block { :mt {} })
(local Dsl {})

(set Env.mt.__index Env)

(fn Env.new []
    (local env
        { :nextID 1
          :typeIDs {}        ; id assigned to each unique type-info
          :types {}          ; types 
          :typesLaidOut {}   ; set of types which have been given layout decorations already
          :nodeIDs {}        ; id assigned to each node
          :constantIDs {}    ; map[type] to map[summary] to constant node for deduplication
          :extInstIDs {}     ; map[str] to id for external instruction sets
          :decorations {}    ; map id to table of decorations
          :memDecorations {} ; map type id to member to table of decorations
          :executionModes {} ; execution modes for given entrypoint name
          :capabilities {}   ; table of capabilities to easily check which are present
          :extensions {}     ; table of extensions ''

          :extinstimports [] ; ExtInstImport instructions
          :entrypoints {}    ; entrypoint name to id
          :debug []          ; debug instructions
          :static []         ; types/constant instructions
          :globals []        ; global variable declarations
          :functions []      ; function objects

          :version { :major 1 :minor 5 }
        })
    (setmetatable env Env.mt))

(fn Env.produceHeader [self]
  (base.SpirvHeader.new
    { :version self.version
      :generatorMagic 0xEAEAEAEA
      :identifierBound self.nextID
    }))

(fn enumerantHasIDOperands [enum v]
  (local desc (. enum.enumerants v.tag))
  (if desc.operands
    (accumulate [any false _ opdesc (ipairs desc.operands) &until any]
      (opdesc.kind:match "Id"))))

(fn Env.produceOps [self ops]
  (local ops (or ops []))
  
  (each [cap _ (pairs self.capabilities)]
    (local cap (. Capability cap))
    (table.insert ops (Op.OpCapability cap)))

  (each [ext _ (pairs self.extensions)]
    (table.insert ops (Op.OpExtension ext)))
  
  (each [_ op (pairs self.extinstimports)]
    (table.insert ops op))

  (local addressingModel
    (if self.capabilities.PhysicalStorageBufferAddresses
      AddressingModel.PhysicalStorageBuffer64
      AddressingModel.Logical))

  (local memoryModel
    (if self.capabilities.VulkanMemoryModel MemoryModel.Vulkan
        self.capabilities.Kernel            MemoryModel.OpenCL
        MemoryModel.GLSL450))
  
  (table.insert ops (Op.OpMemoryModel addressingModel memoryModel))

  (each [_ op (ipairs self.entrypoints)]
    (table.insert ops op))

  (each [entrypoint modes (pairs self.executionModes)]
    (local entrypointID (. self.entrypoints entrypoint))
    (each [_ mode (pairs modes)]
      (if (enumerantHasIDOperands ExecutionMode mode)
        (table.insert ops (Op.OpExecutionModeId entrypointID mode))
        (table.insert ops (Op.OpExecutionMode entrypointID mode)))))

  (each [_ op (ipairs self.debug)]
    (table.insert ops op))

  (each [id decs (pairs self.decorations)]
    (each [_ dec (pairs decs)]
      (if (enumerantHasIDOperands Decoration dec)
        (table.insert ops (Op.OpDecorateId id dec))
        (table.insert ops (Op.OpDecorate id dec)))))

  (each [id memDecs (pairs self.memDecorations)]
    (each [mem decs (pairs memDecs)]
      (each [_ dec (pairs decs)]
        (assert (not (enumerantHasIDOperands Decoration dec))
          (.. "Cannot use this decoration on a member: no such OpMemberDecorateId: " mem (tostring dec)))
        (table.insert ops (Op.OpMemberDecorate id mem dec)))))

  (each [_ op (ipairs self.static)]
    (table.insert ops op))

  (each [_ op (ipairs self.globals)]
    (table.insert ops op))

  (each [_ func (ipairs self.functions)]
    (table.insert ops
      (Op.OpFunction
        (self:typeID func.type.return)
        func.id
        func.control
        (self:typeID func.type)))
        
    (each [_ op (ipairs func.opparams)]
      (table.insert ops op))
      
    (each [i block (ipairs func.blocks)]
      (table.insert ops block.oplabel)
      (when (= i 1)    
        (each [_ op (ipairs func.opvariables)]
          (table.insert ops op)))
      (each [_ op (ipairs block.opphi)]
        (table.insert ops op))
      (each [_ op (ipairs block.body)]
        (table.insert ops op)))
    
    (table.insert ops Op.OpFunctionEnd))

  ops)

(fn Env.capability [self cap]
  (tset self.capabilities cap true))

(fn Env.capability? [self cap]
  (. self.capabilities cap))

(fn Env.extension [self ext]
  (tset self.extensions ext true))

(fn Env.extension? [self ext]
  (. self.extensions ext))

(fn Env.extInstID [self extInst]
  (or (. self.extInstIDs extInst)
    (do (local id (self:freshID))
        (local op (Op.OpExtInstImport id extInst))
        (self:instruction op)
        (tset self.extInstIDs extInst id)
        id)))

(fn getOrSetEmpty [t field]
  (local v (. t field))
  (if v v
    (do (local empty {})
        (tset t field empty)
        empty)))

(fn Env.executionMode [self entrypoint mode]
  ; Fix up mode so that if any nodes are referenced, they are replaced by Id values
  ; This is fine to do in the Env itself, since any such nodes must be (spec) constants anyway.
  (local u32 (Type.int 32 false))

  (when mode.operands
    (local desc (. ExecutionMode.enumerants mode.tag))
    (each [i arg (ipairs mode.operands)]
      (local opdesc (. desc.operands i))
      (when (opdesc.kind:match "Id")
        ; If any non-integer ids become necessary here will need to change
        (tset mode.operands i (self:reifyNode (u32 arg))))))

  (local modesForEntrypoint (getOrSetEmpty self.executionModes entrypoint))
  (tset modesForEntrypoint mode.tag mode))

(fn Env.instruction [self op]
  (if 
    (string.match op.tag "OpType") (table.insert self.static op)
    (string.match op.tag "OpConstant") (table.insert self.static op)
    (string.match op.tag "OpSpecConstant") (table.insert self.static op)
    (string.match op.tag "OpVariable") (table.insert self.globals op)
    (= op.tag :OpExtInstImport) (table.insert self.extinstimports op)
    (= op.tag :OpEntryPoint) (table.insert self.entrypoints op)
    (or (= op.tag :OpName) (= op.tag :OpMemberName)) (table.insert self.debug op)
    (error (.. "Cannot use operation at global scope: " (tostring op)))))

(fn Env.freshID [self]
  (local nextID self.nextID)
  (set self.nextID (+ nextID 1))
  nextID)

(fn Env.typeID? [self type]
  (?. self.typeIDs type.summary))

(fn Env.typeID [self type]
  (self:reifyType type))

(fn Env.reifyType [self type id]
  (or (self:typeID? type)
    (do
      (when id (tset self.typeIDs type.summary id)) ; hack needed due to recursive buffer address types
      (local newTypeID (or (type:reify self id) (self:freshID)))
      (tset self.typeIDs type.summary newTypeID)
      newTypeID)))

(fn Env.constantID [self tid summary]
  (local constantsOfType (or (?. self.constantIDs tid) {}))
  (local existing (?. constantsOfType summary))
  (if existing (values true existing)
    (do
      (local id (self:freshID))
      (tset constantsOfType summary id)
      (tset self.constantIDs tid constantsOfType)
      (values false id))))

(fn Env.nodeID? [self node]
  (?. self.nodeIDs node))

(fn Env.nodeID [self node]
  (self:reifyNode node))

(fn Env.reifyNode [self node]
  (or (self:nodeID? node)
    (do
      (local newNodeID (or (node:reify self) (self:freshID)))
      (tset self.nodeIDs node newNodeID)
      newNodeID)))

(fn Env.decorateID [self id ...]
  (local idDecorations (getOrSetEmpty self.decorations id))
  (each [_ v (ipairs [...])]
    (tset idDecorations v.tag v)))

(fn Env.decorateMemberID [self id member ...]
  (local idDecorations (getOrSetEmpty self.memDecorations id))
  (local memDecorations (getOrSetEmpty idDecorations member))
  (each [_ v (ipairs [...])]
    (tset memDecorations v.tag v)))

(fn Env.decorateNode [self node ...]
  (local id (self:nodeID node))
  (self:decorateID id ...))

(fn Env.decorateType [self type ...]
  (local id (self:typeID type))
  (self:decorateID id ...))

(fn Env.decorated? [self type tag]
  (local id (self:typeID type))
  (?. self.decorations id tag))

(fn Env.decorateMember [self type member ...]
  (local id (self:typeID type))
  (self:decorateMemberID id member ...))

(fn Env.decoratedMember? [self type member tag]
  (local id (self:typeID type))
  (?. self.memDecorations id member tag))
  
; function structure
; .env         env
; .id          number      ; id of function itself
; .type        type-info   ; function type
; .control     FunctionControl
; .params      list[node]  ; function parameter value references
; .opparams    list[Op]
; .opvariables list[Op]    ; Function scope variables
; .interface   table[id]   ; Global scope variables (needed for entrypoints)
; .blocks      list[block]
; .name        ?string

(set Function.mt.__index Function)

(fn Function.new [env type name control]
  (local id (env:freshID))
  (local fun
    { :env env
      :id id
      :type type
      :control (or control (FunctionControl))
      :params []
      :opparams []
      :opvariables []
      :interface {} ; referenced global variables
      :blocks []
      :name name
    })
  (setmetatable fun Function.mt)
  (table.insert env.functions fun)
  fun)


; block structure
; .id          number
; .env         env
; .function    function
; .pred        list[block]
; .succ        list[block]
; .oplabel     Op
; .opphi       list[Op]
; .body        list[Op]


(set Block.mt.__index Block)

(fn Block.new [function]
  (local env function.env)
  (local id (env:freshID))
  (local lbl (Op.OpLabel id))
  (local b 
    { :env env
      :id id
      :function function
      :oplabel (Op.OpLabel id)
      :opphi []
      :body []
      :terminated false
    })
  (table.insert function.blocks b)
  (setmetatable b Block.mt))

(fn Block.sibling [self]
  (Block.new self.function))

(fn Block.extInstID [self extInst]
  (self.env:extInstID extInst))

(fn Block.instruction [self op]
  (when (not self.terminated)
    (case op.tag
      :OpFunctionParameter
        (table.insert self.function.opparams op)
      :OpVariable
        (match (. op.operands 3)
          StorageClass.Function 
            (table.insert self.function.opvariables op)
          _ (do 
              (self.env:instruction op)
              (tset self.function.interface (. op.operands 2) true)))
      :OpPhi (table.insert self.opphi op)
      (where tag
        (or (tag:match "OpConstant") (tag:match "OpSpecConstant") (tag:match "OpType")))
          (self.env:instruction op)
      (where (or :OpName :OpMemberName))
          (self.env:instruction op)
      _ (table.insert self.body op))
    (case op.tag
      (where 
        (or :OpBranch 
            :OpBranchConditional
            :OpReturn
            :OpReturnValue
            :OpSwitch
            :OpKill
            :OpUnreachable
            :OpTerminateInvocation
            :OpIgnoreIntersectionKHR
            :OpTerminateRayKHR
            ))
        (self:terminateBlock))))

(fn Block.terminateBlock [self]
  (set self.terminated true))

(fn Block.freshID [self]
  (self.env:freshID))

(fn Block.constantID [self tid summary]
  (self.env:constantID tid summary))

(fn Block.typeID? [self type]
  (self.env:typeID? type))

(fn Block.typeID [self type]
  (self.env:typeID type))

(fn Block.reifyType [self type id]
  (self.env:reifyType type id))

(fn Block.nodeID? [self node]
  (self.env:nodeID? node))

(fn Block.nodeID [self node]
  (self:reifyNode node))

(fn Block.interfaceID [self id]
  (tset self.function.interface id true))

(fn Block.decorateID [self id ...]
  (self.env:decorateID id ...))
  
(fn Block.decorateMemberID [self id member ...]
  (self.env:decorateMemberID id member ...))

(fn Block.reifyNode [self node]
  (or (self:nodeID? node)
    (do
      (local newNodeID (or (node:reify self) (self:freshID)))
      (tset self.env.nodeIDs node newNodeID)
      newNodeID)))


(set Runtime.mt.__index Runtime)

(fn Runtime.new [executionEnv]
  (setmetatable
    { :env (Env.new)
      :executionEnv (or executionEnv (ExecutionEnvironment.permissive))
      :ctxStack []
    } Runtime.mt))

(fn Runtime.featureSupported? [self feature]
  (or (. self.env.capabilities feature) (. self.env.extensions feature)
    (do (local req (. requirements.index feature))
        (if (not= nil req) (req:validate self.executionEnv)))))

(fn Runtime.currentCtx [self]
  (. self.ctxStack (# self.ctxStack)))

(fn Runtime.pushCtx [self ctx]
  (table.insert self.ctxStack ctx))

(fn Runtime.popCtx [self]
  (table.remove self.ctxStack))

(fn Runtime.freshID [self]
  (self.env:freshID))

(fn Runtime.extInstID [self extInst]
  (self.env:extInstID extInst))

(fn Runtime.instruction [self op]
  (local ctx (or (self:currentCtx) self.env))
  (ctx:instruction op))

(fn Runtime.terminateBlock [self]
  (local ctx (self:currentCtx))
  (ctx:terminateBlock))

(fn Runtime.nodeID? [self node]
  (self.env:nodeID? node))

(fn Runtime.nodeID [self node]
  (local ctx (or (self:currentCtx) self.env))
  (or (ctx:nodeID? node)
    (do
      (local newNodeID (or (node:reify ctx) (ctx:freshID)))
      (tset self.env.nodeIDs node newNodeID)
      newNodeID)))

(fn Runtime.constantID [self tid summary]
  (self.env:constantID tid summary))

(fn Runtime.typeID? [self type]
  (self.env:typeID? type))

(fn Runtime.typeID [self type]
  (self.env:typeID type))

(fn Runtime.reifyType [self type id]
  (self.env:reifyType type id))

(fn Runtime.decorateID [self id ...]
  (self.env:decorateID id ...))
  
(fn Runtime.decorateMemberID [self id member ...]
  (self.env:decorateMemberID id member ...))
  
(fn Runtime.mkLocalCtx [self]
  (local ctx (self:currentCtx))
  (ctx:sibling))


(fn Dsl.createExportedEnv [runtime]
  (local dsl 
    { : types 
      : spirv
      : tostring
      : print
      : pairs
      : ipairs
      : setmetatable
      : getmetatable

      : Node : node?
      
      :sample Node.sample
      :fetch Node.fetch
      :gather Node.gather
      :imageTexel Node.imageTexel
      :queryImageSize Node.queryImageSize
      :queryImageLod Node.queryImageLod
      :queryImageSizeLod Node.queryImageSizeLod
      :queryImageLevels Node.queryImageLevels
      :queryImageSamples Node.queryImageSamples
      :sampledWith Node.sampledWith
      :sampleWith Node.sampleWith

      :subgroup Node.subgroup
      :atomic Node.atomic

      :deref Node.deref

      :lt? Node.lt?
      :gt? Node.gt?
      :eq? Node.eq?
      :neq? Node.neq?
      :lte? Node.lte?
      :gte? Node.gte?
      :any? Node.any?
      :all? Node.all?

      :min Node.min
      :max Node.max
      :nmin Node.nmin
      :nmax Node.nmax

      :d/dx Node.d/dx
      :d/dy Node.d/dy
      :fwidth Node.fwidth

      :dot Node.dot
      :mix Node.mix
      :modf Node.modf
      :frexp Node.frexp
      :ldexp Node.ldexp
      :step Node.step
      :smoothstep Node.smoothstep
      :select Node.select
      :fma Node.fma
      :*+ Node.fma ; TODO: expand this operator to allow chaining or something more useful

      :round Node.round
      :roundEven Node.roundEven
      :trunc Node.trunc
      :floor Node.floor
      :ceil Node.ceil
      :fract Node.fract
      :degreesToRadians Node.degreesToRadians
      :radiansToDegrees Node.radiansToDegrees
      :sign Node.sign
      :abs Node.abs
      :sin Node.sin
      :cos Node.cos
      :tan Node.tan
      :arcsin Node.arcsin
      :arccos Node.arccos
      :arctan Node.arctan
      :sinh Node.sinh
      :cosh Node.cosh
      :tanh Node.tanh
      :arcsinh Node.arcsinh
      :arccosh Node.arccosh
      :arctanh Node.arctanh
      :exp Node.exp
      :exp2 Node.exp2
      :log Node.log
      :ln Node.log
      :log2 Node.log2
      :sqrt Node.sqrt
      :inverseSqrt Node.inverseSqrt
      :normalize Node.normalize
      :norm Node.norm
      :length Node.length
      :distance Node.distance
      :faceForward Node.faceForward
      :refract Node.refract
      :reflect Node.reflect
      :cross Node.cross
      :lsb Node.lsb
      :msb Node.msb
  
      :determinant Node.determinant
      :det Node.determinant
      :invert Node.matrixInverse
      :transpose Node.matrixTranspose
     
      :| Node.|
      :& Node.&

      :packSnorm4x8 Node.packSnorm4x8
      :packUnorm4x8 Node.packUnorm4x8
      :packSnorm2x16 Node.packSnorm2x16
      :packUnorm2x16 Node.packUnorm2x16
      :packHalf2x16 Node.packHalf2x16
      :packDouble2x32 Node.packDouble2x32
      :unpackSnorm2x16 Node.unpackSnorm2x16
      :unpackUnorm2x16 Node.unpackUnorm2x16
      :unpackHalf2x16 Node.unpackHalf2x16
      :unpackSnorm4x8 Node.unpackSnorm4x8
      :unpackUnorm4x8 Node.unpackUnorm4x8
      :unpackDouble2x32 Node.unpackDouble2x32

      : package
      : require })

  (tset dsl :dsl dsl)

  (each [k v (pairs types)]
    (tset dsl k v))

  (fn dsl.supported? [...]
    (accumulate [supported true _ f (ipairs [...]) &until (not supported)]
      (runtime:featureSupported? f)))

  (fn capabilityInternal [capsList]
    (each [_ cap (ipairs capsList)]
      (when (not (runtime.env:capability? cap.tag))
        (assert (dsl.supported? cap.tag) (tostring (. requirements.index cap.tag))
        (runtime.env:capability cap.tag)))))

  (fn extensionInternal [extsList]
    (each [_ ext (ipairs extsList)]
      (when (not (runtime.env:extension? ext))
        (assert (dsl.supported? ext) (tostring (. requirements.index ext)))
        (runtime.env:extension ext))))

  (fn dsl.capability [...]
    (local impliedCaps {})
    (local impliedExts {})

    (each [_ v (ipairs [...])]
      (local cap
        (if (= :string (type v)) (. Capability v) v))
      (tset impliedCaps cap.tag true)
      (base.getCapabilities cap impliedCaps)
      (base.getExtensions cap impliedExts))

    (local impliedCaps (icollect [c _ (pairs impliedCaps)] (. Capability c)))
    (capabilityInternal impliedCaps)

    (local impliedExts (icollect [e _ (pairs impliedExts)] e))
    (extensionInternal impliedExts))

  (fn dsl.extension [...]
    (extensionInternal [...]))

  (fn dsl.executionMode [entrypoint ...]
    (each [_ exec (ipairs [...])]
      (assert (= (enum? exec) :ExecutionMode) "Execution modes must be explicitly constructed.")
      (runtime.env:executionMode entrypoint exec)))

  ; (fn dsl.runtime []
  ;   runtime)

  (fn dsl.layout [type]
    (Type.layout type runtime.env))

  (fn dsl.reify [item]
    (local id 
      (if (node? item) (runtime:nodeID item)
          (type? item) (runtime:typeID item)))
    id)

  (fn dsl.forwardPointer []
    (local id (runtime:freshID))
    (runtime.env:instruction (Op.OpTypeForwardPointer id StorageClass.PhysicalStorageBuffer))
    (Type.pointer nil StorageClass.PhysicalStorageBuffer id))

  (fn dsl.finalizeForwardPointer [ptr]
    (assert (not= nil ptr.elem) "Forward pointer type was not filled in!")
    (runtime.env:reifyType ptr ptr.forward))

  (fn dsl.decorate [item ...]
    (local id (dsl.reify item))
    (runtime.env:decorateID id ...))

  (fn dsl.decorateMember [item member ...]
    (local id (dsl.reify item))
    (runtime.env:decorateMemberID id member ...))

  (fn dsl.name [item name]
    (local id (dsl.reify item))
    (runtime:instruction (Op.OpName id name)))

  (fn dsl.variable [type storage init]
    (local storage (or storage StorageClass.Function))
 
    (local init (if init (type init)))
    (local constInit
      (if (and init (or (= init.kind :constant) (= init.kind :specConstant))) init))

    (local v (Node.variable type storage constInit))
    (when (and init (not constInit))
      (dsl.set* v init))
    v)

  (fn dsl.uniformStorageClass [type]
    (case type.kind
      :image StorageClass.UniformConstant
      :sampler StorageClass.UniformConstant
      :sampledImage StorageClass.UniformConstant
      :accelerationStructure StorageClass.UniformConstant
      :array (dsl.uniformStorageClass type.elem)
      :struct
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.Uniform)
      _ (error (.. "Invalid uniform type: " type.summary))
      ))

  (fn dsl.bufferStorageClass [type]
    (case type.kind
      :array (dsl.bufferStorageClass type.elem)
      :struct 
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.StorageBuffer)
      _ (error (.. "Invalid storage buffer type: " type.summary))
      ))

  (fn dsl.pushConstantStorageClass [type]
    (case type.kind
      :struct
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.PushConstant)
      _ (error (.. "Invalid push constant type: " type.summary))
      ))

  (fn dsl.set* [ptr value memOperands]
    (local ctx (runtime:currentCtx))
    (local pid (ctx:nodeID ptr))
    (local vid (ctx:nodeID (ptr.type.elem value)))

    (local base (Node.aux.basePointer ptr))
    (when (and (= :variable base.kind) (not= base.storage StorageClass.Function))
      (ctx:interfaceID (ctx:nodeID base))) ; already requested so won't change instructions

    (local memOperands
      (if (= ptr.type.storage StorageClass.PhysicalStorageBuffer)
          (MemoryAccess (MemoryAccess.Aligned ptr.type.elem.alignment) memOperands)
          memOperands))

    (ctx:instruction (Op.OpStore pid vid memOperands)))

  (fn dsl.write [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.imageWrite ctx ...))

  (fn dsl.atomic.store [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.atomicStore [ctx ...]))

  (fn dsl.barrier []
    (dsl.controlBarrier :Workgroup :Workgroup
      (MemorySemantics
        :SequentiallyConsistent
        :WorkgroupMemory)))

  (fn dsl.controlBarrier [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.controlBarrier ctx ...))

  (fn dsl.memoryBarrier [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.memoryBarrier ctx ...))  

  (fn dsl.defineFunction [return name params body]
    (local funty (Type.function return params))
    (local fun (Function.new runtime.env funty name))
    (runtime.env:instruction (Op.OpName fun.id name))

    (local ctx (Block.new fun))
    (ctx:reifyType funty) ; make sure this exists

    (each [_ paramType (ipairs params)]
      (local node (Node.param paramType))
      (ctx:reifyNode node)
      (table.insert fun.params node))

    (runtime:pushCtx ctx)
    (local returnNode (body (table.unpack fun.params)))
    (local ctx (runtime:popCtx))

    (if (not= nil returnNode)
      (if (not= return.kind :void)
        (ctx:instruction (Op.OpReturnValue (ctx:nodeID (return returnNode))))
        (do (ctx:nodeID returnNode) (ctx:instruction Op.OpReturn)))
      (if (not= return.kind :void)
        (error (.. "Function " name " has return type of " return.summary " but actual value returned was nil!"))
        (ctx:instruction Op.OpReturn)))
    
    (Node.function fun))

  (fn dsl.entrypoint [name executionmodel body]
    (assert (= nil (. runtime.env.entrypoints name)) "Cannot have two entrypoints with the same name")

    (local funNode (dsl.defineFunction (Type.void) name [] body))
    (local fun funNode.function)
    (local executionmodel
      (if (enum? executionmodel) executionmodel
        (. ExecutionModel executionmodel)))
    (runtime.env:instruction
      (Op.OpEntryPoint executionmodel fun.id name
        (icollect [k _ (pairs fun.interface)] k)))
    (tset runtime.env.entrypoints name fun.id)
    funNode)

  (set dsl.geometry {})

  (fn dsl.geometry.emitVertex []
    (local ctx (runtime:currentCtx))
    (Node.aux.emitVertex ctx))
    
  (fn dsl.geometry.emitStreamVertex [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.emitVertex ctx ...))

  (fn dsl.geometry.endPrimitive []
    (local ctx (runtime:currentCtx))
    (Node.aux.endPrimitive ctx))
    
  (fn dsl.geometry.endStreamPrimitive [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.endStreamPrimitive ctx ...))

  (set dsl.mesh {})

  (fn dsl.mesh.setMeshOutputs [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.setMeshOutputs ctx ...))

  (fn dsl.mesh.emitMeshTasks [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.emitMeshTasks ctx ...))

  (set dsl.rt {})

  (fn dsl.rt.initializeRayQuery [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.initializeRayQuery ctx ...))

  (fn dsl.rt.terminateRayQuery [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.terminateRayQuery ctx ...))
    
  (fn dsl.rt.confirmRayQueryIntersection [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.confirmRayQueryIntersection ctx ...))
    
  (fn dsl.rt.generateRayQueryIntersection [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.generateRayQueryIntersection ctx ...))

  (fn dsl.rt.proceedRayQuery [...]
    (local ctx (runtime:currentCtx))
    (Node.aux.proceedRayQuery ctx ...))

  (set dsl.rt.getRayQueryWorldRayOrigin Node.aux.getRayQueryWorldRayOrigin)
  (set dsl.rt.getRayQueryWorldRayDirection Node.aux.getRayQueryWorldRayDirection)
  (set dsl.rt.getRayQueryIntersectionType Node.aux.getRayQueryIntersectionType)
  (set dsl.rt.getRayQueryIntersectionT Node.aux.getRayQueryIntersectionT)
  (set dsl.rt.getRayQueryIntersectionInstanceCustomIndex Node.aux.getRayQueryIntersectionInstanceCustomIndex)
  (set dsl.rt.getRayQueryIntersectionInstanceShaderBindingTableRecordOffset Node.aux.getRayQueryIntersectionInstanceShaderBindingTableRecordOffset)
  (set dsl.rt.getRayQueryIntersectionGeometryIndex Node.aux.getRayQueryIntersectionGeometryIndex)
  (set dsl.rt.getRayQueryIntersectionPrimitiveIndex Node.aux.getRayQueryIntersectionPrimitiveIndex)
  (set dsl.rt.getRayQueryIntersectionBarycentrics Node.aux.getRayQueryIntersectionBarycentrics)
  (set dsl.rt.getRayQueryIntersectionFrontFace Node.aux.getRayQueryIntersectionFrontFace)
  (set dsl.rt.getRayQueryIntersectionCandidateAABBOpaque Node.aux.getRayQueryIntersectionCandidateAABBOpaque)
  (set dsl.rt.getRayQueryIntersectionObjectRayDirection Node.aux.getRayQueryIntersectionObjectRayDirection)
  (set dsl.rt.getRayQueryIntersectionObjectRayOrigin Node.aux.getRayQueryIntersectionObjectRayOrigin)
  (set dsl.rt.getRayQueryIntersectionObjectToWorld Node.aux.getRayQueryIntersectionObjectToWorld)
  (set dsl.rt.getRayQueryIntersectionWorldToObject Node.aux.getRayQueryIntersectionWorldToObject)

  (fn dsl.rt.ignoreIntersection []
    (Node.aux.ignoreIntersection (runtime:currentCtx)))

  (fn dsl.rt.terminateRay []
    (Node.aux.terminateRay (runtime:currentCtx)))

  (fn dsl.rt.executeCallable [...]
    (Node.aux.executeCallable (runtime:currentCtx) ...))

  (fn dsl.rt.reportIntersection [...]
    (Node.aux.reportIntersection (runtime:currentCtx) ...))

  (fn dsl.rt.traceRay [...]
    (Node.aux.traceRay (runtime:currentCtx) ...))

  ;
  ; control flow
  ;

  (fn dsl.forLoop [cond step body loopControl]
    (local loopControl (or loopControl (LoopControl)))

    (local headerBlock (runtime:mkLocalCtx))
    (local condBlock (runtime:mkLocalCtx))
    
    (local ctx (runtime:popCtx))
    (ctx:instruction (Op.OpBranch headerBlock.id))

    (runtime:pushCtx condBlock)
    (local cond (cond))
    (local condCtx (runtime:popCtx))
    (local condID (condCtx:nodeID cond))

    (local loopBlock (ctx:sibling))
    (runtime:pushCtx loopBlock)
    (body)
    (local loopCtx (runtime:popCtx))

    (local contBlock (ctx:sibling))
    (local mergeBlock (ctx:sibling))

    (headerBlock:instruction (Op.OpLoopMerge mergeBlock.id contBlock.id loopControl))
    (headerBlock:instruction (Op.OpBranch condBlock.id))
    (condCtx:instruction (Op.OpBranchConditional condID loopBlock.id mergeBlock.id))
    (loopCtx:instruction (Op.OpBranch contBlock.id))

    (runtime:pushCtx contBlock)
    (step)
    (local contCtx (runtime:popCtx))
    (contCtx:instruction (Op.OpBranch headerBlock.id))

    (runtime:pushCtx mergeBlock))

  (fn dsl.whileLoop [cond body loopControl]
    (local loopControl (or loopControl (LoopControl)))

    (local ctx (runtime:popCtx))
    (local headerBlock (ctx:sibling))
    (ctx:instruction (Op.OpBranch headerBlock.id))

    (local condBlock (ctx:sibling))
    (runtime:pushCtx condBlock)
    (local cond (cond))
    (local condCtx (runtime:popCtx))
    (local condID (condCtx:nodeID cond))

    (local loopBlock (ctx:sibling))
    (local contBlock (ctx:sibling))
    (local mergeBlock (ctx:sibling))

    (headerBlock:instruction (Op.OpLoopMerge mergeBlock.id contBlock.id loopControl))
    (headerBlock:instruction (Op.OpBranch condBlock.id))

    (condCtx:instruction (Op.OpBranchConditional condID loopBlock.id mergeBlock.id))

    (runtime:pushCtx loopBlock)
    (body)
    (local loopCtx (runtime:popCtx))
    (loopCtx:instruction (Op.OpBranch contBlock.id))

    (contBlock:instruction (Op.OpBranch headerBlock.id))

    (runtime:pushCtx mergeBlock))

  (fn makePhiNodeIfPossible [mergeBlock blocksAndResults]
    (var resultType nil)
    (var phiPossible true)

    (each [_ [block result] (ipairs blocksAndResults)]
      (when (and phiPossible (node? result))
        (if (= nil resultType) (set resultType result.type)
            (and resultType.primitive result.type.primitive)
              (set resultType (Type.aux.primCommonSupertype resultType result.type))
            (set phiPossible (= resultType result.type)))))
    
    (if (not phiPossible) nil (do
      (local phiArguments [])
      (each [_ [block result] (ipairs blocksAndResults) :until (not phiPossible)]
        (local (valid result) (pcall resultType result))
        (when (not valid) (set phiPossible false))
        (when valid 
          (local resultID (block:nodeID result))
          (table.insert phiArguments [resultID block.id])))

      (if phiPossible
        (let [phi (Node.phi resultType (table.unpack phiArguments))]
          (mergeBlock:nodeID phi)
          phi)))))

  (fn dsl.switchCase [disc targets]

    (local disc (Node.aux.autoderef disc))
    (assert (and (node? disc) (= disc.type.kind :int))
            (.. "Switch block discriminant must be a node of integer type, got: " (tostring disc)))

    (local ctx (runtime:popCtx))
    (local discID (ctx:nodeID disc))

    (local seenCases {})
    (local allCasePairs [])
    (local allFinalBodyBlocks [])

    (var defaultCase nil)

    (each [_ target (ipairs targets)]
      (local { : cases : body } target)

      (local bodyBlock (ctx:sibling))
      (runtime:pushCtx bodyBlock)
      (local bodyResult (body))
      (local bodyCtx (runtime:popCtx))
      (table.insert allFinalBodyBlocks [bodyCtx bodyResult])
      
      (each [_ caseExp (ipairs cases)]
        (if (= caseExp :default)
          (do (set defaultCase bodyBlock.id)
              (set seenCases.default true))
          (do (local caseExp (disc.type caseExp))
              (assert (= caseExp.kind :constant)
                      (.. "Switch block case expression must be a constant, got: " (tostring caseExp)))
              (assert (not (. seenCases caseExp.constant))
                      (.. "Same value cannot be used in multiple switch cases: " (tostring caseExp.constant)))
              (tset seenCases caseExp.constant true)
              (table.insert allCasePairs [caseExp.constant bodyBlock.id])))))

    (local mergeBlock (ctx:sibling))

    (local result (and defaultCase (makePhiNodeIfPossible mergeBlock allFinalBodyBlocks)))
    (when (= nil defaultCase)
      (set defaultCase mergeBlock.id))
    
    (ctx:instruction (Op.OpSelectionMerge mergeBlock.id (SelectionControl)))
    (each [_ [bodyCtx] (ipairs allFinalBodyBlocks)]
      (bodyCtx:instruction (Op.OpBranch mergeBlock.id)))

    (ctx:instruction (Op.OpSwitch discID defaultCase allCasePairs))

    (runtime:pushCtx mergeBlock)
    result)

  (fn dsl.ifThenElse [cond then else]
    (local thenBlock (runtime:mkLocalCtx))
    (local elseBlock (runtime:mkLocalCtx))
    
    (local ctx (runtime:popCtx))
    (local condID (ctx:nodeID cond))

    (runtime:pushCtx thenBlock)
    (local thenResult (then))
    (local thenCtx (runtime:popCtx))
    (local thenResult (if (not thenCtx.terminated) thenResult))

    (runtime:pushCtx elseBlock)
    (local elseResult (else))
    (local elseCtx (runtime:popCtx))
    (local elseResult (if (not elseCtx.terminated) elseResult))

    (assert (or (= nil thenResult elseResult) (node? thenResult) (node? elseResult))
            (.. "At least one branch of if* must return a node value for type to be determined, got: "
                (tostring thenResult) ", " (tostring elseResult)))

    (when (and (node? thenResult) (node? elseResult))
      (assert (= thenResult.type.kind elseResult.type.kind)
              (.. "if* branches do not return nodes of the same type: " thenResult.type.summary ", " elseResult.type.summary)))

    (local mergeBlock (ctx:sibling))
    (when (not (or thenCtx.terminated elseCtx.terminated))
      (ctx:instruction (Op.OpSelectionMerge mergeBlock.id (SelectionControl))))

    (local result (makePhiNodeIfPossible mergeBlock
      [ [thenCtx thenResult] [elseCtx elseResult ] ]))

    (ctx:instruction (Op.OpBranchConditional condID thenBlock.id elseBlock.id []))
    (thenCtx:instruction (Op.OpBranch mergeBlock.id))
    (elseCtx:instruction (Op.OpBranch mergeBlock.id))

    (runtime:pushCtx mergeBlock)
    result)

  dsl)


{ : Runtime
  : Env
  : Block
  : BlockContext
  : Function
  : Dsl
}