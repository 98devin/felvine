
(local ast (require :ast))
(local base (require :base))
(local spirv (require :spirv))
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
    : Capability
    : Decoration
    : ExecutionMode
    : StorageClass
    : FunctionControl
    : AddressingModel
    : MemoryModel
  } spirv)


(local Env { :mt {} })
(local Runtime { :mt {} })
(local BlockContext { :mt {} :response {} })
(local Function { :mt {} })
(local Block { :mt {} })


(set Env.mt.__index Env)

(fn Env.new []
    (local env
        { :next-id 1
          :type-ids {}        ; id assigned to each unique type-info
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
; .op          Op          ; OpFunction
; .type        type-info   ; function type
; .params      list[node]  ; function parameter value references
; .opparams    list[Op]
; .opvariables list[Op]    ; Function scope variables
; .interface   table[id]   ; Global scope variables (needed for entrypoints)
; .blocks      list[block]
; .scope       scope       ; root function scope
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
      :blocks []
      :opparams []
      :opvariables []
      :interface {} ; referenced global variables
      :scope { :variables {} }
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
  (self:reify-type type))

(fn Block.reify-type [self type id]
  (or (self.env:type-id? type)
    (do
      (when id (tset self.env.type-ids type.summary id))
      (local new-type-id (or (type:reify self id) (self:fresh-id)))
      (tset self.env.type-ids type.summary new-type-id)
      new-type-id)))

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
  (self:reify-type type))

(fn Runtime.reify-type [self type id]
  (local ctx (or (self:current-ctx) self.env))
  (or (ctx:type-id? type)
    (do
      (when id (tset self.env.type-ids type.summary id))
      (local new-type-id (or (type:reify ctx id) (ctx:fresh-id)))
      (tset self.env.type-ids type.summary new-type-id)
      new-type-id)))

(fn Block.decorate-id [self id ...]
  (self.env:decorate-id id ...))
  
(fn Block.decorate-member-id [self id member ...]
  (self.env:decorate-member-id id member ...))
  
(fn Runtime.mk-local-ctx [self]
  (local ctx (self:current-ctx))
  (ctx:sibling))

{ : Runtime
  : Env
  : Block
  : BlockContext
  : Function
}