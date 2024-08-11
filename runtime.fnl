
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
        { :next-id 1
          :type-ids {}        ; id assigned to each unique type-info
          :types {}           ; types 
          :types-laid-out {}  ; set of types which have been given layout decorations already
          :node-ids {}        ; id assigned to each node
          :constant-ids {}    ; map[type] to map[summary] to constant node for deduplication
          :ext-inst-ids {}     ; map[str] to id for external instruction sets
          :decorations {}     ; map id to table of decorations
          :mem-decorations {} ; map type id to member to table of decorations
          :execution-modes {} ; execution modes for given entrypoint name
          :capabilities {}    ; table of capabilities to easily check which are present
          :extensions {}      ; table of extensions ''

          :extinstimports []  ; ExtInstImport instructions
          :entrypoints {}     ; entrypoint name to id
          :debug []           ; debug instructions
          :static []          ; types/constant instructions
          :globals []         ; global variable declarations
          :functions []       ; function objects

          :version { :major 1 :minor 5 }
        })
    (setmetatable env Env.mt))

(fn Env.produce-header [self]
  (base.SpirvHeader.new
    { :version self.version
      :generatorMagic 0xEAEAEAEA
      :identifierBound self.next-id
    }))

(fn enumerant-has-id-operands [enum v]
  (local desc (. enum.enumerants v.tag))
  (if desc.operands
    (accumulate [any false _ opdesc (ipairs desc.operands) &until any]
      (opdesc.kind:match "Id"))))

(fn Env.produce-ops [self ops]
  (local ops (or ops []))
  
  (each [cap _ (pairs self.capabilities)]
    (local cap (. Capability cap))
    (table.insert ops (Op.OpCapability cap)))

  (each [ext _ (pairs self.extensions)]
    (table.insert ops (Op.OpExtension ext)))
  
  (each [_ op (pairs self.extinstimports)]
    (table.insert ops op))

  (local addressing-model
    (if self.capabilities.PhysicalStorageBufferAddresses
      AddressingModel.PhysicalStorageBuffer64
      AddressingModel.Logical))

  (local memory-model
    (if self.capabilities.VulkanMemoryModel MemoryModel.Vulkan
        self.capabilities.Kernel            MemoryModel.OpenCL
        MemoryModel.GLSL450))
  
  (table.insert ops (Op.OpMemoryModel addressing-model memory-model))

  (each [_ op (ipairs self.entrypoints)]
    (table.insert ops op))

  (each [entrypoint modes (pairs self.execution-modes)]
    (local entrypoint-id (. self.entrypoints entrypoint))
    (each [_ mode (pairs modes)]
      (if (enumerant-has-id-operands ExecutionMode mode)
        (table.insert ops (Op.OpExecutionModeId entrypoint-id mode))
        (table.insert ops (Op.OpExecutionMode entrypoint-id mode)))))

  (each [_ op (ipairs self.debug)]
    (table.insert ops op))

  (each [id decs (pairs self.decorations)]
    (each [_ dec (pairs decs)]
      (if (enumerant-has-id-operands Decoration dec)
        (table.insert ops (Op.OpDecorateId id dec))
        (table.insert ops (Op.OpDecorate id dec)))))

  (each [id mem-decs (pairs self.mem-decorations)]
    (each [mem decs (pairs mem-decs)]
      (each [_ dec (pairs decs)]
        (assert (not (enumerant-has-id-operands Decoration dec))
          (.. "Cannot use this decoration on a member: no such OpMemberDecorateId: " mem (tostring dec)))
        (table.insert ops (Op.OpMemberDecorate id mem dec)))))

  (each [_ op (ipairs self.static)]
    (table.insert ops op))

  (each [_ op (ipairs self.globals)]
    (table.insert ops op))

  (each [_ func (ipairs self.functions)]
    (table.insert ops
      (Op.OpFunction
        (self:type-id func.type.return)
        func.id
        func.control
        (self:type-id func.type)))
        
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

(fn Env.ext-inst-id [self ext-inst]
  (or (. self.ext-inst-ids ext-inst)
    (do (local id (self:fresh-id))
        (local op (Op.OpExtInstImport id ext-inst))
        (self:instruction op)
        (tset self.ext-inst-ids ext-inst id)
        id)))

(fn get-or-set-empty [t field]
  (local v (. t field))
  (if v v
    (do (local empty {})
        (tset t field empty)
        empty)))

(fn Env.execution-mode [self entrypoint mode]
  ; Fix up mode so that if any nodes are referenced, they are replaced by Id values
  ; This is fine to do in the Env itself, since any such nodes must be (spec) constants anyway.
  (local u32 (Type.int 32 false))

  (when mode.operands
    (local desc (. ExecutionMode.enumerants mode.tag))
    (each [i arg (ipairs mode.operands)]
      (local opdesc (. desc.operands i))
      (when (opdesc.kind:match "Id")
        ; If any non-integer ids become necessary here will need to change
        (tset mode.operands i (self:reify-node (u32 arg))))))

  (local modes-for-entrypoint (get-or-set-empty self.execution-modes entrypoint))
  (tset modes-for-entrypoint mode.tag mode))

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

(fn Env.fresh-id [self]
  (local next-id self.next-id)
  (set self.next-id (+ next-id 1))
  next-id)

(fn Env.type-id? [self type]
  (?. self.type-ids type.summary))

(fn Env.type-id [self type]
  (self:reify-type type))

(fn Env.reify-type [self type id]
  (or (self:type-id? type)
    (do
      (when id (tset self.type-ids type.summary id)) ; hack needed due to recursive buffer address types
      (local new-type-id (or (type:reify self id) (self:fresh-id)))
      (tset self.type-ids type.summary new-type-id)
      new-type-id)))

(fn Env.constant-id [self tid summary]
  (local constants-of-type (or (?. self.constant-ids tid) {}))
  (local existing (?. constants-of-type summary))
  (if existing (values true existing)
    (do
      (local id (self:fresh-id))
      (tset constants-of-type summary id)
      (tset self.constant-ids tid constants-of-type)
      (values false id))))

(fn Env.node-id? [self node]
  (?. self.node-ids node))

(fn Env.node-id [self node]
  (self:reify-node node))

(fn Env.reify-node [self node]
  (or (self:node-id? node)
    (do
      (local new-node-id (or (node:reify self) (self:fresh-id)))
      (tset self.node-ids node new-node-id)
      new-node-id)))

(fn Env.decorate-id [self id ...]
  (local id-decorations (get-or-set-empty self.decorations id))
  (each [_ v (ipairs [...])]
    (tset id-decorations v.tag v)))

(fn Env.decorate-member-id [self id member ...]
  (local id-decorations (get-or-set-empty self.mem-decorations id))
  (local mem-decorations (get-or-set-empty id-decorations member))
  (each [_ v (ipairs [...])]
    (tset mem-decorations v.tag v)))

(fn Env.decorate-node [self node ...]
  (local id (self:node-id node))
  (self:decorate-id id ...))

(fn Env.decorate-type [self type ...]
  (local id (self:type-id type))
  (self:decorate-id id ...))

(fn Env.decorated? [self type tag]
  (local id (self:type-id type))
  (?. self.decorations id tag))

(fn Env.decorate-member [self type member ...]
  (local id (self:type-id type))
  (self:decorate-member-id id member ...))

(fn Env.decorated-member? [self type member tag]
  (local id (self:type-id type))
  (?. self.mem-decorations id member tag))
  
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
  (local id (env:fresh-id))
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
  (local id (env:fresh-id))
  (local lbl (Op.OpLabel id))
  (local b 
    { :env env
      :id id
      :function function
      :oplabel (Op.OpLabel id)
      :opphi []
      :body [] 
    })
  (table.insert function.blocks b)
  (setmetatable b Block.mt))

(fn Block.sibling [self]
  (Block.new self.function))

(fn Block.ext-inst-id [self ext-inst]
  (self.env:ext-inst-id ext-inst))

(fn Block.instruction [self op]
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
    (where tag
      (or (tag:match "OpConstant") (tag:match "OpSpecConstant") (tag:match "OpType")))
        (self.env:instruction op)
    (where (or :OpName :OpMemberName))
        (self.env:instruction op)
    :OpPhi (table.insert self.opphi op)
    _ (table.insert self.body op)))

(fn Block.fresh-id [self]
  (self.env:fresh-id))

(fn Block.constant-id [self tid summary]
  (self.env:constant-id tid summary))

(fn Block.type-id? [self type]
  (self.env:type-id? type))

(fn Block.type-id [self type]
  (self.env:type-id type))

(fn Block.reify-type [self type id]
  (self.env:reify-type type id))

; (fn Block.reify-type [self type id]
;   (or (self.env:type-id? type)
;     (do
;       (when id (tset self.env.type-ids type.summary id))
;       (local new-type-id (or (type:reify self id) (self:fresh-id)))
;       (tset self.env.type-ids type.summary new-type-id)
;       new-type-id)))

(fn Block.node-id? [self node]
  (self.env:node-id? node))

(fn Block.node-id [self node]
  (self:reify-node node))

(fn Block.interface-id [self id]
  (tset self.function.interface id true))

(fn Block.decorate-id [self id ...]
  (self.env:decorate-id id ...))
  
(fn Block.decorate-member-id [self id member ...]
  (self.env:decorate-member-id id member ...))

(fn Block.reify-node [self node]
  (or (self:node-id? node)
    (do
      (local new-node-id (or (node:reify self) (self:fresh-id)))
      (tset self.env.node-ids node new-node-id)
      new-node-id)))


(set Runtime.mt.__index Runtime)

(fn Runtime.new [execution-env]
  (setmetatable
    { :env (Env.new)
      :execution-env (or execution-env (ExecutionEnvironment.permissive))
      :ctx-stack []
    } Runtime.mt))

(fn Runtime.feature-supported? [self feature]
  (or (. self.env.capabilities feature) (. self.env.extensions feature)
    (do (local req (. requirements.index feature))
        (if (not= nil req) (req:validate self.execution-env)))))

(fn Runtime.current-ctx [self]
  (. self.ctx-stack (# self.ctx-stack)))

(fn Runtime.push-ctx [self ctx]
  (table.insert self.ctx-stack ctx))

(fn Runtime.pop-ctx [self]
  (table.remove self.ctx-stack))

(fn Runtime.fresh-id [self]
  (self.env:fresh-id))

(fn Runtime.ext-inst-id [self ext-inst]
  (self.env:ext-inst-id ext-inst))

(fn Runtime.instruction [self op]
  (local ctx (or (self:current-ctx) self.env))
  (ctx:instruction op))

(fn Runtime.node-id? [self node]
  (self.env:node-id? node))

(fn Runtime.node-id [self node]
  (local ctx (or (self:current-ctx) self.env))
  (or (ctx:node-id? node)
    (do
      (local new-node-id (or (node:reify ctx) (ctx:fresh-id)))
      (tset self.env.node-ids node new-node-id)
      new-node-id)))

(fn Runtime.constant-id [self tid summary]
  (self.env:constant-id tid summary))

(fn Runtime.type-id? [self type]
  (self.env:type-id? type))

(fn Runtime.type-id [self type]
  (self.env:type-id type))

(fn Runtime.reify-type [self type id]
  (self.env:reify-type type id))

; (fn Runtime.reify-type [self type id]
;   (local ctx (or (self:current-ctx) self.env))
;   (or (ctx:type-id? type)
;     (do
;       (when id (tset self.env.type-ids type.summary id))
;       (local new-type-id (or (type:reify ctx id) (ctx:fresh-id)))
;       (tset self.env.type-ids type.summary new-type-id)
;       new-type-id)))

(fn Block.decorate-id [self id ...]
  (self.env:decorate-id id ...))
  
(fn Block.decorate-member-id [self id member ...]
  (self.env:decorate-member-id id member ...))
  
(fn Runtime.mk-local-ctx [self]
  (local ctx (self:current-ctx))
  (ctx:sibling))


(fn Dsl.create-exported-env [runtime]
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
      :query-image-size Node.query-image-size
      :query-image-lod Node.query-image-lod
      :query-image-size-lod Node.query-image-size-lod
      :query-image-levels Node.query-image-levels
      :query-image-samples Node.query-image-samples
      :sampled-with Node.sampled-with
      :sample-with Node.sample-with

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
      :round-even Node.round-even
      :trunc Node.trunc
      :floor Node.floor
      :ceil Node.ceil
      :fract Node.fract
      :degrees-to-radians Node.degrees-to-radians
      :radians-to-degrees Node.radians-to-degrees
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
      :inverse-sqrt Node.inverse-sqrt
      :normalize Node.normalize
      :norm Node.norm
      :length Node.length
      :distance Node.distance
      :face-forward Node.face-forward
      :refract Node.refract
      :reflect Node.reflect
      :cross Node.cross
      :lsb Node.lsb
      :msb Node.msb
  
      :determinant Node.determinant
      :det Node.determinant
      :invert Node.matrix-inverse
      :transpose Node.matrix-transpose
     
      :| Node.|
      :& Node.&

      :pack-snorm4x8 Node.pack-snorm4x8
      :pack-unorm4x8 Node.pack-unorm4x8
      :pack-snorm2x16 Node.pack-snorm2x16
      :pack-unorm2x16 Node.pack-unorm2x16
      :pack-half2x16 Node.pack-half2x16
      :pack-double2x32 Node.pack-double2x32
      :unpack-snorm2x16 Node.unpack-snorm2x16
      :unpack-unorm2x16 Node.unpack-unorm2x16
      :unpack-half2x16 Node.unpack-half2x16
      :unpack-snorm4x8 Node.unpack-snorm4x8
      :unpack-unorm4x8 Node.unpack-unorm4x8
      :unpack-double2x32 Node.unpack-double2x32

      : package
      : require })

  (tset dsl :dsl dsl)

  (each [k v (pairs types)]
    (tset dsl k v))

  (fn dsl.supported? [...]
    (accumulate [supported true _ f (ipairs [...]) &until (not supported)]
      (runtime:feature-supported? f)))

  (fn capability-internal [caps-list]
    (each [_ cap (ipairs caps-list)]
      (when (not (runtime.env:capability? cap.tag))
        (assert (dsl.supported? cap.tag) (tostring (. requirements.index cap.tag))
        (runtime.env:capability cap.tag)))))

  (fn extension-internal [exts-list]
    (each [_ ext (ipairs exts-list)]
      (when (not (runtime.env:extension? ext))
        (assert (dsl.supported? ext) (tostring (. requirements.index ext)))
        (runtime.env:extension ext))))

  (fn dsl.capability [...]
    (local implied-caps {})
    (local implied-exts {})

    (each [_ v (ipairs [...])]
      (local cap
        (if (= :string (type v)) (. Capability v) v))
      (tset implied-caps cap.tag true)
      (base.get-capabilities cap implied-caps)
      (base.get-extensions cap implied-exts))

    (local implied-caps (icollect [c _ (pairs implied-caps)] (. Capability c)))
    (capability-internal implied-caps)

    (local implied-exts (icollect [e _ (pairs implied-exts)] e))
    (extension-internal implied-exts))

  (fn dsl.extension [...]
    (extension-internal [...]))

  (fn dsl.execution-mode [entrypoint ...]
    (each [_ exec (ipairs [...])]
      (assert (= (enum? exec) :ExecutionMode) "Execution modes must be explicitly constructed.")
      (runtime.env:execution-mode entrypoint exec)))

  ; (fn dsl.runtime []
  ;   runtime)

  (fn dsl.layout [type]
    (Type.layout type runtime.env))

  (fn dsl.reify [item]
    (local id 
      (if (node? item) (runtime:node-id item)
          (type? item) (runtime:type-id item)))
    id)

  (fn dsl.forward-pointer []
    (local id (runtime:fresh-id))
    (runtime.env:instruction (Op.OpTypeForwardPointer id StorageClass.PhysicalStorageBuffer64))
    (Type.pointer nil StorageClass.PhysicalStorageBuffer64 id))

  (fn dsl.finalize-forward-pointer [ptr]
    (assert (not= nil ptr.elem) "Forward pointer type was not filled in!")
    (runtime.env:reify-type ptr ptr.forward))

  (fn dsl.decorate [item ...]
    (local id (dsl.reify item))
    (runtime.env:decorate-id id ...))

  (fn dsl.decorate-member [item member ...]
    (local id (dsl.reify item))
    (runtime.env:decorate-member-id id member ...))

  (fn dsl.name [item name]
    (local id (dsl.reify item))
    (runtime:instruction (Op.OpName id name)))

  ; TODO: Know what type each builtin is so we can automatically fill that in.
  ; (fn dsl.builtin [name])

  (fn dsl.variable [type storage init]
    (local storage (or storage StorageClass.Function))

    (local init (if init (type init)))
    (local const-init
      (if (and init (or (= init.kind :constant) (= init.kind :spec-constant))) init))

    (local v (Node.variable type storage const-init))
    (when (and init (not const-init))
      (dsl.set* v init))
    v)

  (fn dsl.uniform-storage-class [type]
    (case type.kind
      :image StorageClass.UniformConstant
      :sampler StorageClass.UniformConstant
      :sampled-image StorageClass.UniformConstant
      :array (dsl.uniform-storage-class type.elem)
      :struct
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.Uniform)
      _ (error (.. "Invalid uniform type: " type.summary))
      ))

  (fn dsl.buffer-storage-class [type]
    (case type.kind
      :array (dsl.buffer-storage-class type.elem)
      :struct 
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.StorageBuffer)
      _ (error (.. "Invalid storage buffer type: " type.summary))
      ))

  (fn dsl.push-constant-storage-class [type]
    (case type.kind
      :struct
        (do (dsl.layout type)
            (dsl.decorate type Decoration.Block)
            StorageClass.PushConstant)
      _ (error (.. "Invalid push constant type: " type.summary))
      ))

  (fn dsl.set* [ptr value mem-operands]
    (local ctx (runtime:current-ctx))
    (local pid (ctx:node-id ptr))
    (local vid (ctx:node-id (ptr.type.elem value)))

    (local base (Node.aux.base-pointer ptr))
    (when (and (= :variable base.kind) (not= base.storage StorageClass.Function))
      (ctx:interface-id (ctx:node-id base))) ; already requested so won't change instructions

    (local mem-operands
      (if (= ptr.type.storage StorageClass.PhysicalStorageBuffer64)
          (MemoryAccess (MemoryAccess.Aligned ptr.type.elem.alignment) mem-operands)
          mem-operands))

    (ctx:instruction (Op.OpStore pid vid mem-operands)))

  (fn dsl.write [...]
    (local ctx (runtime:current-ctx))
    (Node.aux.image-write ctx ...))

  (fn dsl.atomic.store [...]
    (local ctx (runtime:current-ctx))
    (Node.aux.atomic-store [ctx ...]))

  (fn dsl.barrier []
    (dsl.control-barrier :Workgroup :Workgroup
      (MemorySemantics
        MemorySemantics.SequentiallyConsistent
        MemorySemantics.WorkgroupMemory)))

  (fn dsl.control-barrier [...]
    (local ctx (runtime:current-ctx))
    (Node.aux.control-barrier ctx ...))

  (fn dsl.memory-barrier [...]
    (local ctx (runtime:current-ctx))
    (Node.aux.memory-barrier ctx ...))  

  (fn dsl.define-function [return name params body]
    (local funty (Type.function return params))
    (local fun (Function.new runtime.env funty name))

    (local ctx (Block.new fun))
    (ctx:reify-type funty) ; make sure this exists

    (each [_ param-type (ipairs params)]
      (local node (Node.param param-type))
      (ctx:reify-node node)
      (table.insert fun.params node))

    (runtime:push-ctx ctx)
    (local return-node (body (table.unpack fun.params)))
    (local ctx (runtime:pop-ctx))

    (if (and (not= return-node nil) (not= return-node.type.kind :void))
      (ctx:instruction (Op.OpReturnValue (ctx:node-id (return return-node))))
      (ctx:instruction Op.OpReturn))
    
    (ctx:instruction (Op.OpName fun.id name))
    (Node.function fun))

  (fn dsl.entrypoint [name executionmodel body]
    (assert (= nil (. runtime.env.entrypoints name)) "Cannot have two entrypoints with the same name")

    (local fun-node (dsl.define-function (Type.void) name [] body))
    (local fun fun-node.function)
    (local executionmodel
      (if (enum? executionmodel) executionmodel
        (. ExecutionModel executionmodel)))
    (runtime.env:instruction
      (Op.OpEntryPoint executionmodel fun.id name
        (icollect [k _ (pairs fun.interface)] k)))
    (tset runtime.env.entrypoints name fun.id)
    fun-node)

  ; (fn dsl.loop [initial cond body loop-control]

  ;   (local loop-control (or loop-control (LoopControl)))

  ;   (local header-block (runtime:mk-local-ctx))
  ;   (local loop-block (runtime:mk-local-ctx))
  ;   (local merge-block (runtime:mk-local-ctx))
    
  ;   (local ctx (runtime:pop-ctx))
  ;   (local initial-id (ctx:node-id initial))
  ;   (ctx:instruction (Op.OpBranch header-block.id))

  ;   (runtime:push-ctx header-block)
  ;   (local cond-id (ctx:node-id cond))
  ;   (ctx:instruction (Op.OpLoopMerge merge-block.id header-block.id loop-control))
  ;   (ctx:instruction (Op.OpBranchConditional ))

  ;   )

  (fn dsl.for-loop [cond step body loop-control]
    (local loop-control (or loop-control (LoopControl)))

    (local header-block (runtime:mk-local-ctx))
    (local cond-block (runtime:mk-local-ctx))
    (local loop-block (runtime:mk-local-ctx))
    
    (local ctx (runtime:pop-ctx))
    (ctx:instruction (Op.OpBranch header-block.id))

    (runtime:push-ctx cond-block)
    (local cond (cond))
    (local cond-ctx (runtime:pop-ctx))
    (local cond-id (cond-ctx:node-id cond))

    (runtime:push-ctx loop-block)
    (body)

    (local cont-block (runtime:mk-local-ctx))
    (local merge-block (runtime:mk-local-ctx))
    (local loop-ctx (runtime:pop-ctx))

    (header-block:instruction (Op.OpLoopMerge merge-block.id cont-block.id loop-control))
    (header-block:instruction (Op.OpBranch cond-block.id))
    (cond-ctx:instruction (Op.OpBranchConditional cond-id loop-block.id merge-block.id))
    (loop-ctx:instruction (Op.OpBranch cont-block.id))

    (runtime:push-ctx cont-block)
    (step)
    (local cont-ctx (runtime:pop-ctx))
    (cont-ctx:instruction (Op.OpBranch header-block.id))

    (runtime:push-ctx merge-block))

  (fn dsl.while-loop [cond body loop-control]
    (local loop-control (or loop-control (LoopControl)))

    (local header-block (runtime:mk-local-ctx))
    (local cond-block (runtime:mk-local-ctx))
    (local loop-block (runtime:mk-local-ctx))
    (local cont-block (runtime:mk-local-ctx))
    (local merge-block (runtime:mk-local-ctx))
    
    (local ctx (runtime:pop-ctx))
    (ctx:instruction (Op.OpBranch header-block.id))

    (header-block:instruction (Op.OpLoopMerge merge-block.id cont-block.id loop-control))
    (header-block:instruction (Op.OpBranch cond-block.id))

    (runtime:push-ctx cond-block)
    (local cond (cond))
    (local cond-ctx (runtime:pop-ctx))
    (local cond-id (cond-ctx:node-id cond))
    (cond-ctx:instruction (Op.OpBranchConditional cond-id loop-block.id merge-block.id))

    (runtime:push-ctx loop-block)
    (body)
    (local loop-ctx (runtime:pop-ctx))
    (loop-ctx:instruction (Op.OpBranch cont-block.id))

    (cont-block:instruction (Op.OpBranch header-block.id))

    (runtime:push-ctx merge-block))

  (fn dsl.if-then-else [cond then else]
    (local then-block (runtime:mk-local-ctx))
    (local else-block (runtime:mk-local-ctx))
    
    (local ctx (runtime:pop-ctx))
    (local cond-id (ctx:node-id cond))

    (runtime:push-ctx then-block)
    (local then-result (then))
    (local then-ctx (runtime:pop-ctx))
    (local then-id (if then-result (then-ctx:node-id then-result)))

    (runtime:push-ctx else-block)
    (local else-result (else))
    (local else-ctx (runtime:pop-ctx))
    (local else-id (if else-result (else-ctx:node-id else-result)))
    
    (local merge-block (ctx:sibling))
    (ctx:instruction (Op.OpSelectionMerge merge-block.id (SelectionControl)))
    (ctx:instruction (Op.OpBranchConditional cond-id then-block.id else-block.id []))
    (then-ctx:instruction (Op.OpBranch merge-block.id))
    (else-ctx:instruction (Op.OpBranch merge-block.id))

    (local result (if
      (and (not= nil then-result) (not= nil else-result)
           (not= :void then-result.type.kind)
           (not= :void else-result.type.kind)
           (= then-result.type else-result.type))
      (do (local phi (Node.phi then-result.type [then-id then-ctx.id] [else-id else-ctx.id]))
          (merge-block:reify-node phi)
          phi)))

    (runtime:push-ctx merge-block)
    result)

  dsl)


{ : Runtime
  : Env
  : Block
  : BlockContext
  : Function
  : Dsl
}