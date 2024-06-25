(local base (require :base))
(local enum? base.enum?)
(local spirv (require :spirv))
(local fennel (require :fennel))

(local
    { : AddressingModel
      : BuiltIn
      : Capability
      : Decoration
      : Dim
      : ExecutionMode
      : ExecutionModel
      : ExtGLSL
      : FunctionControl
      : GroupOperation
      : ImageFormat
      : ImageOperands
      : MemoryModel
      : Op
      : Scope
      : SourceLanguage
      : SpecConstantOp
      : StorageClass
    } spirv)
    



(local Type { :mt {} :aux {} })
(local Node { :mt {} :aux {} :glsl {} })

(fn type? [t] 
  (= (getmetatable t) Type.mt))

(fn node? [n]
  (= (getmetatable n) Node.mt))



; type-info structure base
; .instance  ?number  ; to allow cloning for different (member) decorations
; .summary   string   ; semi readable hash of the type
; .opaque    bool
; .size      ?number  ; in bytes, if not opaque
; .alignment ?number  ; in bytes, if not opaque
; .kind      :void | :bool | :int | :float | :vector | :matrix | :image | :sampler | :sampled-image | :array | :pointer | :function | :struct

; type-info structure :int
; .bits      number
; .signed    bool

; type-info structure :float
; .bits      number

; type-info structure :vector | :array
; .elem      type-info
; .count     ?number

; type-info structure :matrix
; .elem      type-info
; .col-type  type-info
; .rows      number
; .cols      number

; type-info structure :image
; .elem      type-info
; .dim       Dim
; .depth     bool     
; .array     bool
; .ms        bool
; .usage     :texture | :storage
; .format    ?ImageFormat

; type-info structure :sampled-image
; .image     type-info

; type-info structure :pointer
; .elem      type-info
; .storage   StorageClass

; type-info structure :function
; .return    type-info
; .params    list[type-info]

; type-info structure :struct
; .field-types   list[type-info]
; .field-names   ?list[string]
; .field-indices ?table[string, number]

(fn Type.new [o]
  (setmetatable (or o {}) Type.mt))

(fn Type.aux.contained-matrix [t]
  (case t
    {:kind :matrix} t
    {:kind :array} (Type.aux.contained-matrix t.elem)))

(fn Type.aux.layout-struct-member [type member member-type env]
  (local contained-matrix (Type.aux.contained-matrix member-type))
  (when contained-matrix 
    (local (majority vector)
      (if (env:decorated-member? type member :RowMajor)
        (values Decoration.RowMajor (Type.vector contained-matrix.elem contained-matrix.cols))
        (values Decoration.ColMajor (Type.vector contained-matrix.elem contained-matrix.rows))))
    (local {: size : alignment} vector)
    (local padded-size (band (+ size (- alignment 1)) (bnot (- alignment 1))))
    (env:decorate-member type member majority (Decoration.MatrixStride padded-size))))


(fn Type.layout [type env]
  (case type.kind
    :struct
      (do 
        (var offset 0)
        (each [i field (ipairs type.field-types)]
          (Type.layout field env)
          (Type.aux.layout-struct-member type (- i 1) field env)
          (local {: size : alignment} field)
          (assert alignment (.. "Cannot layout struct with opaque member: " (. type.field-names i) field.summary))
          (assert (or size (= i (# type.field-types)))
            (.. "Cannot layout struct with unsized member if it is not last: " (. type.field-names i) field.summary))
          (set offset (band (+ offset (- alignment 1)) (bnot (- alignment 1))))
          (env:decorate-member type (- i 1) (Decoration.Offset offset))
          (when size (set offset (+ offset size)))))

    :array
      (let [{: size : alignment} type.elem
            size (assert size (.. "Cannot layout array with unsized element type: " type.elem.summary))
            padded-size (band (+ size (- alignment 1)) (bnot (- alignment 1)))]
        (Type.layout type.elem env)
        (env:decorate-type type (Decoration.ArrayStride padded-size)))))


; Type construction with multiple inputs and non-node (constant) arguments
; e.g. to allow (u32 0) or (vec4f 10.0 -10.0 (vec2f a b))
; should propagate (spec-)const-ness.
; serves as a main way to turn meta-values into typed values.
(fn Type.construct [tycon ...]
  (case tycon
    {:kind :int : signed}
      (do (local arg ...)
          (if (node? arg) (Node.convert arg tycon)
              (= (type arg) :number)
                (do (assert (or signed (>= arg 0)) (.. "Unsigned integer must be >= 0, got: " arg))
                    (Node.constant tycon (math.floor arg)))
              (error (.. "Cannot construct integer from argument: " (fennel.view arg)))))
              ; TODO: Allow specifying a particular bit pattern via a string?
    {:kind :float}
      (do (local arg ...)
          (if (node? arg) (Node.convert arg tycon)
              (= (type arg) :number) (Node.constant tycon arg)
              (error (.. "Cannot construct float from argument: " (fennel.view arg)))))
              ; TODO: Allow specifying a particular bit pattern via a string?
    {:kind :vector : elem : count}
      (do (local args [...])
          (local components [])
          (var component-count 0)
          (each [_ arg (ipairs args)]
            (if (node? arg)
                (do (local arg (Node.aux.autoderef arg))
                    (local (prim arg-count) (arg.type:prim-count))
                    (set component-count (+ component-count arg-count))
                    (table.insert components (Node.convert arg (Type.vector elem arg-count))))
                (= (type arg) :table)
                (do (set component-count (+ component-count (# arg)))
                    (icollect [_ arg-elem (ipairs arg) &into components] 
                      (elem arg-elem)))
                (= (type arg) :number)
                (do (set component-count (+ component-count 1))
                    (table.insert components (elem arg)))
                (error (.. "Cannot construct vector from argument: " (fennel.view arg)))))
          
          (assert (or (= component-count count) (= component-count 1)) 
                  (.. "Incorrect number of arguments to construct vector: " component-count " " tycon.summary))
          (if
            (= component-count 1) (Node.convert (. components 1) tycon)
            (= (# components) 1) (. components 1) 
            (do (local common-kind (Node.aux.common-node-kind-of components))
              (case common-kind
                (where (or :expr :spec-constant)) (Node.composite tycon components common-kind)
                :constant ; need to flatten the constants inside to replicate regular operations
                  (do (local flat-components [])
                      (each [_ component (ipairs components)]
                        (if (= component.kind :vector)
                          (icollect [_ v (ipairs component.constant) &into flat-components] v)
                          (table.insert flat-components component.constant)))
                      (Node.constant tycon flat-components))))))
    {:kind :array : elem : count}
      (do (local args [...])
          (local arg-count (# args))
          (assert (or (= arg-count 1) (= arg-count count)) "Array must be constructed from a single table or unpacked sequence")
          (local args (if (= arg-count 1) (. args 1) args))

          (local components
            (icollect [_ arg (ipairs args)]
              (elem arg)))
          (local component-count (# components))

          (when count
            (assert (= component-count count) (.. "Incorrect number of arguments to construct array: " component-count tycon.summary)))

          (local common-kind (Node.aux.common-node-kind-of components))
          (case common-kind
            :constant (Node.constant (Type.array elem component-count) components) ; we know count, no need for runtime array.
            _ (Node.composite tycon components common-kind)))
    other
      (do (local arg ...)
          (assert (node? arg) (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary))
          (if 
            (= arg.type tycon) arg
            (and (= arg.type.kind :pointer)
                 (= arg.type.elem tycon)) (Node.deref arg)
            (error (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary))))))

(fn Type.clone [info]
  (local shallowcopy
    (collect [k v (pairs info)] k v))
  (case shallowcopy.instance
    nil (set shallowcopy.instance 1)
    n   (set shallowcopy.instance (+ n 1)))
  shallowcopy)

; forced id parameter necessary to ensure forward pointer declarations are
; linked properly, e.g. for types which reference a physicalstoragebuffer* to themselves.
(fn Type.reify [self ctx id]
  (local id (or id (ctx:fresh-id)))
  (case self.kind
    :void (ctx:instruction (Op.OpTypeVoid id))
    :bool (ctx:instruction (Op.OpTypeBool id))
    :int (ctx:instruction (Op.OpTypeInt id self.bits (if self.signed 1 0)))
    :float (ctx:instruction (Op.OpTypeFloat id self.bits))
    :vector (ctx:instruction (Op.OpTypeVector id (ctx:type-id self.elem) self.count))
    :matrix (do (local column (Type.vector self.elem self.rows))
                (ctx:instruction (Op.OpTypeMatrix id (ctx:type-id column) self.cols)))
    :sampler (ctx:instruction (Op.OpTypeSampler id))
    :sampled-image (ctx:instruction (Op.OpTypeSampledImage id (ctx:type-id self.image)))
    :image (ctx:instruction
      (Op.OpTypeImage
        id
        (ctx:type-id self.elem)
        self.dim
        (if self.depth 1 0)
        (if self.array 1 0)
        (if self.ms 1 0)
        (case self.usage
          :texture 1
          :storage 2)
        (or self.format ImageFormat.Unknown)))

    :pointer 
      (when (or (= nil self.forward)
              (= id self.forward))
        (ctx:instruction (Op.OpTypePointer id self.storage (ctx:type-id self.elem))))

    :function (ctx:instruction
      (Op.OpTypeFunction
        id
        (ctx:type-id self.return)
        (icollect [_ t (ipairs self.params)]
          (ctx:type-id t))))
      
    ; TODO: emit member offset information
    :struct
      (do (ctx:instruction
            (Op.OpTypeStruct id (icollect [_ t (ipairs self.field-types)] (ctx:type-id t))))
          (when self.field-names
            (each [i v (ipairs self.field-names)]
              (ctx:instruction (Op.OpMemberName id (- i 1) v))))
          (when self.field-decorations
            (each [i decs (pairs self.field-decorations)]
              (each [_ dec (ipairs decs)]
                (ctx:decorate-member-id id (- i 1) dec)))))
    :array
      (case self.count
        nil (ctx:instruction (Op.OpTypeRuntimeArray id (ctx:type-id self.elem)))
        count (do (local count ((Type.int 32 false) count))
                  (ctx:instruction (Op.OpTypeArray id (ctx:type-id self.elem) (ctx:node-id count))))))

  (ctx:instruction (Op.OpName id self.summary))
  id)

(fn Type.make-summary [info]
  (local summary 
    (case info.kind
      :void :void
      :bool :bool
      :int (.. (if info.signed "i" "u") info.bits)
      :float (.. "f" info.bits)
      :vector (.. "v" info.count info.elem.summary)
      :array
        (do (local count
          (if (= nil info.count) ""
              (node? info.count)
                (if (= :constant info.count.kind) info.count.constant
                    (string.format "spec(%p)" info.count))
              (tostring info.count)))
            (.. "[" count "]" info.elem.summary))
      :matrix (.. "m" info.rows "x" info.cols info.elem.summary)
      :sampler :sampler
      :sampled-image
        (info.image.summary:gsub "texture" "sampler")
      :image (.. info.usage info.dim.tag
        (if info.depth "Depth" "")
        (if info.ms "MS" "")
        (if info.array "Array" "")
        "<" (if info.format info.format.tag info.elem.summary) ">")
      :pointer 
        (if info.forward 
          (.. info.storage.tag :* info.forward)
          (.. info.storage.tag :* info.elem.summary))
      :function (.. "(" (table.concat (icollect [_ e (ipairs info.params)] e.summary) ",") ")" info.return.summary)
      :struct 
        (if info.field-names
          (.. "{" (table.concat (icollect [i e (ipairs info.field-types)] (.. (. info.field-names i) ":" e.summary)) ",") "}")
          (.. "{" (table.concat (icollect [_ e (ipairs info.field-types)] e.summary) ",") "}"))
    ))
  (set info.summary (.. summary (if info.instance (.. "(" info.instance ")") "")))
  summary)

(fn Type.void []
  (Type.new
    { :kind :void
      :opaque true
      :summary :void
    }))

(fn Type.bool []
  (Type.new
    { :kind :bool
      :opaque true
      :summary :bool
    }))

(fn Type.sampler []
  (Type.new
    { :kind :sampler
      :opaque true
      :summary :sampler
    }))

(fn Type.sampled [image]
  (assert (= image.kind :image) (.. "Cannot sample non-image type: " image.summary))
  (assert (= image.usage :texture) (.. "Cannot sample storage image: " image.summary))
  (Type.new
    { :kind :sampled-image
      :opaque true
      :image image
    }))

(fn Type.int [b signed]
  (local size (math.floor (/ (+ b 7) 8)))
  (Type.new
    { :kind :int
      :bits b
      :size size
      :alignment size
      :signed signed
      :opaque false
    }))

(fn Type.float [b]
  (local size (math.floor (/ (+ b 7) 8)))
  (Type.new
    { :kind :float
      :bits b
      :size size
      :alignment size
      :opaque false
    }))

(fn Type.vector [elem count]
  (if (= count 1) elem
    (Type.new
      { :kind :vector
        :size (if elem.size (* elem.size count))
        :alignment elem.alignment
        :opaque false
        :elem elem
        :count count
      })))

(fn Type.array [elem count]
  (Type.new
    { :kind :array
      :size (if (and count (not elem.opaque) (not= nil elem.size)) (* elem.size count) nil)
      :alignment elem.alignment
      :opaque elem.opaque
      :elem elem
      :count count
    }))

(fn Type.matrix [elem rows cols majority]
  (Type.new
    { :kind :matrix
      :size (* elem.size rows cols)
      :alignment elem.alignment
      :opaque false
      :elem elem
      :rows rows
      :cols cols
      :majority majority
    }))

(fn advance-size-alignment [current {: size : alignment}]
  (if (or (= nil current) (= nil current.size) (= nil alignment))
    nil
    (let [aligned-offset (band
          (+ current.size (- alignment 1))
          (bnot (- alignment 1)))]
        { :size (if (not= nil size) (+ aligned-offset size))
          :alignment (math.max current.alignment alignment)
        })))

(fn Type.struct [field-types field-names field-decorations]
    (local field-decorations (or field-decorations {}))
    (local field-indices {})
    (each [i t (pairs field-types)]
      (tset field-indices (. field-names i) (- i 1)))
    (local size-alignment
      (accumulate [current {:size 0 :alignment 1} _ ty (ipairs field-types)]
        (advance-size-alignment current ty)))
    (Type.new
      { :kind :struct
        :opaque (= nil size-alignment)
        :size (?. size-alignment :size)
        :alignment (?. size-alignment :alignment)
        : field-types
        : field-names
        : field-indices
        : field-decorations
      }))

(fn Type.function [return params]
  (Type.new
    { :kind :function
      :return return
      :params params
      :opaque true
    }))

(fn Type.pointer [elem storage forward]
  (local (opaque size alignment)
    (if (= storage StorageClass.PhysicalStorageBuffer)
        (values false 8 8)
        true))
  (Type.new
    { :kind :pointer
      :opaque opaque
      :size size
      :alignment alignment
      :elem elem
      :storage storage
      :forward forward
    }))

; `access` is indexing from pointers and can be dynamic
(fn Type.access [self index]
  (assert (= self.kind :pointer) (.. "Cannot `access` via non pointer type: " self.summary))
  (fn ptr-to [new-elem] (Type.pointer new-elem self.storage))
  (case self.elem
    {:kind :struct : field-types}
      (do (assert (= index.kind :constant) (.. "Cannot access non-constant struct field of " self.elem.summary))
          (assert (= index.type.kind :int) (.. "Struct field access must be an integer, got: " index.type.summary))
          (local member-index (+ index.constant 1))
          (assert (<= member-index (# field-types)) (.. "Struct does not have enough fields for index: " member-index " " self.elem.summary))
          (ptr-to (. field-types member-index)))
    {:kind :vector : count}
      (do (assert (= index.type.kind :int) (.. "Vector index must be an integer, got: " index.type.summary))
          (when (= index.kind :constant)
            (assert (< (or index.constant 0) count) (.. "Vector index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr-to self.elem.elem))
    {:kind :array : ?count}
      (do (assert (= index.type.kind :int) (.. "Array index must be an integer, got: " index.type.summary))
          (when (and (= index.kind :constant) (not= nil ?count))
            (assert (< index.constant ?count) (.. "Array index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr-to self.elem.elem))
    {:kind :matrix : cols : rows}
      (do (assert (= index.type.kind :int) (.. "Matrix index must be an integer, got: " index.type.summary))
          (when (= index.kind :constant)
            (assert (< (or index.constant 0) cols) (.. "Matrix index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr-to (Type.vector self.elem.elem rows)))
    _ (error (.. "Cannot index non-composite type: " self.elem.summary))))

; `extract` is indexing into values and must be static
(fn Type.extract [self index]
  (assert (= (type index) :number) (.. "Cannot `extract` with non-numeric index: " index))
  (case self
    {:kind :struct : field-types}
      (do (local member-index (+ index 1))
          (assert (<= member-index (# self.field-types)) (.. "Struct does not have enough fields for index: " member-index " " self.summary))
          (. self.field-types member-index))
    {:kind :vector : count}
      (do (assert (< index count)) (.. "Vector index would be out of bounds: " index " " self.summary)
          self.elem)
    {:kind :array : count}
      (do (when count
            (assert (< index count)) (.. "Array index would be out of bounds: " index " " self.summary))
          self.elem)
    {:kind :matrix : cols : rows}
      (do (assert (< index cols)) (.. "Matrix index would be out of bounds: " index " " self.summary)
          (Type.vector self.elem rows))
    _ (error (.. "Cannot index non-composite type: " self.summary))))

(fn Type.deref [self]
  (case self.kind
    :pointer self.elem
    _ (error (.. "Cannot dereference non-pointer type: " self.summary))))

(fn Type.prim-count [self]
  (case self.kind
    :int (values self 1)
    :float (values self 1)
    :vector (values self.elem self.count)
    _ (error (.. "Type is not primitive: " self.summary))))

(fn Type.prim-elem [self]
  (case self.kind
    :int self
    :float self
    :vector self.elem
    :matrix self.elem
    _ (error (.. "Type does not contain primitive numerical element: " self.summary))))

(fn Type.mt.__index [self key]
  (case key
    :summary (Type.make-summary self)
    _ (. Type key)))

(fn Type.mt.__eq [self other]
  (= self.summary other.summary))

(fn Type.mt.__tostring [self]
  self.summary)

(set Type.mt.__call Type.construct)

(fn struct-member-index [type member-name]
  (local ix (?. type :field-indices member-name))
  (assert ix (.. "Type is not a struct or has no member `" member-name "`: " type.summary))
  ix)


; node structure
; .kind          :expr | :phi | :function | :variable | :param | :constant | :spec-constant
; .type          type-info
; .reify         (fn[self block] -> id) 
  ; write Op(s) to block returning result id
  ; requires of course that all dependencies and this node's type have been reified already.

; node structure :expr   ; is a statement if type is void, otherwise a value
; .operation     Op.tag
; .operands      list[any]

; node structure :phi
; .sources       list[[id, block]]

; node structure :function
; .function-id  id

; node structure :variable
; .storage      StorageClass
; .initializer  ?node

; node structure :constant
; .constant  any

; node structure :spec-constant
; .operation     SpecConstantOp.tag
; .operands      list[any]
; .dependencies  list[node]

(fn Node.new [o]
  (local o (or o {}))
  (setmetatable o Node.mt))

(set Node.constant-impl {})
(set Node.spec-constant-impl {})

(fn Node.aux.common-node-kind [kind1 kind2]
  (case (values kind1 kind2)
    (:constant :constant)           :constant
    (:constant :spec-constant)      :spec-constant
    (:spec-constant :constant)      :spec-constant
    (:spec-constant :spec-constant) :spec-constant
    _ :expr))

(fn Node.aux.common-node-kind-of [nodes]
  (accumulate [kind :constant _ node (ipairs nodes)]
    (Node.aux.common-node-kind kind node.kind)))

(fn node-reify-param [self ctx]
  (local tid (ctx:type-id self.type))
  (local id (ctx:fresh-id))
  (local op (Op.OpFunctionParameter tid id))
  (ctx:instruction op)
  id)

(fn Node.param [type]
  (Node.new
    { :kind :param
      :type type
      :reify node-reify-param
    }))

(fn node-reify-phi [self ctx]
  (local tid (ctx:type-id self.type))
  (local id (ctx:fresh-id))
  (local op (Op.OpPhi tid id self.sources))
  (ctx:instruction op)
  id)

(fn Node.phi [type ...]
  (Node.new
    { :kind :phi
      :type type
      :sources [...]
      :reify node-reify-phi
    }))

(fn node-reify-function [self ctx]
  self.function.id)

(fn Node.function [function]
  (Node.new
    { :kind :function
      :type function.type
      :function function
      :reify node-reify-function
    }))

(fn node-reify-variable [self ctx]
  (local tid (ctx:type-id self.type))
  (local init (if (rawget self :initializer) (ctx:node-id self.initializer) nil))
  (local id (ctx:fresh-id))
  (local op (Op.OpVariable tid id self.storage init))
  (ctx:instruction op)
  id)

(fn Node.variable [type storage initializer]
  (local storage (or storage StorageClass.Function))
  (Node.new
    { :kind :variable
      :type (Type.pointer type storage)
      :storage storage
      :initializer initializer
      :reify node-reify-variable
    }))

(fn node-constant-summary [self]
  (or (rawget self :summary)
    (do (local summary (fennel.view (rawget self :constant)))
        (set self.summary summary)
        summary)))

(fn type-serialize-fmt [t]
  (case t
    {:kind :int : bits : signed}
      (let [words (math.floor (/ (+ bits 31) 32))
            sigil (if signed "i" "I")]
        (.. sigil (* words 4)))
    {:kind :float : bits}
      (if (> bits 32) "d" "f")))

(fn node-reify-constant [self ctx]
  (local tid (ctx:type-id self.type))
  (local (existing cid) (ctx:constant-id tid (node-constant-summary self)))
  (when (not existing)
    (fn constituent-ids [elem constants]
      (icollect [_ v (ipairs constants)]
        (ctx:node-id (Node.constant elem v))))
    (local op
      (if (= nil self.constant) (Op.OpConstantNull tid cid)
        (case self.type.kind
          :bool
            (if self.constant (Op.OpConstantTrue tid cid) (Op.OpConstantFalse tid cid))
          (where (or :int :float))
            (Op.OpConstant tid cid (base.serializable-with-fmt (type-serialize-fmt self.type) self.constant))
          (where (or :vector :array))
            (Op.OpConstantComposite tid cid (constituent-ids self.type.elem self.constant))
          :matrix
            (Op.OpConstantComposite tid cid (constituent-ids (Type.vector self.type.elem self.type.rows) self.constant))
          :struct
            (Op.OpConstantComposite tid cid 
              (icollect [i m (ipairs self.type.field-names)]
                (ctx:node-id (Node.constant (. self.type.field-types i) (. self.constant m))
          :pointer
            (error (.. "Cannot have a constant non-null pointer, tried to provide value: " self.constant))
          :function
            (error "Cannot define constant function. Function nodes are already constants.")
          :void
            (error "Cannot define constant void. Values of void do not exist.")))))))
    (ctx:instruction op))
  cid)

(fn node-reify-spec-constant [self ctx]
  (local tid (ctx:type-id self.type))
  (local cid (ctx:fresh-id))
  (fn constituent-ids [elem constants]
    (icollect [_ v (ipairs constants)]
      (ctx:node-id (Node.constant elem v))))
  (local op
    (case self.type.kind
      :bool
        (if self.constant (Op.OpSpecConstantTrue tid cid) (Op.OpSpecConstantFalse tid cid))
      (where (or :int :float))
        (Op.OpSpecConstant tid cid (base.serializable-with-fmt (type-serialize-fmt self.type) self.constant))
      (where (or :vector :array))
        (Op.OpSpecConstantComposite tid cid (constituent-ids self.type.elem self.constant))
      :matrix
        (Op.OpSpecConstantComposite tid cid (constituent-ids (Type.vector self.type.elem self.type.rows) self.constant))
      :struct
        (Op.OpSpecConstantComposite tid cid 
          (icollect [i m (ipairs self.type.field-names)]
            (ctx:node-id (Node.constant (. self.type.field-types i) (. self.constant m))
      :pointer
        (error (.. "Cannot declare a spec-constant pointer; tried to provide value: " self.constant))
      :function
        (error "Cannot define a spec-constant function. Function nodes are already constants.")
      :void
        (error "Cannot define a spec-constant of type void. Values of void do not exist."))))))
  (ctx:instruction op)
  cid)

;
(fn Node.aux.adjust-constant-value [ty value]
  ; (print :adjust-constant-value ty.summary value)
  (local value (if (node? value) value.constant value))
  (case ty
    {:kind :int : signed : bits}
      (if (> bits 62)
        (if (or signed (>= value 0)) (assert (math.tointeger value) "Cannot represent integer")
            (error "Cannot represent unsigned integer"))
        (let [max-value (^ 2 bits)
              sign (if (>= value 0) 1 -1)
              wrapped-value (% (math.modf value) (* sign max-value))]
          (assert 
            (math.tointeger
              (if (and (not signed) (< wrapped-value 0)) (+ wrapped-value max-value)
                wrapped-value)) "Cannot represent integer")))
    {:kind :float}
      value ; nothing really needs to happen since all numbers can be converted to floats
    (where (or {:kind :vector : elem} {:kind :array : elem}))
      (icollect [_ v (ipairs value)] (Node.aux.adjust-constant-value elem v))
    {:kind :matrix : elem : rows}
      (let [col-type (Type.vector elem rows)]
        (icollect [_ col (ipairs value)] (Node.aux.adjust-constant-value col-type col)))
    ))

(fn Node.constant [type value]
  ; (print :Node.constant type.summary value)
  (if (node? value)
    (if (= value.type type) value
      (Node.new
        { :kind :constant
          :type type
          :constant (Node.aux.adjust-constant-value type value.constant)
          :reify node-reify-constant
        }))    
    (Node.new
      { :kind :constant
        :type type
        :constant (Node.aux.adjust-constant-value type value)
        :reify node-reify-constant
      })))

(fn Node.spec-constant [type value]
  (local const (Node.constant type value))
  (set const.kind :spec-constant)
  (set const.reify node-reify-spec-constant)
  const)

(fn node-reify-composite [self ctx]
  (local tid (ctx:type-id self.type))
  (local argids
    (icollect [_ arg (ipairs self.operands)]
      (ctx:node-id arg)))
  (local id (ctx:fresh-id))
  (local op ((. Op self.operation) tid id argids))
  (ctx:instruction op)
  id)

(fn Node.composite [type components kind]
  (local operation
    (case (or kind :expr)
      :expr :OpCompositeConstruct
      :spec-constant :OpSpecConstantComposite
      :constant :OpConstantComposite
      ))
  (Node.new
    { :kind (or kind :expr)
      :type type
      :operation operation
      :operands components
      :reify node-reify-composite
    }))


(fn Node.aux.base-pointer [ptr]
  (assert (= ptr.type.kind :pointer) (.. "Node is not a pointer: " (tostring ptr)))
  (var base ptr)
  (while (and (= :expr base.kind) (= :OpAccessChain base.operation))
    (set base (. base.operands 1)))
  base)


(fn node-reify-load [self ctx]
  (local [source memory-ops] self.operands)
  (local tid (ctx:type-id self.type))
  (local source-id (ctx:node-id source))
  (local id (ctx:fresh-id))
  (local op (Op.OpLoad tid id source-id memory-ops))
  (ctx:instruction op)

  (local base (Node.aux.base-pointer source))
  (when (and (= base.kind :variable) (not= base.storage StorageClass.Function))
    (ctx:interface-id (ctx:node-id base))) ; already requested so won't change instructions
  
  id)

(fn Node.deref [node]
  (case node.type.kind
    :pointer
      (Node.new
        { :kind :expr
          :type (node.type:deref)
          :operation :OpLoad
          :operands [node]
          :reify node-reify-load
        })
    _ (error "Cannot dereference non-pointer value")))

(fn node-reify-passthrough [self ctx]
  (local id (ctx:node-id (. self.operands 1)))
  id)

(fn Node.aux.passthrough-convert [self type]
  (if (= self.kind :constant)
    (Node.constant type self.constant)
    (Node.new
      { :kind :expr
        :type type
        :operation :Passthrough
        :operands [self]
        :reify node-reify-passthrough
      })))


(fn Node.any? [vec]
  (local bool (Type.bool))
  (local (prim count) (vec.type:prim-count))
  (assert (= bool prim) (.. "Cannot take disjunction of type: " vec.type.summary))
  (if (= 1 count) vec
    (Node.aux.op :OpAny bool vec)))


(fn Node.all? [vec]
  (local bool (Type.bool))
  (local (prim count) (vec.type:prim-count))
  (assert (= bool prim) (.. "Cannot take conjunction of type: " vec.type.summary))
  (if (= 1 count) vec
    (Node.aux.op :OpAll bool vec)))


; This is only primitive type conversion,
; e.g. numbers and vectors of them.
; Anything else will need a dedicated routine, since
; only these simple types have conversion ops in spirv
(fn Node.convert [node type]
  (local node (Node.aux.autoderef node))

  (local (n-prim n-count) (node.type:prim-count))
  (local (t-prim t-count) (type:prim-count))

  ; cannot convert from vector to scalar
  ; (bitcast is a different operation)
  (when (not= n-count 1)
    (assert (= n-count t-count) (.. "Incompatible counts for conversion: " n-count " " t-count " from types: " node.type.summary " " type.summary)))

  (var out node)

  ; handle primitive conversion first
  (when (not= n-prim t-prim)
    (case (values n-prim t-prim)
      ({:kind :int :signed n-sign :bits n-bits}
       {:kind :int :signed t-sign :bits t-bits})
        (do
          ; need to sign extend before casting signed-ness
          (when (not= t-bits n-bits)
            (local extended (Type.vector (Type.int t-bits n-sign) n-count))
            (set out 
              (Node.aux.op
                (if n-sign :OpSConvert :OpUConvert)
                extended
                out)))
          (when (not= t-sign n-sign)
            (set out (Node.aux.passthrough-convert out (Type.vector t-prim n-count)))))
      ({:kind :int :signed n-sign} {:kind :float})
        (set out
          (Node.aux.op
            (if n-sign :OpConvertSToF :OpConvertUToF)
            (Type.vector t-prim n-count)
            out))
      ({:kind :float} {:kind :int :signed t-sign})
        (set out
          (Node.aux.op
            (if t-sign :OpConvertFToS :OpConvertFToU)
            (Type.vector t-prim n-count)
            out))
      ({:kind :float} {:kind :float})
        (set out
          (Node.aux.op
            :OpFConvert
            (Type.vector t-prim n-count)
            out))))
            
  ; handle scalar-to-vector broadcast
  (when (not= n-count t-count)
    (case (Node.aux.common-node-kind-of [out])
      :constant (set out (Node.constant type (fcollect [i 1 t-count] out.constant)))
      _ (set out (Node.composite type (fcollect [i 1 t-count] out)))))
    
  out)


(fn node-reify-op [self ctx]
  (local tid (ctx:type-id self.type))
  (local arg-ids
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:node-id arg) arg)))
  (local id (ctx:fresh-id))
  (local op ((. Op self.operation) tid id (table.unpack arg-ids)))
  (ctx:instruction op)
  id)

(fn node-reify-spec-constant-op [self ctx]
  (local tid (ctx:type-id self.type))
  (local arg-ids
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:node-id arg) arg)))
  (local id (ctx:fresh-id))
  (local op (Op.OpSpecConstantOp tid id ((. SpecConstantOp self.operation) (table.unpack arg-ids))))
  (ctx:instruction op)
  id)

(fn node-reify-glsl [self ctx]
  (local ext-id (ctx:ext-inst-id :GLSL.std.450))
  (local tid (ctx:type-id self.type))
  (local arg-ids
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:node-id arg) arg)))
  (local id (ctx:fresh-id))
  (local op (Op.OpExtInst tid id ext-id ((. ExtGLSL self.operation) (table.unpack arg-ids))))
  (ctx:instruction op)
  id)


(fn Type.prim-common-supertype [t0 ...]
  (accumulate [t t0 _ t1 (ipairs [...])]
    (Type.aux.prim-common-supertype t t1)))

(fn Type.aux.prim-common-supertype [lt rt]
  (local (l-prim l-count) (lt:prim-count))
  (local (r-prim r-count) (rt:prim-count))

  (when (and (not= 1 l-count) (not= 1 r-count))
    (assert (= l-count r-count) (.. "Cannot find common result for these types: " lt.summary " " rt.summary)))
  
  (local out-prim
    (if (= l-prim.kind r-prim.kind :bool) l-prim
      (do 
        (assert (and (not= l-prim.kind :bool) (not= r-prim.kind :bool)) "Cannot mix bool with number.")
        (local out-kind
          (if (or (= l-prim.kind :float) (= r-prim.kind :float)) :float :int))
        (local out-signed
          (if (or (= l-prim.kind :float) (= r-prim.kind :float)) true (or l-prim.signed r-prim.signed)))
        (local out-bits
          (math.max l-prim.bits r-prim.bits))
        (case out-kind
          :int (Type.int out-bits out-signed)
          :float (Type.float out-bits)))))

  (Type.vector out-prim (math.max l-count r-count)))



(fn Node.aux.make-op-internal [operation type ...]
  (Node.new
    { :kind :expr
      :type type
      :operation operation
      :operands [...]
      :reify node-reify-op
    }))

(fn Node.aux.make-glsl-op-internal [operation type ...]
  (Node.new
    { :kind :expr
      :type type
      :operation operation
      :operands [...]
      :reify node-reify-glsl
    }))

(fn Node.aux.make-spec-constant-op-internal [operation type ...]
  (Node.new
    { :kind :spec-constant
      :type type
      :operation operation
      :operands [...]
      :reify node-reify-spec-constant-op
    }))

(fn Node.aux.op [operation type ...]
  (local specialized-funcs
    [ (. Node.constant-impl operation) 
      (. Node.spec-constant-impl operation)
      Node.aux.make-op-internal ])
  (local start-ix
    (case (Node.aux.common-node-kind-of [...])
      :constant 1
      :spec-constant 2
      :expr 3 ))
  (faccumulate [value nil i start-ix 3 &until value]
    (let [f (. specialized-funcs i)]
      (when (not= nil f)
        (local (valid result) (pcall f operation type ...))
        (if valid result)))))


(fn Node.glsl.op [operation type ...]
  (local specialized-funcs
    [ (. Node.constant-impl (.. "GLSL" operation))
      (. Node.spec-constant-impl (.. "GLSL" operation))
      Node.aux.make-glsl-op-internal ])
  (local start-ix
    (case (Node.aux.common-node-kind-of [...])
      :constant 1
      :spec-constant 2
      :expr 3 ))
  (faccumulate [value nil i start-ix 3 &until value]
    (let [f (. specialized-funcs i)]
      (when (not= nil f)
        (local (valid result) (pcall f operation type ...))
        (if valid result)))))

(fn Node.aux.autoderef [node]
  (if (and (node? node) (= node.type.kind :pointer))
    (Node.deref node)
    node))

(fn node-simple-unop [{ : name :sint sint-op :uint uint-op :float float-op :bool bool-op }]
  (fn [node]
    (local opcode
      (case (node.type:prim-count)
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :bool} bool-op
        {:kind :float} float-op))
    (if (= nil opcode)
      (error (.. "Cannot " name " value of type: " node.type.summary)))
    (Node.aux.op
      opcode node.type node)))

(fn node-compare-unop
  [{ :sint sint-op
     :uint uint-op
     :float float-op
     :bool bool-op }]
  (fn [node]
    (local (prim count) (node.type:prim-count))
    (local opcode
     (case prim
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :bool} bool-op
        {:kind :float} float-op))
    (if (= nil opcode)
      (error (.. "Cannot compare values of type: " node.type.summary)))
    (local out-bool (Type.vector (Type.bool) count))
    (Node.aux.op
      opcode out-bool node)))

(fn node-glsl-unop [{ : name :sint sint-op :uint uint-op :float float-op :bool bool-op : no-f64? : no-i64? }]
  (fn [node]
    (var (out-prim out-count) (node.type:prim-count))
    (var opcode
      (case out-prim
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :bool} bool-op
        {:kind :float} float-op))
    (when (and (= nil opcode) (= out-prim.kind :int))
      (set opcode float-op)
      (set out-prim (Type.float 32)))
    (if (= nil opcode)
      (error (.. "Cannot " name " value of type: " node.type.summary)))
    (when no-f64?
      (case out-prim
        (where {:kind :float : bits} (> bits 32))
          (set out-prim (Type.float 32))))
    (when no-i64?
      (case out-prim
        (where {:kind :int : signed : bits} (> bits 32))
          (set out-prim (Type.int 32 signed))))
    (local out-type (Type.vector out-prim out-count))
    (Node.glsl.op
      opcode out-type (out-type node))))

(fn node-simple-binop 
  [{ : name 
     :sint sint-op
     :uint uint-op
     :float float-op
     :bool bool-op }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local out-type
      (if (and (node? lhs) (node? rhs)) (Type.prim-common-supertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (local opcode
      (case (out-type:prim-count)
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :bool} bool-op
        {:kind :float} float-op))
    (if (= nil opcode)
      (error (.. "Cannot " name " values of type: " out-type.summary)))
    (Node.aux.op opcode out-type 
      (out-type lhs)
      (out-type rhs))))

(fn node-compare-binop
  [{ :sint sint-op
     :uint uint-op
     :float float-op }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local out-type
      (if (and (node? lhs) (node? rhs)) (Type.prim-common-supertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (local (_ out-count) (out-type:prim-count))
    (local out-bool (Type.vector (Type.bool) out-count))
    (local opcode
      (case (out-type:prim-count)
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :float} float-op))
    (if (= nil opcode)
      (error (.. "Cannot compare values of type: " out-type.summary)))
    (Node.aux.op opcode out-bool
      (out-type lhs)
      (out-type rhs))))

(fn node-glsl-binop
  [{ : name 
     :sint sint-op
     :uint uint-op
     :float float-op
     :bool bool-op
     : no-f64?
     : no-i64? }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local out-type
      (if (and (node? lhs) (node? rhs)) (Type.prim-common-supertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (var (out-prim out-count) (out-type:prim-count))
    (var opcode
      (case out-prim
        {:kind :int :signed true} sint-op
        {:kind :int :signed false} uint-op
        {:kind :bool} bool-op
        {:kind :float} float-op))
    (when (and (= nil opcode) (= out-prim.kind :int))
      (set opcode float-op)
      (set out-prim (Type.float 32)))
    (if (= nil opcode)
      (error (.. "Cannot " name " values of type: " out-type.summary)))
    (when no-f64?
      (case out-prim
        (where {:kind :float : bits} (> bits 32))
          (set out-prim (Type.float 32))))
    (when no-i64?
      (case out-prim
        (where {:kind :int : signed : bits} (> bits 32))
          (set out-prim (Type.int 32 signed))))
    (local out-type (Type.vector out-prim out-count))
    (Node.glsl.op opcode out-type 
      (out-type lhs)
      (out-type rhs))))

;
; Constant propagation implementations
; NOTE: should review to ensure that Node.constant handles wrapping etc. in a way consistent with spirv.
; 

(fn Node.aux.const-int-float-convert [operation type node]
  ; (print operation type node)
  (case type.kind
    :int (Node.constant type (math.floor node.constant))
    :float (Node.constant type node.constant)))

(macro vectorized-const-impl-unop [op ...]
  (fn vectorize-unop [op]
    `(fn [operation# type# lhs#]
      ; (print operation# lhs#)
      (Node.constant type#
        (if (= (type lhs#.constant) :table)
            (icollect [_# l# (ipairs lhs#.constant)] (,op l#))
            (,op lhs#.constant)))))
  `(each [_# op# (ipairs [,...])]
    (tset Node.constant-impl op# ,(vectorize-unop op))))

(macro vectorized-const-impl-binop [op ...]
  (fn vectorize-binop [op]
    `(fn [operation# type# lhs# rhs#]
      ; (print operation# lhs# rhs#)
      (Node.constant type#
        (if (= (type lhs#.constant) :table) ; both are already of the correct type so must match.
            (icollect [i# l# (ipairs lhs#.constant)]
              (,op l# (. rhs#.constant i#)))
            (,op lhs#.constant rhs#.constant)))))
  `(each [_# op# (ipairs [,...])]
    (tset Node.constant-impl op# ,(vectorize-binop op))))


(each [_ op (ipairs [:OpSConvert :OpUConvert :OpFConvert :OpConvertSToF :OpConvertUToF :OpConvertFToS :OpConvertFToU])]
  (tset Node.constant-impl op Node.aux.const-int-float-convert))

(vectorized-const-impl-unop -
  :OpFNegate :OpSNegate)

(vectorized-const-impl-unop bnot
  :OpNot)

(vectorized-const-impl-unop not
  :OpLogicalNot)

(vectorized-const-impl-binop +
  :OpFAdd :OpIAdd)

(vectorized-const-impl-binop -
  :OpFSub :OpISub)

(vectorized-const-impl-binop *
  :OpFMul :OpIMul)

(vectorized-const-impl-binop /
  :OpFDiv :OpSDiv :OpUDiv)

(vectorized-const-impl-binop %
  :OpFMod :OpSMod :OpUMod)

(vectorized-const-impl-binop ^
  :GLSLPow)

(vectorized-const-impl-binop and
  :OpLogicalAnd)

(vectorized-const-impl-binop or
  :OpLogicalOr)

(vectorized-const-impl-binop band
  :OpBitwiseAnd)

(vectorized-const-impl-binop bor
  :OpBitwiseOr)

(vectorized-const-impl-binop bxor
  :OpBitwiseXor)

(vectorized-const-impl-binop <
  :OpSLessThan :OpULessThan :OpFOrdLessThan)
  
(vectorized-const-impl-binop <=
  :OpSLessThanEqual :OpULessThanEqual :OpFOrdLessThanEqual)

(vectorized-const-impl-binop >=
  :OpSGreaterThanEqual :OpUGreaterThanEqual :OpFGreaterThanEqual)

(vectorized-const-impl-binop >
  :OpSGreaterThan :OpUGreaterThan :OpFGreaterThan)

(vectorized-const-impl-binop =
  :OpIEqual :OpFOrdEqual :OpLogicalEqual)

(vectorized-const-impl-binop not=
  :OpINotEqual :OpFOrdNotEqual :OpLogicalNotEqual)


(fn Node.aux.constant-impl-min [_ ty lhs rhs]
  (Node.constant ty
    (if (= (type lhs.constant) :table) ; both are already of the correct type so must match.
        (icollect [i l (ipairs lhs.constant)]
          (math.min l (. rhs.constant i)))
        (math.min lhs.constant rhs.constant))))

(fn Node.aux.constant-impl-min [_ ty lhs rhs]
  (Node.constant ty
    (if (= (type lhs.constant) :table) ; both are already of the correct type so must match.
        (icollect [i l (ipairs lhs.constant)]
          (math.max l (. rhs.constant i)))
        (math.max lhs.constant rhs.constant))))

(set Node.constant-impl.GLSLFMin Node.aux.constant-impl-min)
(set Node.constant-impl.GLSLSMin Node.aux.constant-impl-min)
(set Node.constant-impl.GLSLUMin Node.aux.constant-impl-min)
(set Node.constant-impl.GLSLFMax Node.aux.constant-impl-max)
(set Node.constant-impl.GLSLSMax Node.aux.constant-impl-max)
(set Node.constant-impl.GLSLUMax Node.aux.constant-impl-max)

(fn Node.constant-impl.GLSLFma [_ type v0 v1 v2]
  (+ (* v0 v1) v2))

;
; Spec constant ops supported by Shader capability.
; Some listed in the spec are handled elsewhere as they do not have trivial (all id) operands.
;

(local spec-constant-shader-ops
  [ :OpSConvert :OpUConvert :OpFConvert
    :OpSNegate :OpNot
    :OpIAdd :OpISub :OpIMul :OpUDiv :OpSDiv
    :OpUMod :OpSRem :OpSMod
    :OpShiftRightLogical :OpShiftRightArithmetic :OpShiftLeftLogical
    :OpBitwiseOr :OpBitwiseXor :OpBitwiseAnd
    :OpLogicalOr :OpLogicalAnd :OpLogicalNot
    :OpLogicalEqual :OpLogicalNotEqual
    :OpSelect
    :OpIEqual :OpINotEqual
    :OpULessThan :OpSLessThan
    :OpUGreaterThan :OpSGreaterThan
    :OpULessThanEqual :OpSLessThanEqual
    :OpUGreaterThanEqual :OpSGreaterThanEqual
    :OpQuantizeToF16
  ])

(each [_ op (ipairs spec-constant-shader-ops)]
  (tset Node.spec-constant-impl op Node.aux.make-spec-constant-op-internal))

;
; Binary arithmetic operations
;

(set Node.neg
  (node-simple-unop { :name :negate :sint :OpSNegate :uint :OpSNegate :float :OpFNegate }))

(set Node.add
  (node-simple-binop { :name :add :sint :OpIAdd :uint :OpIAdd :float :OpFAdd }))

(set Node.sub
  (node-simple-binop { :name :subtract :sint :OpISub :uint :OpISub :float :OpFSub }))

(set Node.aux.mul
  (node-simple-binop { :name :multiply :sint :OpIMul :uint :OpIMul :float :OpFMul }))

(set Node.div
  (node-simple-binop { :name :divide :sint :OpSDiv :uint :OpUDiv :float :OpFDiv }))

(set Node.mod
  (node-simple-binop { :name :modulate :sint :OpSMod :uint :OpUMod :float :OpFMod }))

(set Node.lsl
  (node-simple-binop { :name "logical shift left" :sint :OpShiftLeftLogical :uint :OpShiftLeftLogical }))

(set Node.lsr
  (node-simple-binop { :name "logical shift right" :sint :OpShiftRightLogical :uint :OpShiftRightLogical }))

(set Node.asr
  (node-simple-binop { :name "arithmetic shift right" :sint :OpShiftRightArithmetic :uint :OpShiftRightArithmetic }))

(set Node.rshift
  (node-simple-binop { :name "shift right" :sint :OpShiftRightArithmetic :uint :OpShiftRightLogical }))

(set Node.band
  (node-simple-binop { :name "binary and" :sint :OpBitwiseAnd :uint :OpBitwiseAnd }))
  
(set Node.bor
  (node-simple-binop { :name "binary or" :sint :OpBitwiseOr :uint :OpBitwiseOr }))
  
(set Node.bxor
  (node-simple-binop { :name "binary exclusive or" :sint :OpBitwiseXor :uint :OpBitwiseXor }))
  

(set Node.lt?
  (node-compare-binop { :sint :OpSLessThan :uint :OpULessThan :float :OpFOrdLessThan }))

(set Node.gt?
  (node-compare-binop { :sint :OpSGreaterThan :uint :OpUGreaterThan :float :OpFOrdGreaterThan }))

(set Node.eq?
  (node-compare-binop { :sint :OpIEqual :uint :OpIEqual :float :OpFOrdEqual :bool :OpLogicalEqual }))

(set Node.neq?
  (node-compare-binop { :sint :OpINotEqual :uint :OpINotEqual :float :OpFOrdNotEqual :bool :OpLogicalNotEqual }))

(set Node.lte?
  (node-compare-binop { :sint :OpSLessThanEqual :uint :OpULessThanEqual :float :OpFOrdLessThanEqual }))

(set Node.gte?
  (node-compare-binop { :sint :OpSGreaterThanEqual :uint :OpUGreaterThanEqual :float :OpFOrdGreaterThanEqual }))


(set Node.bnot
  (node-simple-unop { :name "binary not" :sint :OpNot :uint :OpNot }))

(set Node.breverse
  (node-simple-unop { :name "binary reverse" :sint :OpBitReverse :uint :OpBitReverse }))

(set Node.bcount
  (node-simple-unop { :name "bit count" :sint :OpBitCount :uint :OpBitCount }))


; TODO: bitfield insert/extract


(set Node.infinite?
  (node-compare-unop { :name "check infiniteness" :float :OpIsInf }))

(set Node.nan?
  (node-compare-unop { :name "check for NaN" :float :OpIsNan }))

(set Node.unordered
  { :lt? (node-compare-binop { :float :OpFUnordLessThan })
    :gt? (node-compare-binop { :float :OpFUnordGreaterThan })
    :eq? (node-compare-binop { :float :OpFUnordEqual })
    :neq? (node-compare-binop { :float :OpFUnordNotEqual })
    :lte? (node-compare-binop { :float :OpFUnordLessThanEqual })
    :gte? (node-compare-binop { :float :OpFUnordGreaterThanEqual })
  })


(set Node.!
  (node-simple-unop { :name "logical not" :bool :OpLogicalNot }))

(set Node.aux.|
  (node-simple-binop { :name "take disjunction of" :bool :OpLogicalOr }))
  
(set Node.aux.&
  (node-simple-binop { :name "take conjunction of" :bool :OpLogicalAnd }))

(fn Node.| [...]
  (local bool (Type.bool))
  (case ...
    nil (Node.constant bool false)
    (a nil) a
    (a b nil) (Node.aux.| a b)
    a (Node.aux.| a (Node.| (select 2 ...)))))
    
(fn Node.& [...]
  (local bool (Type.bool))
  (case ...
    nil (Node.constant bool true)
    (a nil) a
    (a b nil) (Node.aux.& a b)
    a (Node.aux.& a (Node.& (select 2 ...)))))


(fn Node.mul [lhs rhs]
  (local lhs (Node.aux.autoderef lhs))
  (local rhs (Node.aux.autoderef rhs))
  
  (local lhs (if (node? lhs) lhs ((rhs.type:prim-elem) lhs)))
  (local rhs (if (node? rhs) rhs ((lhs.type:prim-elem) rhs)))

  (local (lt rt) (values lhs.type rhs.type))

  (case (values lt rt)
    ({:kind :matrix} {:kind :matrix})
      (do (assert (and (= lt.elem.kind rt.elem.kind :float) (= lt.elem rt.elem))
                  (.. "Cannot multiply matrix * matrix of type: " lt.summary rt.summary))
          (assert (= lt.cols rt.rows)
                  (.. "Cannot multiply matrix * matrix of size: " lt.summary rt.summary))
          (Node.aux.op 
            :OpMatrixTimesMatrix
            (Type.matrix lt.elem lt.rows rt.cols)
            lhs rhs))

    ({:kind :vector} {:kind :matrix})
      (do (assert (and (= lt.elem.kind rt.elem.kind :float) (= lt.elem rt.elem))
                  (.. "Cannot multiply vector * matrix of type: " lt.summary rt.summary))
          (assert (= lt.count rt.rows)
                  (.. "Cannot multiply vector * matrix of size: " lt.summary rt.summary))
          (Node.aux.op
            :OpVectorTimesMatrix
            (Type.vector lt.elem rt.cols)
            lhs rhs))

    ({:kind :matrix} {:kind :vector})
      (do (assert (and (= lt.elem.kind rt.elem.kind :float) (= lt.elem rt.elem))
                  (.. "Cannot multiply matrix * vector of type: " lt.summary rt.summary))
          (assert (= lt.cols rt.count)
                  (.. "Cannot multiply matrix * vector of size: " lt.summary rt.summary))
          (Node.aux.op
            :OpMatrixTimesVector
            (Type.vector lt.elem lt.rows)
            lhs rhs))

    (where ({:kind :matrix} {:kind k}) (or (= k :int) (= k :float)))
      (do (assert (= lt.elem.kind :float)
                  (.. "Cannot multiply matrix * scalar of type: " lt.summary rt.summary))
          (Node.aux.op
            :OpMatrixTimesScalar
            lt
            lhs (Node.convert rhs lt.elem)))

    (where ({:kind k} {:kind :matrix}) (or (= k :int) (= k :float)))
      (do (assert (= rt.elem.kind :float)
                  (.. "Cannot multiply scalar * matrix of type: " lt.summary rt.summary))
          (Node.aux.op
            :OpMatrixTimesScalar
            rt
            rhs (Node.convert lhs rt.elem)))

    (where ({:kind :vector :elem {:kind vk}} {:kind k}) (or (= k :float) (and (= k :int) (= vk :float))))
      (do (local out-elem (Type.prim-common-supertype lt.elem rt))
          (local out-vec (Type.vector out-elem lt.count))
          (Node.aux.op
            :OpVectorTimesScalar
            out-vec
            (Node.convert lhs out-vec) (Node.convert rhs out-elem)))
    
    (where ({:kind k} {:kind :vector :elem {:kind vk}}) (or (= k :float) (and (= k :int) (= vk :float))))
      (do (local out-elem (Type.prim-common-supertype lt rt.elem))
          (local out-vec (Type.vector out-elem rt.count))
          (Node.aux.op
            :OpVectorTimesScalar
            out-vec
            (Node.convert rhs out-vec) (Node.convert lhs out-elem)))

    _ (Node.aux.mul lhs rhs)
  ))


(fn Node.dot [lhs rhs]
  (local lhs (Node.aux.autoderef lhs))
  (local rhs (Node.aux.autoderef rhs))
  
  (assert (and (node? lhs) (node? rhs)) "Dot product arguments must be vectors.")

  ; TODO: expose packed dot products, OpSUDot and Op{S,U,SU}DotAccSat via another function with options
  (local out-type (Type.prim-common-supertype lhs.type rhs.type))

  (local (out-prim out-count) (out-type:prim-count))

  (if (= out-count 1)
    (Node.aux.mul (out-prim lhs) (out-prim rhs)) ; might as well allow this for more generic code
    (do 
      (local opcode 
        (case out-prim
          {:kind :float} :OpDot
          {:kind :int :signed true} :OpSDot
          {:kind :int :signed false} :OpUDot
          _ (error (.. "Cannot take dot product of value with type: " out-prim.summary))))
      (Node.aux.op
        opcode out-prim (out-type lhs) (out-type rhs)))))


(fn Node.d/dx [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:prim-count))
  (local out-type (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpDPdx out-type (out-type value)))

(fn Node.d/dy [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:prim-count))
  (local out-type (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpDPdy out-type (out-type value)))

(fn Node.fwidth [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:prim-count))
  (local out-type (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpFwidth out-type (out-type value)))


;
; Image operations
; 

(fn Node.sampled-with [image sampler]
  (local image (Node.aux.autoderef image))
  (local sampler (Node.aux.autoderef sampler))
  (assert (= sampler.type.kind :sampler)
    (.. "Cannot sample image with non-sampler, got: " (tostring sampler)))
  (Node.aux.op :OpSampledImage (Type.sampled image.type) image sampler))


(local bool (Type.bool))
(local u32 (Type.int 32 false))
(local f32 (Type.float 32))
(local i32 (Type.int 32 true))
(local const-offsets-type (Type.array (Type.vector i32 2) 4))

(local image-coord-dims
  { :1D 1
    :2D 2
    :3D 3
    :Cube 3
    :Buffer 1
    :SubpassData 2 ; but must be constant [0, 0]
    ; other types are not allowed or cannot be sampled
  })

(local image-op-coord-type
  { :Sample f32
    :Fetch u32
    :Gather f32
    :Write u32
  })


(fn Node.aux.image-coord [image-type image-op coord ?proj]
  (local coord (Node.aux.autoderef coord))

  (local base-coord-count (. image-coord-dims image-type.dim.tag))
  (local (default-coord-prim req-coord-count)
    (values (. image-op-coord-type image-op)
            (+ base-coord-count (if (or image-type.array ?proj) 1 0))))

  (local coord-prim (if (node? coord) (coord.type:prim-count) default-coord-prim))

  (local result-prim (if (= coord-prim.kind default-coord-prim.kind) coord-prim default-coord-prim))
  (local coord-type (Type.vector result-prim req-coord-count))
  (coord-type coord))


(fn Node.query-image-size [image]
  (local image (Node.image image))
  (local image-type image.type)
  (local coords (. image-coord-dims image-type.dim.tag))
  (local result-type (Type.vector u32 coords))
  (Node.aux.op :OpImageQuerySize result-type image))


(fn Node.query-image-size-lod [image lod]
  (local image (Node.image image))
  (local image-type image.type)
  (local coords (. image-coord-dims image-type.dim.tag))
  (local result-type (Type.vector u32 coords))
  (Node.aux.op :OpImageQuerySizeLod result-type image (u32 lod)))
  

(fn Node.query-image-lod [image coord]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :sampled-image) (.. "Cannot query lod from non-sampled image type: " image.type.summary))
  (local image-type image.type.image)
  (local coord (Node.aux.image-coord image-type :Sample coord))
  (Node.aux.op :OpImageQueryLod (Type.vector f32 2) image coord))


(fn Node.query-image-levels [image]
  (local image (Node.image image))
  (local image-type image.type)
  (Node.aux.op :OpImageQueryLevels u32 image))


(fn Node.query-image-samples [image]
  (local image (Node.image image))
  (local image-type image.type)
  (Node.aux.op :OpImageQuerySamples u32 image))
 

; utility to help make all the various instructions appear more uniform
(fn Node.aux.collect-image-operands [...]
  (local image-op-properties {})
  (local image-operands-list [])
  (fn go [...]
    (local (consumed new-value)
      (case ...
        (where v (= (enum? v) :ImageOperands)) (values 1 v)
        (:Bias v) (values 2 (ImageOperands.Bias v))
        (:Lod v) (values 2 (ImageOperands.Lod v))
        (:Grad dx dy) (values 3 (ImageOperands.Grad dx dy))
        (:ConstOffset o) (values 2 (ImageOperands.ConstOffset o))
        (:Offset o) (values 2 (ImageOperands.Offset o))
        (:ConstOffsets o) (values 2 (ImageOperands.ConstOffsets o))
        (:Sample s) (values 2 (ImageOperands.Sample s))
        (:MinLod lod) (values 2 (ImageOperands.MinLod lod))
        (:MakeTexelAvailable scope) (values 2 (ImageOperands.MakeTexelAvailable scope))
        (:MakeTexelVisible scope) (values 2 (ImageOperands.MakeTexelVisible scope))
        :NonPrivateTexel (values 1 ImageOperands.NonPrivateTexel)
        :VolatileTexel (values 1 ImageOperands.VolatileTexel)
        :SignExtend (values 1 ImageOperands.SignExtend)
        :ZeroExtend (values 1 ImageOperands.ZeroExtend)
        :Nontemporal (values 1 ImageOperands.Nontemporal)

        :Sparse (do (set image-op-properties.Sparse true) 1)
        :Proj (do (set image-op-properties.Proj true) 1)
        (:Dref d) (do (set image-op-properties.Dref d) 2)
      ))
    (when (not= nil new-value)
      (table.insert image-operands-list new-value))
    (if (not= nil consumed)
      (go (select (+ consumed 1) ...))))

  (go ...)

  (local image-operands
    (if (not= 0 (# image-operands-list))
      (ImageOperands (table.unpack image-operands-list))))
  (values image-op-properties image-operands))

(fn Node.aux.reify-image-operands [ctx ops]
  (base.map-operands ops (fn [arg desc]
    (if (node? arg) (ctx:node-id arg)
        (enum? arg) arg))))

(fn node-reify-image-op [self ctx]
  (local tid (ctx:type-id self.type))
  (local arg-ids
    (icollect [_ arg (ipairs self.operands)]
      (if (enum? arg) (Node.aux.reify-image-operands ctx arg)
          (node? arg) (ctx:node-id arg))))
  (local id (ctx:fresh-id))
  (local op ((. Op self.operation) tid id (table.unpack arg-ids)))
  (ctx:instruction op)
  id)


(local image-format-component-count
  {
    ; rgba
    :Rgba32f 4
    :Rgba16f 4
    :Rgba16 4
    :Rgba16Snorm 4
    :Rgb10A2 4
    :Rgba8 4
    :Rgba8Snorm 4
    :Rgba32i 4
    :Rgba16i 4
    :Rgba8i 4
    :Rgba32ui 4
    :Rgba16ui 4
    :Rgb10a2ui 4
    :Rgba8ui 4
    
    ; rgb
    :R11fG11fB10f 3

    ; rg
    :Rg32f 2
    :Rg16f 2
    :Rg16 2
    :Rg16Snorm 2
    :Rg8 2
    :Rg8Snorm 2
    :Rg32i 2
    :Rg16i 2
    :Rg8i 2
    :Rg32ui 2
    :Rg16ui 2
    :Rg8ui 2

    ; r
    :R32f 1
    :R16f 1
    :R16 1
    :R16Snorm 1
    :R8 1
    :R8Snorm 1
    :R32i 1
    :R16i 1
    :R8i 1
    :R32ui 1
    :R16ui 1
    :R8ui 1
    :R64i 1
    :R64ui 1
  })

(fn Node.aux.image-write [ctx image coord texel ...]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :image) (.. "Cannot write texel data to non-image type: " image.type.summary))
  (assert (= image.type.usage :storage) (.. "Cannot write texel data to non-storage image: " image.type.summary))
  (local image-type image.type)

  (local (properties image-operands) (Node.aux.collect-image-operands ...))
  
  (assert (not (or properties.Proj (not= nil properties.Dref) properties.Sparse))
          (.. "Invalid additional options :Proj/:Dref/:Sparse specified for image write: " image.type.summary))

  (assert (not (or (?. image-operands :Bias)
                  ;  (and (not sampled-image?) (?. image-operands :Lod))
                   (?. image-operands :Grad)
                   (?. image-operands :ConstOffsets)
                   (?. image-operands :MinLod)
                   (?. image-operands :MakeTexelVisible)))
          (.. "Invalid image operands present for image write: " (tostring image-operands) " " image.type.summary))
  
  (local coord (Node.aux.image-coord image-type :Write coord))

  (local texel (Node.aux.autoderef texel))
  (assert (node? texel) "Texel value for image write must be a typed node. Try casting to a vector if necessary.")
  (local (texel-prim texel-count) (texel.type:prim-count))

  (when (not= image-type.format.tag :Unknown)
    (assert (>= texel-count (. image-format-component-count image-type.format.tag))
            (.. "Input texel has too few components for image format: " texel.type.summary image-type.format.tag)))

  (local texel-final-type (Type.vector image-type.elem texel-count))
  (local texel (texel-final-type texel))

  (local base-coord-count (. image-coord-dims image-type.dim.tag))
  (local base-vec-i32 (Type.vector i32 base-coord-count))
  (local image-operands
    (if image-operands (base.map-operands image-operands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (base-vec-i32 arg)
        :Offset (base-vec-i32 arg)
        :Sample (u32 arg)
      )))))

  (local op
    (Op.OpImageWrite
      (ctx:node-id image) (ctx:node-id coord) (ctx:node-id texel)
      (if image-operands (Node.aux.reify-image-operands ctx image-operands))))

  (ctx:instruction op))

(fn Node.sample [image coord ...]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :sampled-image) (.. "Cannot sample from non-sampled image type: " image.type.summary))
  (local image-type image.type.image)

  (local (properties image-operands) (Node.aux.collect-image-operands ...))
  (assert (not (and properties.Proj image-type.array))
          (.. "Cannot use Projective sampling on an Array image: " image.type.summary))
  
  (local coord (Node.aux.image-coord image-type :Sample coord properties.Proj))

  (local explicit-lod?
    (or (?. image-operands :Lod) (?. image-operands :Grad)))
  
  (assert (not (or (and explicit-lod? (?. image-operands :Bias))
                   (and (?. image-operands :Lod) (?. image-operands :Grad))
                   (and (or explicit-lod? (?. image-operands :Lod)) (?. image-operands :MinLod))
                   (?. image-operands :ConstOffsets)
                   (?. image-operands :MakeTexelAvailable)
                   (?. image-operands :MakeTexelVisible)))
          (.. "Invalid image operands present for image sample: " (tostring image-operands)))
  
  (local result-count (if properties.Dref 1 4))
  (var result-type (Type.vector image-type.elem result-count))
  (when properties.Sparse 
    (set result-type (Type.struct [i32 result-type] [:0 :1])))

  (local dref (if (not= nil properties.Dref) (f32 properties.Dref)))

  (local operands [image coord])
  (when dref (table.insert operands dref))

  (local base-coord-count (. image-coord-dims image-type.dim.tag))
  (local base-vec-f32 (Type.vector f32 base-coord-count))
  (local base-vec-i32 (Type.vector i32 base-coord-count))
  (local image-operands
    (if image-operands (base.map-operands image-operands (fn [arg desc tag]
      (case tag
        :Lod (f32 arg)
        :Grad (base-vec-f32 arg)
        :ConstOffset (base-vec-i32 arg)
        :Offset (base-vec-i32 arg)
        :ConstOffsets (const-offsets-type arg)
        :Sample (u32 arg)
        :MinLod (f32 arg)
      )))))

  (when image-operands
    (table.insert operands image-operands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      "Sample"
      (if properties.Proj :Proj "")
      (if (not= nil properties.Dref) :Dref "")
      (if explicit-lod?
        :ExplicitLod :ImplicitLod)))

  (Node.new
    { :kind :expr
      :type result-type
      :operation opcode
      :operands operands
      :reify node-reify-image-op
    }))


(fn Node.gather [image coord component? ...]
  (local image (Node.aux.autoderef image)) ; allow fetch on sampled images by extracting image from combined object
  (assert (= image.type.kind :sampled-image) (.. "Cannot gather from non-sampled image type: " image.type.summary))
  (local image-type image.type.image)

  (local coord (Node.aux.image-coord image-type :Gather coord))
  
  (local (properties image-operands) 
    (if (not= :string (type component?))
      (Node.aux.collect-image-operands ...)
      (Node.aux.collect-image-operands component? ...)))

  (local component? (if (not= :string (type component?)) component?))

  (assert (not properties.Proj)
          (.. "Cannot use Projective coordinates in image gather: " image-type.summary))

  (assert (not (or (?. image-operands :Bias)
                  ;  (?. image-operands :Lod)
                   (?. image-operands :Grad)
                   (?. image-operands :MinLod)
                   (?. image-operands :MakeTexelAvailable)
                   (?. image-operands :MakeTexelVisible)))
          (.. "Invalid image operands present for image gather: " (tostring image-operands)))

  (var result-type (Type.vector image-type.elem 4))
  (when properties.Sparse 
    (set result-type (Type.struct [i32 result-type] [:0 :1])))

  (local base-coord-count (. image-coord-dims image-type.dim.tag))
  (local base-vec-i32 (Type.vector i32 base-coord-count))
  (local image-operands
    (if image-operands (base.map-operands image-operands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (base-vec-i32 arg)
        :ConstOffsets (const-offsets-type arg)
        :Offset (base-vec-i32 arg)
        :Sample (u32 arg)
      )))))

  (assert (not (and (not= nil properties.Dref) component?))
          "Image gather operation must either use :Dref or provide component index, but not both")

  (local dref-or-component 
    (if (not= nil properties.Dref) (f32 properties.Dref)
        component? (u32 component?)
        (u32 0)))

  (local operands [image coord dref-or-component])
  (when image-operands
    (table.insert operands image-operands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      (if (not= nil properties.Dref) :Dref "")
      "Gather"))

  (Node.new
    { :kind :expr
      :type result-type
      :operation opcode
      :operands operands
      :reify node-reify-image-op
    }))


(fn Node.image [maybe-sampled-image]
  (local maybe-sampled-image (Node.aux.autoderef maybe-sampled-image))
  (case maybe-sampled-image.type.kind
    :image maybe-sampled-image
    :sampled-image (Node.aux.op :OpImage maybe-sampled-image.type.image maybe-sampled-image)
    other (error (.. "Cannot extract image from non-(sampled-)image argument: " maybe-sampled-image.type.summary))))


(fn Node.fetch [image coord ...]
  (local image (Node.image image)) ; allow fetch on sampled images by extracting image from combined object
  (local image-type image.type)
  (local sampled-image? (= image-type.usage :texture))

  (assert (not (and sampled-image? (= image-type.dim.tag :Cube)))
    (.. "Cannot fetch from cube image: " image.type.summary))

  (local coord (Node.aux.image-coord image-type :Fetch coord))
  
  (local (properties image-operands) (Node.aux.collect-image-operands ...))
  (assert (not (or properties.Proj properties.Dref))
          (.. "Cannot use Projective or Depth in image fetch/read: " image.type.summary))

  (assert (not (or (?. image-operands :Bias)
                   (and (not sampled-image?) (?. image-operands :Lod))
                   (?. image-operands :Grad)
                   (?. image-operands :ConstOffsets)
                   (?. image-operands :MinLod)
                   (?. image-operands :MakeTexelAvailable)
                   (and sampled-image? (?. image-operands :MakeTexelVisible))))
          (.. "Invalid image operands present for image fetch/read: " (tostring image-operands) " " image.type.summary))
  
  (var result-type (Type.vector image-type.elem 4))
  (when properties.Sparse 
    (set result-type (Type.struct [i32 result-type] [:0 :1])))

  (local base-coord-count (. image-coord-dims image-type.dim.tag))
  (local base-vec-i32 (Type.vector i32 base-coord-count))
  (local image-operands
    (if image-operands (base.map-operands image-operands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (base-vec-i32 arg)
        :Offset (base-vec-i32 arg)
        :Sample (u32 arg)
      )))))

  (local operands [image coord])
  (when image-operands
    (table.insert operands image-operands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      (if sampled-image? "Fetch" "Read")))

  (Node.new
    { :kind :expr
      :type result-type
      :operation opcode
      :operands operands
      :reify node-reify-image-op
    }))

;
; Subgroup operations
;

(local uvec4 (Type.vector u32 4))
(local SubgroupScope (u32 3))

(set Node.subgroup {})

(fn Node.subgroup.elect []
  (Node.aux.op :OpGroupNonUniformElect bool SubgroupScope))

(fn Node.subgroup.ballot [value]
  (Node.aux.op :OpGroupNonUniformBallot uvec4 SubgroupScope (bool value)))

(fn Node.subgroup.inverse-ballot [value]
  (Node.aux.op :OpGroupNonUniformInverseBallot bool SubgroupScope (uvec4 value)))

(fn Node.subgroup.inverse-ballot-at-index [value index]
  (Node.aux.op :OpGroupNonUniformBallotBitExtract bool SubgroupScope (uvec4 value) (u32 index)))
  
(fn Node.subgroup.ballot-bit-count [value]
  (Node.aux.op :OpGroupNonUniformBallotBitCount u32 SubgroupScope (uvec4 value)))
  
(fn Node.subgroup.ballot-lsb [value]
  (Node.aux.op :OpGroupNonUniformBallotFindLSB u32 SubgroupScope (uvec4 value)))
  
(fn Node.subgroup.ballot-msb [value]
  (Node.aux.op :OpGroupNonUniformBallotFindMSB u32 SubgroupScope (uvec4 value)))

(fn Node.subgroup.broadcast [value index]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.broadcast-quad [value index]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformQuadBroadcast value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.broadcast-first [value]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcastFirst value.type SubgroupScope value))

(fn Node.subgroup.swap-quad [value direction]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (local index
    (case direction
      :Horizontal 0
      :Vertical 1
      :Diagonal 2
      _ (error (.. "Quad swap direction must be one of :Horizontal/:Vertical/:Diagonal, got: " direction))))
  (Node.aux.op :OpGroupNonUniformQuadSwap value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.shuffle [value index]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformShuffle value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.shuffle-xor [value mask]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 mask)))

(fn Node.subgroup.shuffle-up [value delta]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 delta)))
  
(fn Node.subgroup.shuffle-down [value delta]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 delta)))

(fn node-subgroup-op [{ :name name :sint sint-op :uint uint-op :float float-op :bool bool-op }]
  (fn [value ?group-op ?cluster]
    (local value (Node.aux.autoderef value))
    (local (prim count) (value.type:prim-count))
    (local opcode
      (case prim
        {:kind :int : signed} (if signed sint-op uint-op)
        {:kind :float} float-op
        {:kind :bool} bool-op
        _ (error (.. "Cannot " name " values (within subgroup) of type: " value.type.summary))))
    (local group-op
      (if 
        (= nil ?group-op) GroupOperation.Reduce
        (= (enum? ?group-op) :GroupOperation) ?group-op
        (= (type ?group-op) :string) (. GroupOperation ?group-op)
        (error (.. "Unrecognized group operation: " (tostring ?group-op)))))
    (local cluster
      (case group-op.tag
        :ClusteredReduce
          (do (assert ?cluster "Cluster size required for ClusteredReduce subgroup operation.")
              (local ?cluster (u32 ?cluster))
              (assert (or (= ?cluster.kind :constant) (= ?cluster.kind :spec-constant))
                (.. "Cluster size argument must be constant, got: " (tostring ?cluster)))
              ?cluster)
        (where (or :PartitionedReduceNV :PartitionedInclusiveScanNV :PartitionedExclusiveScanNV))
          (do (assert ?cluster "Partition required for PartitionedNV subgroup operation.")
              (uvec4 ?cluster))))
    
    (Node.aux.op opcode value.type SubgroupScope group-op value cluster)))


(set Node.subgroup.add
  (node-subgroup-op { :name "add" :sint :OpGroupNonUniformIAdd :uint :OpGroupNonUniformIAdd :float :OpGroupNonUniformFAdd }))

(set Node.subgroup.mul
  (node-subgroup-op { :name "multiply" :sint :OpGroupNonUniformIMul :uint :OpGroupNonUniformIMul :float :OpGroupNonUniformFMul }))

(set Node.subgroup.min
  (node-subgroup-op { :name "find minimum" :sint :OpGroupNonUniformSMin :uint :OpGroupNonUniformUMin :float :OpGroupNonUniformFMin }))
  
(set Node.subgroup.max
  (node-subgroup-op { :name "find maximum" :sint :OpGroupNonUniformSMax :uint :OpGroupNonUniformUMax :float :OpGroupNonUniformFMax }))

(set Node.subgroup.band
  (node-subgroup-op { :name "bitwise and" :sint :OpGroupNonUniformBitwiseAnd :uint :OpGroupNonUniformBitwiseAnd }))
  
(set Node.subgroup.bor
  (node-subgroup-op { :name "bitwise or" :sint :OpGroupNonUniformBitwiseOr :uint :OpGroupNonUniformBitwiseOr }))
  
(set Node.subgroup.bxor
  (node-subgroup-op { :name "bitwise xor" :sint :OpGroupNonUniformBitwiseXor :uint :OpGroupNonUniformBitwiseXor }))
  
(set Node.subgroup.and
  (node-subgroup-op { :name "logical and" :bool :OpGroupNonUniformLogicalAnd }))
  
(set Node.subgroup.or
  (node-subgroup-op { :name "logical or" :bool :OpGroupNonUniformLogicalAnd }))
  
(set Node.subgroup.xor
  (node-subgroup-op { :name "logical xor" :bool :OpGroupNonUniformLogicalAnd }))


(fn Node.subgroup.all? [value]
  (Node.aux.op :OpSubgroupAllKHR bool (bool value)))

(fn Node.subgroup.any? [value]
  (Node.aux.op :OpSubgroupAnyKHR bool (bool value)))

(fn Node.subgroup.eq? [value]
  (Node.aux.op :OpSubgroupAllEqualKHR bool (bool value)))

(fn Node.subgroup.partition-nv [value]
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot partition non-vector non-scalar value, got: " value.type.summary)))

  (Node.aux.op :OpGroupNonUniformPartitionNV uvec4 value))

(fn Node.subgroup.rotate [value delta ?cluster]
  (local value (Node.aux.autoderef value))
  (local delta (Node.aux.autoderef value))
  
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot rotate non-vector non-scalar value, got: " value.type.summary)))

  (local delta (u32 delta))
  (local cluster (if ?cluster (u32 ?cluster)))

  (when cluster
    (assert (or (= cluster.kind :constant) (= cluster.kind :spec-constant))
      (.. "Rotation clustering argument must be constant, got: " cluster)))

  (Node.aux.op :OpGroupNonUniformRotateKHR value.type SubgroupScope value delta cluster))


;
; Atomics
;

(set Node.atomic {})

(fn Node.aux.validate-atomic-elem [type]
  (assert (or (= type.kind :int) (= type.kind :float))
    (.. "Atomically accessed value must be scalar integer or float, got: " type.summary)))
    
(fn Node.aux.validate-atomic-elem-int [type]
  (assert (= type.kind :int))
    (.. "Atomically accessed value must be scalar integer, got: " type.summary))

(fn Node.aux.atomic-scope-value [scope]
  (local scope (if (enum? scope) scope.value (. Scope scope :value)))
  (u32 scope))

(fn Node.aux.atomic-memory-semantics-value [memory-semantics]
  (assert (= (enum? memory-semantics) :MemorySemantics)
    (.. "Expected MemorySemantics value, got: " (tostring memory-semantics)))
  (u32 memory-semantics.value))

(fn Node.atomic.load [ptr scope memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
  (Node.aux.op :OpAtomicLoad ptr.type.elem ptr scope memory-semantics))
  
(fn Node.aux.atomic-store [ctx ptr value scope memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
  (ctx:instruction
    (Op.OpAtomicStore
      (ctx:node-id ptr)
      (ctx:node-id scope)
      (ctx:node-id memory-semantics)
      (ctx:node-id (ptr.type.elem value)))))

(fn Node.atomic.swap [ptr value scope memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
  (Node.aux.op :OpAtomicExchange ptr.type.elem ptr scope memory-semantics (ptr.type.elem value)))

(fn Node.atomic.compare-swap [ptr value compare-value scope eq-memory-semantics uneq-memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local eq-memory-semantics (Node.aux.atomic-memory-semantics-value eq-memory-semantics))
  (local uneq-memory-semantics (Node.aux.atomic-memory-semantics-value uneq-memory-semantics))
  (Node.aux.op :OpAtomicCompareExchange ptr.type.elem ptr scope eq-memory-semantics uneq-memory-semantics (ptr.type.elem value) (ptr.type.elem compare-value)))

(fn Node.atomic.increment [ptr scope memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem-int ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
  (Node.aux.op :OpAtomicIIncrement ptr.type.elem ptr scope memory-semantics))
  
(fn Node.atomic.decrement [ptr scope memory-semantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validate-atomic-elem-int ptr.type.elem)
  (local scope (Node.aux.atomic-scope-value scope))
  (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
  (Node.aux.op :OpAtomicIDecrement ptr.type.elem ptr scope memory-semantics))

(fn node-atomic-binop [{ :name name :sint sint-op :uint uint-op :float float-op }]
  (fn [ptr value scope memory-semantics]
    (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
    (Node.aux.validate-atomic-elem ptr.type.elem)
    (local scope (Node.aux.atomic-scope-value scope))
    (local memory-semantics (Node.aux.atomic-memory-semantics-value memory-semantics))
    (local opcode
      (case ptr.type.elem
        {:kind :int : signed} (if signed sint-op uint-op)
        {:kind :float} float-op
        _ (error (.. "Cannot atomically " name " values of type: " ptr.type.elem.summary))))
    (Node.aux.op opcode ptr.type.elem ptr scope memory-semantics (ptr.type.elem value))))

(set Node.atomic.add
  (node-atomic-binop { :name "add" :sint :OpAtomicIAdd :uint :OpAtomicIAdd :float :OpAtomicFAddEXT }))

(set Node.aux.atomic-sub
  (node-atomic-binop { :name "subtract" :sint :OpAtomicISub :uint :OpAtomicISub }))

(fn Node.atomic.sub [ptr value scope memory-semantics]
  (case (?. ptr :type :elem :kind)
    :float (Node.atomic.add [ptr (- (ptr.type.elem value)) scope memory-semantics])
    _ (Node.aux.atomic-sub ptr value scope memory-semantics)))
  
(set Node.atomic.min
  (node-atomic-binop { :name "take minimum" :sint :OpAtomicSMin :uint :OpAtomicUMin :float :OpAtomicFMinEXT }))

(set Node.atomic.max
  (node-atomic-binop { :name "take maximum" :sint :OpAtomicSMax :uint :OpAtomicUMax :float :OpAtomicFMaxEXT }))

(set Node.atomic.band
  (node-atomic-binop { :name "binary and" :sint :OpAtomicAnd :uint :OpAtomicAnd }))
  
(set Node.atomic.bor
  (node-atomic-binop { :name "binary or" :sint :OpAtomicOr :uint :OpAtomicOr }))
  
(set Node.atomic.bxor
  (node-atomic-binop { :name "binary xor" :sint :OpAtomicXor :uint :OpAtomicXor }))

;
; Primitive Emitters
;

(fn Node.aux.emit-vertex [ctx]
  (ctx:instruction Op.OpEmitVertex))

(fn Node.aux.end-primitive [ctx]
  (ctx:instruction Op.OpEndPrimitive))

(fn Node.aux.emit-stream-vertex [ctx id]
  (local id (ctx:node-id (u32 id)))
  (ctx:instruction (Op.OpEmitStreamVertex id)))

(fn Node.aux.end-stream-primitive [ctx id]
  (local id (ctx:node-id (u32 id)))
  (ctx:instruction (Op.OpEndStreamPrimitive id)))

;
; Barriers
; 

(fn Node.aux.control-barrier [ctx execution-scope memory-scope memory-semantics]
  (local execution-scope 
    (if (enum? execution-scope) execution-scope.value
        (= (type execution-scope) :string) (. Scope execution-scope :value)
        execution-scope))
  (local memory-scope 
    (if (enum? memory-scope) memory-scope.value
        (= (type memory-scope) :string) (. Scope memory-scope :value)
        memory-scope))
  (local memory-semantics
    (if (= (enum? memory-semantics) :MemorySemantics) memory-semantics.value-union
        (error "Must provide MemorySemantics flags value explicitly for barrier")))
  (ctx:instruction 
    (Op.OpControlBarrier (ctx:node-id (u32 execution-scope)) 
                         (ctx:node-id (u32 memory-scope))
                         (ctx:node-id (u32 memory-semantics)))))

(fn Node.aux.memory-barrier [ctx memory-scope memory-semantics]
  (local memory-scope 
    (if (enum? memory-scope) memory-scope.value
        (= (type memory-scope) :string (. Scope memory-scope :value)
        memory-scope)))
  (local memory-semantics
    (if (= (enum? memory-semantics) :MemorySemantics) memory-semantics.value-union
        (error "Must provide MemorySemantics flags value explicitly for barrier")))
  (ctx:instruction 
    (Op.OpMemoryBarrier (ctx:node-id (u32 memory-scope)) 
                        (ctx:node-id (u32 memory-semantics)))))


;
; ExtGLSL operations
;

(set Node.pow
  (node-glsl-binop { :name "exponentiate" :float :Pow :no-f64? true }))

(set Node.arctan2
  (node-glsl-binop { :name "compute arctangent" :float :Atan2 :no-f64? true }))

(set Node.aux.max
  (node-glsl-binop { :name "take maximum" :sint :SMax :uint :UMax :float :FMax }))

(set Node.aux.min
  (node-glsl-binop { :name "take minimum" :sint :SMin :uint :UMin :float :FMin }))

(set Node.aux.nmax
  (node-glsl-binop { :name "take maximum (ignoring NaN)" :float :NMax }))

(set Node.aux.nmin
  (node-glsl-binop { :name "take minimum (ignoring NaN)" :float :NMin }))

(set Node.step
  (node-glsl-binop { :name "step function" :float :Step }))

(set Node.distance
  (node-glsl-binop { :name "find distance between" :float :Distance }))

(fn Node.max [a ...]
  (case ...
    nil a
    b (Node.aux.max a (Node.max b (select 2 ...)))))

(fn Node.min [a ...]
  (case ...
    nil a
    b (Node.aux.min a (Node.min b (select 2 ...)))))

(fn Node.nmax [a ...]
  (case ...
    nil a
    b (Node.aux.nmax a (Node.nmax b (select 2 ...)))))

(fn Node.nmin [a ...]
  (case ...
    nil a
    b (Node.aux.nmin a (Node.nmin b (select 2 ...)))))


(set Node.round
  (node-glsl-unop { :name "round" :float :Round }))

(set Node.round-even
  (node-glsl-unop { :name "round to nearest even" :float :RoundEven }))

(set Node.trunc
  (node-glsl-unop { :name "truncate" :float :Trunc }))

(set Node.floor
  (node-glsl-unop { :name "take floor of" :float :Floor }))

(set Node.ceil
  (node-glsl-unop { :name "take ceiling of" :float :Ceil }))

(set Node.fract
  (node-glsl-unop { :name "take fractional part of" :float :Fract }))

(set Node.degrees-to-radians
  (node-glsl-unop { :name "convert degrees to radians" :float :Radians :no-f64? true }))

(set Node.radians-to-degrees
  (node-glsl-unop { :name "convert radians to degrees" :float :Degrees :no-f64? true }))

(set Node.sign
  (node-glsl-unop { :name "find sign of" :sint :SSign :float :FSign }))
  
(set Node.abs
  (node-glsl-unop { :name "find absolute value of" :sint :SAbs :float :FAbs }))

(set Node.sin
  (node-glsl-unop { :name "compute sine" :float :Sin :no-f64? true }))
  
(set Node.cos
  (node-glsl-unop { :name "compute cosine" :float :Cos :no-f64? true }))
  
(set Node.tan
  (node-glsl-unop { :name "compute tangent" :float :Tan :no-f64? true }))
  
(set Node.arcsin
  (node-glsl-unop { :name "compute arcsine" :float :Asin :no-f64? true }))
  
(set Node.arccos
  (node-glsl-unop { :name "compute arccosine" :float :Acos :no-f64? true }))
  
(set Node.arctan
  (node-glsl-unop { :name "compute arctangent" :float :Atan :no-f64? true }))
  
(set Node.sinh
  (node-glsl-unop { :name "compute hyperbolic sine" :float :Sinh :no-f64? true }))
  
(set Node.cosh
  (node-glsl-unop { :name "compute hyperbolic cosine" :float :Cosh :no-f64? true }))
  
(set Node.tanh
  (node-glsl-unop { :name "compute hyperbolic tangent" :float :Tanh :no-f64? true }))
  
(set Node.arcsinh
  (node-glsl-unop { :name "compute hyperbolic arcsine" :float :Asinh :no-f64? true }))
  
(set Node.arccosh
  (node-glsl-unop { :name "compute hyperbolic arccosine" :float :Acosh :no-f64? true }))
  
(set Node.arctanh
  (node-glsl-unop { :name "compute hyperbolic arctangent" :float :Atanh :no-f64? true }))
  
(set Node.exp
  (node-glsl-unop { :name "exponentiate" :float :Exp :no-f64? true }))

(set Node.exp2
  (node-glsl-unop { :name "exponentiate" :float :Exp2 :no-f64? true }))

(set Node.log
  (node-glsl-unop { :name "find natural logarithm" :float :Log :no-f64? true }))

(set Node.log2
  (node-glsl-unop { :name "find base-2 logarithm" :float :Log2 :no-f64? true }))

(set Node.sqrt
  (node-glsl-unop { :name "find square root" :float :Sqrt }))

(set Node.inverse-sqrt
  (node-glsl-unop { :name "find inverse square root" :float :InverseSqrt }))

(set Node.normalize
  (node-glsl-unop { :name "normalize" :float :Normalize }))

(set Node.lsb
  (node-glsl-unop { :name "find least-significant bit" :sint :FindILsb :uint :FindILsb :no-i64? true }))

(set Node.msb
  (node-glsl-unop { :name "find most-significant bit" :sint :FindSMsb :uint :FindUMsb :no-i64? true }))


(fn Node.select [cond then else]
  (local bool (Type.bool))

  (local cond (Node.aux.autoderef cond))
  (local then (Node.aux.autoderef then))
  (local else (Node.aux.autoderef else))

  (if (and (node? cond) (= :constant cond.kind)) (if cond.constant then else)
    (do 
      (local f32 (Type.float 32))
      (local then-type (if (node? then) then.type f32))
      (local else-type (if (node? else) else.type f32))

      ; FIXME: OpSelect can also work on pointers or composites
      (local out-type
        (Type.prim-common-supertype then-type else-type))

      (local (out-prim out-count) (out-type:prim-count))
      (local cond-type (Type.vector bool out-count))

      (Node.aux.op
        :OpSelect out-type (cond-type cond) (out-type then) (out-type else)))))


(fn Node.smoothstep [v0 v1 vt]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local vt (Node.aux.autoderef vt))
  (if (not (or (node? v0) (node? v1) (node? vt)))
    (do
      (local t (/ (- vt v0) (- v1 v0)))
      (local t (math.min 1 (math.max t 0)))
      (* t t (- 3 (* t 2))))
    (do 
      (local f32 (Type.float 32))
      (local v0 (if (node? v0) v0 (f32 v0)))
      (local v1 (if (node? v1) v1 (f32 v1)))
      (local vt (if (node? vt) vt (f32 vt)))

      (local out-type
        (Type.prim-common-supertype v0.type v1.type vt.type))
      
      (local (out-prim out-count) (out-type:prim-count))
      (assert (= :float out-prim.kind) "Cannot smoothstep non-floating values.")

      (Node.glsl.op
        :SmoothStep out-type (out-type v0) (out-type v1) (out-type vt)))))


(fn Node.mix [v0 v1 vt]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local vt (Node.aux.autoderef vt))
  (if (not (or (node? v0) (node? v1) (node? vt))) (+ v0 (* (- v1 v0) vt))
    (do 
      (local f32 (Type.float 32))
      (local v0 (if (node? v0) v0 (f32 v0)))
      (local v1 (if (node? v1) v1 (f32 v1)))
      (local vt (if (node? vt) vt (f32 vt)))

      (local out-type
        (Type.prim-common-supertype v0.type v1.type vt.type))
      
      (local (out-prim out-count) (out-type:prim-count))
      (assert (= :float out-prim.kind) "Cannot mix non-floating values.")

      (Node.glsl.op
        :FMix out-type (out-type v0) (out-type v1) (out-type vt)))))


(fn Node.fma [v0 v1 v2]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local v2 (Node.aux.autoderef v2))
  (if (not (or (node? v0) (node? v1) (node? v2))) (+ (* v0 v1) v2))
    (do 
      (local f32 (Type.float 32))
      (local v0 (if (node? v0) v0 (f32 v0)))
      (local v1 (if (node? v1) v1 (f32 v1)))
      (local v2 (if (node? v2) v2 (f32 v2)))

      (local out-type
        (Type.prim-common-supertype v0.type v1.type v2.type f32))
      
      (local (out-prim out-count) (out-type:prim-count))

      (Node.glsl.op
        :Fma out-type (out-type v0) (out-type v1) (out-type v2))))


(fn Node.determinant [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot find determinant of non-matrix value.")
  
  (local mat-type mat.type)
  (assert (= mat-type.rows mat-type.cols) (.. "Argument to determinant must be a square matrix, got: " mat.type.summary))
  
  (Node.glsl.op
    :Determinant mat-type.elem mat))


(fn Node.matrix-inverse [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot invert non-matrix value.")
  
  (local mat-type mat.type)
  (assert (= mat-type.rows mat-type.cols) (.. "Matrix to invert must be a square matrix, got: " mat.type.summary))
  
  (Node.glsl.op
    :MatrixInverse mat-type mat))


(fn Node.matrix-transpose [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot invert non-matrix value.")
  
  (local mat-type mat.type)
  (local out-type (Type.matrix mat-type.elem mat-type.cols mat-type.rows))

  (Node.aux.op
    :OpTranspose out-type mat))


(fn Node.modf [value]
  (local value (Node.aux.autoderef value))
  (if (= :number (type value)) (math.modf value)
    (do 
      (local (prim count) (value.type:prim-count))
      (assert (= prim.kind :float) (.. "Argument to modf must be floating, got: " value.type.summary))

      (local out-type (Type.struct [value.type value.type] [:0 :1]))

      (local modf-result
        (Node.glsl.op :ModfStruct out-type value))
      (values
        modf-result.1 modf-result.0)
    )))

;
; 
;

(fn node-reify-returnvalue [self ctx]
  (local id (ctx:node-id (. self.operands 1)))
  (local op (Op.OpReturnValue id))
  (ctx:instruction op)
  id)

(fn Node.returnvalue [node]
  (Node.new
    { :kind :expr
      :type (Type.void)
      :operation :OpReturnValue
      :operands [node]
      :reify node-reify-returnvalue
    }))


(fn node-reify-accesschain [self ctx]
  (local [base indices] self.operands)
  (local tid (ctx:type-id self.type))
  (local base-id (ctx:node-id base))
  (local index-ids (icollect [_ index (ipairs indices)] (ctx:node-id index)))
  (local id (ctx:fresh-id))
  (ctx:instruction ((. Op self.operation) tid id base-id index-ids))
  (when (and (= base.kind :variable) (not= base.storage StorageClass.Function))
    (ctx:interface-id base-id))
  id)

; TODO: Consider using OpInBoundsAccessChain when it is possible to do so
(fn Node.access [base index]
  ; (print :Node.access base index)
  (local index (Node.aux.autoderef index))
  (var result-type (Type.access base.type index))
  (if (and (= base.kind :expr) (= base.operation :OpAccessChain))
      (do (local [base indices] base.operands)
          (local indices (icollect [_ v (ipairs indices)] v))
          (table.insert indices index)
          (Node.access-chain base result-type indices))
    (Node.access-chain base result-type [index])))

(fn Node.access-chain [base type indices]
  (Node.new
    { :kind :expr
      :type type
      :operation :OpAccessChain
      :operands [base indices]
      :reify node-reify-accesschain
    }))


(fn node-reify-extractchain [self ctx]
  (local tid (ctx:type-id self.type))
  (local base-id (ctx:node-id (. self.operands 1)))
  (local indices (. self.operands 2))
  (local id (ctx:fresh-id))
  (ctx:instruction ((. Op self.operation) tid id base-id indices))
  id)

(fn Node.extract [base index]
  (var result-type (Type.extract base.type index))
  (if (= base.kind :constant) (Node.constant result-type (. base.constant (+ index 1)))
      (and (= base.kind :expr) (= base.operation :OpCompositeExtract))
      (do (local [base indices] base.operands)
          (local indices (icollect [_ v (ipairs indices)] v))
          (table.insert indices index)
          (Node.extract-chain base result-type indices))
    (Node.extract-chain base result-type [index])))

(fn Node.extract-chain [base type indices]
  (Node.new
    { :kind :expr
      :type type
      :operation :OpCompositeExtract
      :operands [base indices]
      :reify node-reify-extractchain
    }))


(fn node-reify-extract-dynamic [self ctx]
  (local [base index] self.operands)
  (local tid (ctx:type-id self.type))
  (local base-id (ctx:node-id base))
  (local index-id (ctx:node-id index))
  (local id (ctx:fresh-id))
  (ctx:instruction (Op.OpVectorExtractDynamic tid id base-id index-id))
  id)

; Extract a dynamic index of a vector
(fn Node.extract-dynamic [self index]
  (assert (= index.type.kind :int) (.. "Vector must be indexed by an integer, got: " index.type.summary))
  (Node.new
    { :kind :expr
      :type self.elem
      :operation :OpVectorExtractDynamic
      :operands [self index]
      :reify node-reify-extract-dynamic
    }))


(fn node-reify-shuffle [self ctx]
  (local [vec1 vec2 indices] self.operands)
  (local tid (ctx:type-id self.type))
  (local vec1-id (ctx:node-id vec1))
  (local vec2-id (ctx:node-id vec2))
  (local id (ctx:fresh-id))
  (ctx:instruction (Op.OpVectorShuffle tid id vec1-id vec2-id indices))
  id)

(fn Node.shuffle [vec1 vec2 indices]
  (assert (and (= vec1.type.kind :vector) (= vec2.type.kind :vector))
    (.. "Cannot shuffle non-vector values: " vec1.type.summary " " vec2.type.summary))
  (assert (= vec1.type.elem vec2.type.elem)
    (.. "Shuffled vectors must have the same element type, got: " vec1.type.elem.summary " " vec2.type.elem.summary))

  (local combined-count (+ vec1.type.count vec2.type.count))
  (each [_ index (ipairs indices)]
    (assert (< -1 index combined-count) (.. "Index not in range for shuffle: " index)))

  (if (= 1 (# indices))
    (do (local [index] indices)
        (if (>= index vec1.type.count)
          (Node.extract vec2 (- index vec1.type.count))
          (Node.extract vec1 index)))
    (Node.new
      { :kind :expr
        :type (Type.vector vec1.type.elem (# indices))
        :operation :OpVectorShuffle
        :operands [vec1 vec2 indices]
        :reify node-reify-shuffle
      })))


(local swizzle-index
  { :x 0 :y 1 :z 2 :w 3 
    :r 0 :g 1 :b 2 :a 3
    :u 0 :v 1 :s 2 :t 3
    :0 0 :1 1 :2 2 :3 3 })

(fn Node.swizzle [self index]
  (assert (or 
    (index:match "^[xyzw]+$")
    (index:match "^[rgba]+$")
    (index:match "^[uvst]+$")
    (index:match "^[0123]+$")) (.. "Unrecognized vector swizzle: " index))
  (local indices
    (fcollect [i 1 (# index)]
      (. swizzle-index (index:sub i i))))
  (Node.shuffle self self indices))


; handles syntax for all of the following:
; value[index]
; value.field
; vector.xxyy swizzle
(fn Node.index [self index]
  (local index (Node.aux.autoderef index))
  (case (values self.type.kind (type index))
    (where (or 
      (:struct :number)
      (:vector :number)
      (:matrix :number)
      (:array  :number))) (Node.extract self (math.floor index))
    (where (:array :table) (node? index))
      (do (assert (or (= index.kind :constant) ))
        (Node.extract self (math.floor index)))
    (:pointer :number)
      (Node.access self
        (Node.constant (Type.int 32 true) (math.floor index)))
    (:struct :string)
      (Node.extract self (struct-member-index self.type index))
    (where (:vector :string) (index:match "^[xyzwrgbauvst0123]+$"))
      (Node.swizzle self index)
    (where (:vector :table) (node? index))
      (Node.extract-dynamic self index)
    (where (:pointer :string))
      (do (local elem self.type.elem)
          (if (= elem.kind :struct)
                (Node.access self (u32 (struct-member-index elem index)))
              (and (= elem.kind :vector)
                   (index:match "^[xyzwrgbauvst0123]$"))
                (Node.access self (Node.constant (Type.int 32 true) (. swizzle-index index)))
              (= index "*")
                (Node.deref self)
              (Node.index (Node.deref self) index)))
    (where (:pointer :table) (node? index))
      (Node.access self index)
    else (error (.. "Index " (tostring index) " invalid for value: " (tostring self)))))


(fn node-reify-function-call [self ctx]
  (local [func args] self.operands)
  (local tid (ctx:type-id self.type))
  (local arg-ids (icollect [_ arg (ipairs args)] (ctx:node-id arg)))
  (local id (ctx:fresh-id))
  (ctx:instruction (Op.OpFunctionCall tid id func.function.id arg-ids))
  (each [iid _ (pairs func.function.interface)]
    (ctx:interface-id iid))
  id)


(fn Node.function-call [func args]
  (Node.new
    { :kind :expr
      :type func.function.type.return
      :operation :OpFunctionCall
      :operands [func args]
      :reify node-reify-function-call
    }))


; handles syntax for the following:
; function(args...)
; slightly nicer access chains (arr i j) rather than (. arr i j)
(fn Node.call [self ...]
  (case self.kind
    :function (do
        (local args [...])
        (assert (= (# args) (# self.type.params))
          (.. "Function called with the wrong number of arguments: " self.function.name self.function.type.summary))
        (local cast-args
          (icollect [i arg (ipairs args)] ((. self.type.params i) arg)))
        (Node.function-call self cast-args))
    _ (accumulate [node self _ index (ipairs [...])]
        (Node.index node index))))

;
; Node metamethods providing surface syntax to the operations
;

(fn Node.mt.__tostring [self]
  (case self.kind
    :expr (.. "(expr " self.type.summary " " self.operation ")")
    :param (.. "(param " self.type.summary ")")
    :variable (.. "(variable " self.type.summary ")")
    :constant (.. "(constant " self.type.summary " " (node-constant-summary self) ")")
    :spec-constant (.. "(spec-constant " self.type.summary (if (rawget self :operation) (.. " " self.operation) "") ")")
    :function (.. "(function " self.type.summary ")")
    :phi (.. "(phi " self.type.summary ")")))


(set Node.mt.__unm Node.neg)
(set Node.mt.__add Node.add)
(set Node.mt.__sub Node.sub)
(set Node.mt.__mul Node.mul)
(set Node.mt.__div Node.div)
(set Node.mt.__mod Node.mod)
(set Node.mt.__pow Node.pow)

(set Node.mt.__band Node.band)
(set Node.mt.__bor Node.bor)
(set Node.mt.__bxor Node.bxor)
(set Node.mt.__bnot Node.bnot)

(set Node.mt.__index Node.index)
(set Node.mt.__call Node.call)


{ : Type
  : type?

  : Node
  : node?

  :enum? enum?
} 