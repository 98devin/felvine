(local base (require :base))
(local ast (require :ast))
(local spirv (require :spirv))
(local runtime (require :runtime))
(local requirements (require :requirements))
(local types (require :types))
(local fennel (require :fennel))

(local
  { : Op
    : Decoration
    : Capability
    : ExecutionModel
    : StorageClass
    : SelectionControl
    : LoopControl
    : MemorySemantics
  } spirv)

(local
  { : Node : node?
    : Type : type?
    : enum?
  } ast)

(local
  { : Runtime
    : Block
    : Function
  } runtime)



(local Dsl {})

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
      :step Node.step
      :smoothstep Node.smoothstep
      :select Node.select
      :fma Node.fma
      :*+ Node.fma

      ; :control-barrier Node.aux.control-barrier
      ; :memory-barrier Node.aux.memory-barrier

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
      :lsb Node.lsb
      :msb Node.msb
  
      :determinant Node.determinant
      :det Node.determinant
      :invert Node.matrix-inverse
     
      :| Node.|
      :& Node.&

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
    (runtime.env:instruction (Op.OpTypeForwardPointer id StorageClass.PhysicalStorageBuffer))
    (Type.pointer nil StorageClass.PhysicalStorageBuffer id))

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
  ; (fn export.builtin [name])

  (fn dsl.variable [type storage]
    (local storage (or storage StorageClass.Function))
    (local v (Node.variable type storage))
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

(fn Dsl.dofile [file runtime]
  (local runtime (or runtime (Runtime.new)))
  (local env (Dsl.create-exported-env runtime))
  (fennel.dofile file
    { :env env
      :requireAsInclude true
    })
  runtime)

(fn Dsl.translate-file [file]
  
  (local runtime (Runtime.new))
  (local env (Dsl.create-exported-env runtime))

  (local (f err) (io.open file :r))
  (assert (= err nil) err)
  (local content (f:read :*a))
  (f:close)

  (local lua-content 
    (fennel.compileString content
      { :requireAsInclude true
        :filename file
        :env env
      }))
  lua-content)

Dsl