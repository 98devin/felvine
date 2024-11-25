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
      : MemoryAccess
      : MemorySemantics
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
; .kind      :void | :bool | :int | :float | :vector | :matrix | :image | :sampler | :sampledImage | :array | :pointer | :function | :struct
; .primitive bool

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
; .colType  type-info
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

; type-info structure :sampledImage
; .image     type-info

; type-info structure :pointer
; .elem      type-info
; .storage   StorageClass

; type-info structure :function
; .return    type-info
; .params    list[type-info]

; type-info structure :struct
; .fieldTypes   list[type-info]
; .fieldNames   ?list[string]
; .fieldIndices ?table[string, number]

(fn Type.new [o]
  (setmetatable (or o {}) Type.mt))

(fn Type.aux.containedMatrix [t]
  (case t
    {:kind :matrix} t
    {:kind :array} (Type.aux.containedMatrix t.elem)))

(fn Type.aux.layoutStructMember [type member memberType env]
  (local containedMatrix (Type.aux.containedMatrix memberType))
  (when containedMatrix 
    (local (majority vector)
      (if (env:decoratedMember? type member :RowMajor)
        (values Decoration.RowMajor (Type.vector containedMatrix.elem containedMatrix.cols))
        (values Decoration.ColMajor (Type.vector containedMatrix.elem containedMatrix.rows))))
    (local {: size : alignment} vector)
    (local paddedSize (band (+ size (- alignment 1)) (bnot (- alignment 1))))
    (env:decorateMember type member majority (Decoration.MatrixStride paddedSize))))


(fn Type.layout [type env]
  (when (not (. env.typesLaidOut type.summary))
    (tset env.typesLaidOut type.summary true)
    (case type.kind
      :pointer
        (when (= type.storage.tag :PhysicalStorageBuffer)
            (Type.layout type.elem env))

      :struct
        (do 
          (var offset 0)
          (each [i field (ipairs type.fieldTypes)]
            (Type.layout field env)
            (Type.aux.layoutStructMember type (- i 1) field env)
            (local {: size : alignment} field)
            (assert alignment (.. "Cannot layout struct with opaque member: " (. type.fieldNames i) field.summary))
            (assert (or size (= i (# type.fieldTypes)))
              (.. "Cannot layout struct with unsized member if it is not last: " (. type.fieldNames i) field.summary))
            (set offset (band (+ offset (- alignment 1)) (bnot (- alignment 1))))
            (env:decorateMember type (- i 1) (Decoration.Offset offset))
            (when size (set offset (+ offset size)))))

      :array
        (let [{: size : alignment} type.elem
              size (assert size (.. "Cannot layout array with unsized element type: " type.elem.summary))
              paddedSize (band (+ size (- alignment 1)) (bnot (- alignment 1)))]
          (Type.layout type.elem env)
          (env:decorateType type (Decoration.ArrayStride paddedSize))))))


(fn Type.aux.logicallyMatches [self other]
  (case (values self.kind other.kind)
    (:array :array)
      (and (= self.count other.count) (Type.aux.logicallyMatches self.elem other.elem))
    (:struct :struct)
      (and (= (# self.fieldTypes) (# other.fieldTypes))
        (faccumulate [all true i 1 (# self.fieldTypes)]
          (let [t1 (. self.fieldTypes i) t2 (. other.fieldTypes i)]
            (and all (or (= t1 t2) (Type.aux.logicallyMatches t1 t2))))))
    _ false))


; Type construction with multiple inputs and non-node (constant) arguments
; e.g. to allow (u32 0) or (vec4f 10.0 -10.0 (vec2f a b))
; should propagate (spec-)const-ness.
; serves as a main way to turn meta-values into typed values.
(fn Type.construct [tycon ...]
  (case tycon
    {:kind :int : signed}
      (do (local arg ...)
          (if (node? arg) (Node.convert arg tycon)
              (enum? arg) (Node.constant tycon arg.value)
              (= (type arg) :number)
                (do (assert (or signed (>= arg 0)) (.. "Unsigned integer must be >= 0, got: " arg))
                    (Node.constant tycon (math.floor arg)))
              (error (.. "Cannot construct integer from argument: " (fennel.view arg)))))
              ; TODO: Allow specifying a particular bit pattern via a string?

    {:kind :float}
      (do (local arg ...)
          (if (node? arg) (Node.convert arg tycon)
              (enum? arg) (Node.constant tycon arg.value)
              (= (type arg) :number) (Node.constant tycon arg)
              (error (.. "Cannot construct float from argument: " (fennel.view arg)))))
              ; TODO: Allow specifying a particular bit pattern via a string?

    {:kind :vector : elem : count}
      (do (local args [...])
          (local components [])
          (var componentCount 0)
          (each [_ arg (ipairs args)]
            (if (node? arg)
                (do (local arg (Node.aux.autoderef arg))
                    (local (prim argCount) (arg.type:primCount))
                    (set componentCount (+ componentCount argCount))
                    (table.insert components (Node.convert arg (Type.vector elem argCount))))
                (= (type arg) :table)
                (do (set componentCount (+ componentCount (# arg)))
                    (icollect [_ argElem (ipairs arg) &into components] 
                      (elem argElem)))
                (= (type arg) :number)
                (do (set componentCount (+ componentCount 1))
                    (table.insert components (elem arg)))
                (error (.. "Cannot construct vector from argument: " (fennel.view arg)))))
          
          (assert (or (= componentCount count) (= componentCount 1)) 
                  (.. "Incorrect number of arguments to construct vector: " componentCount " " tycon.summary))
          (if
            (= componentCount 1) (Node.convert (. components 1) tycon)
            (= (# components) 1) (. components 1) 
            (do (local commonKind (Node.aux.commonNodeKindOf components))
              (case commonKind
                (where (or :expr :specConstant)) (Node.composite tycon components commonKind)
                :constant ; need to flatten the constants inside to replicate regular operations
                  (do (local flatComponents [])
                      (each [_ component (ipairs components)]
                        (if (= component.kind :vector)
                          (icollect [_ v (ipairs component.constant) &into flatComponents] v)
                          (table.insert flatComponents component.constant)))
                      (Node.constant tycon flatComponents))))))

    {:kind :array : elem : ?count}
      (do (local args [...])
          (local argCount (# args))
          (when ?count
            (assert (or (= argCount 1) (= argCount ?count)) "Array must be constructed from a single table or unpacked sequence"))
          (if (= argCount 1)
            (let [arg (Node.aux.autoderef (. args 1))]
              (if (node? arg)
                (if (= arg.type tycon) arg
                    (Type.aux.logicallyMatches arg.type tycon) (Node.aux.op :OpCopyLogical tycon arg)
                    (error (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary)))
                (Type.aux.arrayFromParts tycon arg)))
            (Type.aux.arrayFromParts tycon args)))

    {:kind :matrix : elem : rows : cols}
      (do (local args [...])
          (local argCount (# args))
          (assert (or (= argCount 1) (= argCount cols))
            "Matrix must be constructed from a single table or unpacked sequence of columns")
          (local args (if (= argCount 1) (. args 1) args))
          (if (and (= argCount 1) (node? args))
            (if (= tycon args.type) args
                (= :matrix args.kind)
                  (Type.aux.matrixFromParts tycon
                    (fcollect [i 0 (- args.cols 1)] (args i)))
                (Type.aux.matrixFromParts args))
            (Type.aux.matrixFromParts args)))
    
    {:kind :struct : fieldTypes : fieldNames}
      (do (local args [...])
          (local argCount (# args))
          (assert (or (= argCount 1) (= argCount (# fieldTypes)))
            "Struct must be constructed from a single table or sequence of field values")
          (if (= (# args) 1)
            (let [arg (Node.aux.autoderef (. args 1))]
              (assert (= (type arg) :table) (.. "Struct must be constructed from table, got: " (tostring arg)))            
              (if (node? arg)
                (if (= arg.type tycon) arg
                    (Type.aux.logicallyMatches arg.type tycon) (Node.aux.op :OpCopyLogical tycon arg)
                    (error (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary)))
                (Type.aux.structFromParts tycon arg)))
            (Type.aux.structFromParts tycon args)))
    
    {:kind :void}
      nil

    {:kind :accelerationStructure}
      (do (local arg ...)
          (assert (and (node? arg)
                       (or (= arg.type (Type.int 64 false))
                           (= arg.type (Type.vector (Type.int 32 false) 2))))
                  (.. "Acceleration structure cannot be cast from: " (tostring arg)))
          (Node.aux.op :OpConvertUToAccelerationStructureKHR (Type.accelerationStructure) arg))

    other
      (do (local arg ...)
          (assert (node? arg) (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary))
          (if 
            (= arg.type tycon) arg
            (and (= arg.type.kind :pointer)
                 (= arg.type.elem tycon)) (Node.deref arg)
            (error (.. "Cannot cast value to type: " (tostring arg) " " tycon.summary))))))


(fn Type.aux.arrayFromParts [tycon parts]
  (local {: count : elem} tycon)
  (local components
    (icollect [_ arg (ipairs parts)]
      (elem arg)))
  (local componentCount (# components))

  (when count
    (assert (= componentCount count) (.. "Incorrect number of arguments to construct array: " componentCount tycon.summary)))

  (local commonKind (Node.aux.commonNodeKindOf components))
  (case commonKind
    :constant (Node.constant (Type.array elem componentCount) components) ; we know count, no need for runtime array.
    _ (Node.composite tycon components commonKind)))


(fn Type.aux.matrixFromParts [tycon parts]
  (local {: elem : rows} tycon)
  (local column (Type.vector elem rows))
  (local components
    (icollect [_ arg (ipairs parts)]
      (column arg)))

  (local commonKind (Node.aux.commonNodeKindOf components))
  (case commonKind
    :constant (Node.constant tycon components)
    _ (Node.composite tycon components commonKind)))


(fn Type.aux.structFromParts [tycon parts]
  (local {: fieldTypes : fieldNames} tycon)
  (let [fields (icollect [i name (ipairs tycon.fieldNames)]
                ((. tycon.fieldTypes i) (or (. parts name) (. parts i))))
        commonKind (Node.aux.commonNodeKindOf fields)]
    ; TODO: support constant folded struct values properly
    (Node.composite tycon fields commonKind)))


; forced id parameter necessary to ensure forward pointer declarations are
; linked properly, e.g. for types which reference a PhysicalStorageBuffer* to themselves.
(fn Type.reify [self ctx id]
  (local id (or id (ctx:freshID)))
  (case self.kind
    :void (ctx:instruction (Op.OpTypeVoid id))
    :bool (ctx:instruction (Op.OpTypeBool id))
    :int (ctx:instruction (Op.OpTypeInt id self.bits (if self.signed 1 0)))
    :float (ctx:instruction (Op.OpTypeFloat id self.bits))
    :vector (ctx:instruction (Op.OpTypeVector id (ctx:typeID self.elem) self.count))
    :matrix (do (local column (Type.vector self.elem self.rows))
                (ctx:instruction (Op.OpTypeMatrix id (ctx:typeID column) self.cols)))
    :sampler (ctx:instruction (Op.OpTypeSampler id))
    :sampledImage (ctx:instruction (Op.OpTypeSampledImage id (ctx:typeID self.image)))
    :image (ctx:instruction
      (Op.OpTypeImage
        id
        (ctx:typeID self.elem)
        self.dim
        (if self.depth 1 0)
        (if self.array 1 0)
        (if self.ms 1 0)
        (case self.usage
          :texture 1
          :storage 2)
        (or self.format ImageFormat.Unknown)))

    :rayQuery (ctx:instruction (Op.OpTypeRayQueryKHR id))
    :accelerationStructure (ctx:instruction (Op.OpTypeAccelerationStructureKHR id))

    :pointer 
      (when (or (= nil self.forward)
              (= id self.forward))
        (Type.layout self ctx)
        (ctx:instruction (Op.OpTypePointer id self.storage (ctx:typeID self.elem))))

    :function (ctx:instruction
      (Op.OpTypeFunction
        id
        (ctx:typeID self.return)
        (icollect [_ t (ipairs self.params)]
          (ctx:typeID t))))
      
    :struct
      (do (ctx:instruction
            (Op.OpTypeStruct id (icollect [_ t (ipairs self.fieldTypes)] (ctx:typeID t))))
          (when self.fieldNames
            (each [i v (ipairs self.fieldNames)]
              (ctx:instruction (Op.OpMemberName id (- i 1) v))))
          (when self.fieldDecorations
            (each [i decs (pairs self.fieldDecorations)]
              (each [_ dec (ipairs decs)]
                (ctx:decorateMemberID id (- i 1) dec)))))
    :array
      (case self.count
        nil (ctx:instruction (Op.OpTypeRuntimeArray id (ctx:typeID self.elem)))
        count (do (local count ((Type.int 32 false) count))
                  (ctx:instruction (Op.OpTypeArray id (ctx:typeID self.elem) (ctx:nodeID count))))))

  (ctx:instruction (Op.OpName id self.summary))
  id)

(fn Type.makeSummary [info]
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
      :sampledImage
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
        (if info.fieldNames
          (.. "{" (table.concat (icollect [i e (ipairs info.fieldTypes)] (.. (. info.fieldNames i) ":" e.summary)) ",") "}")
          (.. "{" (table.concat (icollect [_ e (ipairs info.fieldTypes)] e.summary) ",") "}"))
      :rayQuery :rayQuery
      :accelerationStructure :accelerationStructure
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

(fn Type.accelerationStructure []
  (Type.new
    { :kind :accelerationStructure
      :opaque true
      :summary :accelerationStructure
    }))

(fn Type.rayQuery []
  (Type.new
    { :kind :rayQuery
      :opaque true
      :summary :rayQuery
    }))

(fn Type.sampled [image]
  (assert (= image.kind :image) (.. "Cannot sample non-image type: " image.summary))
  (assert (= image.usage :texture) (.. "Cannot sample storage image: " image.summary))
  (Type.new
    { :kind :sampledImage
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
      :primitive true
    }))

(fn Type.float [b]
  (local size (math.floor (/ (+ b 7) 8)))
  (Type.new
    { :kind :float
      :bits b
      :size size
      :alignment size
      :opaque false
      :primitive true
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
        :primitive elem.primitive
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

(fn advanceSizeAlignment [current {: size : alignment}]
  (if (or (= nil current) (= nil current.size) (= nil alignment))
    nil
    (let [alignedOffset (band
          (+ current.size (- alignment 1))
          (bnot (- alignment 1)))]
        { :size (if (not= nil size) (+ alignedOffset size))
          :alignment (math.max current.alignment alignment)
        })))

(fn Type.struct [fieldTypes fieldNames fieldDecorations]
    (local fieldDecorations (or fieldDecorations {}))
    (local fieldIndices {})
    (each [i t (pairs fieldTypes)]
      (tset fieldIndices (. fieldNames i) (- i 1)))
    (local sizeAlignment
      (accumulate [current {:size 0 :alignment 1} _ ty (ipairs fieldTypes)]
        (advanceSizeAlignment current ty)))
    (Type.new
      { :kind :struct
        :opaque (= nil sizeAlignment)
        :size (?. sizeAlignment :size)
        :alignment (?. sizeAlignment :alignment)
        : fieldTypes
        : fieldNames
        : fieldIndices
        : fieldDecorations
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
  (fn ptr [newElem] (Type.pointer newElem self.storage))
  (case self.elem
    {:kind :struct : fieldTypes}
      (do (assert (= index.kind :constant) (.. "Cannot access non-constant struct field of " self.elem.summary))
          (assert (= index.type.kind :int) (.. "Struct field access must be an integer, got: " index.type.summary))
          (local memberIndex (+ index.constant 1))
          (assert (<= memberIndex (# fieldTypes)) (.. "Struct does not have enough fields for index: " memberIndex " " self.elem.summary))
          (ptr (. fieldTypes memberIndex)))
    {:kind :vector : count}
      (do (assert (= index.type.kind :int) (.. "Vector index must be an integer, got: " index.type.summary))
          (when (= index.kind :constant)
            (assert (< (or index.constant 0) count) (.. "Vector index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr self.elem.elem))
    {:kind :array : ?count}
      (do (assert (= index.type.kind :int) (.. "Array index must be an integer, got: " index.type.summary))
          (when (and (= index.kind :constant) (not= nil ?count))
            (assert (< index.constant ?count) (.. "Array index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr self.elem.elem))
    {:kind :matrix : cols : rows}
      (do (assert (= index.type.kind :int) (.. "Matrix index must be an integer, got: " index.type.summary))
          (when (= index.kind :constant)
            (assert (< (or index.constant 0) cols) (.. "Matrix index would be out of bounds: " index.constant " " self.elem.summary)))
          (ptr (Type.vector self.elem.elem rows)))
    _ (error (.. "Cannot index non-composite type: " self.elem.summary))))

; `extract` is indexing into values and must be static
(fn Type.extract [self index]
  (assert (= (type index) :number) (.. "Cannot `extract` with non-numeric index: " index))
  (case self
    {:kind :struct : fieldTypes}
      (do (local memberIndex (+ index 1))
          (assert (<= memberIndex (# self.fieldTypes)) (.. "Struct does not have enough fields for index: " memberIndex " " self.summary))
          (. self.fieldTypes memberIndex))
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

(fn Type.primCount [self]
  (case self.kind
    :int (values self 1)
    :float (values self 1)
    :vector (values self.elem self.count)
    _ (error (.. "Type is not primitive: " self.summary))))

(fn Type.primElem [self]
  (case self.kind
    :int self
    :float self
    :vector self.elem
    :matrix self.elem
    _ (error (.. "Type does not contain primitive numerical element: " self.summary))))

(fn Type.mt.__index [self key]
  (case key
    :summary (Type.makeSummary self)
    _ (. Type key)))

(fn Type.mt.__eq [self other]
  (= self.summary other.summary))

(fn Type.mt.__tostring [self]
  self.summary)

(set Type.mt.__call Type.construct)

(fn structMemberIndex [type memberName]
  (local ix (?. type :fieldIndices memberName))
  (assert ix (.. "Type is not a struct or has no member `" memberName "`: " type.summary))
  ix)

(local bool (Type.bool))
(local u32 (Type.int 32 false))
(local f32 (Type.float 32))
(local i32 (Type.int 32 true))
(local u64 (Type.int 64 false))
(local f64 (Type.float 64))
(local i64 (Type.int 64 true))

; node structure
; .kind          :expr | :phi | :function | :variable | :param | :constant | :specConstant
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

; node structure :specConstant
; .operation     SpecConstantOp.tag
; .operands      list[any]
; .dependencies  list[node]

(fn Node.new [o]
  (local o (or o {}))
  (setmetatable o Node.mt))

(set Node.constantImpl {})
(set Node.specConstantImpl {})

(fn Node.aux.enumValue [enum v]
  (if 
    (node? v) (do (assert (and (= v.kind :constant) (= v.type.kind :int))
                          (.. "Cannot interpret value as " enum.name " " (tostring v))) (u32 v))
    (enum? v) (do (assert (= (enum? v) enum.name)
                          (.. "Cannot interpret value as " enum.name " " (tostring v))) (u32 v.value))
    (= (type v) :string) (u32 (. enum v :value))
    (= (type v) :number) (u32 v)
    (error (.. "Cannot interpret value as " enum.name " " (tostring v)))))

(fn Node.aux.commonNodeKind [kind1 kind2]
  (case (values kind1 kind2)
    (:constant :constant)           :constant
    (:constant :specConstant)      :specConstant
    (:specConstant :constant)      :specConstant
    (:specConstant :specConstant) :specConstant
    _ :expr))

(fn Node.aux.commonNodeKindOf [nodes]
  (accumulate [kind :constant _ node (ipairs nodes)]
    (Node.aux.commonNodeKind kind node.kind)))

(fn nodeReifyParam [self ctx]
  (local tid (ctx:typeID self.type))
  (local id (ctx:freshID))
  (local op (Op.OpFunctionParameter tid id))
  (ctx:instruction op)
  id)

(fn Node.param [type]
  (Node.new
    { :kind :param
      :type type
      :reify nodeReifyParam
    }))

(fn nodeReifyPhi [self ctx]
  (local tid (ctx:typeID self.type))
  (local id (ctx:freshID))
  (local op (Op.OpPhi tid id self.sources))
  (ctx:instruction op)
  id)

(fn Node.phi [type ...]
  (Node.new
    { :kind :phi
      :type type
      :sources [...]
      :reify nodeReifyPhi
    }))

(fn nodeReifyFunction [self ctx]
  self.function.id)

(fn Node.function [function]
  (Node.new
    { :kind :function
      :type function.type
      :function function
      :reify nodeReifyFunction
    }))

(fn nodeReifyVariable [self ctx]
  (local tid (ctx:typeID self.type))
  (local init (if (rawget self :initializer) (ctx:nodeID self.initializer) nil))
  (local id (ctx:freshID))
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
      :reify nodeReifyVariable
    }))

(fn nodeConstantSummary [self]
  (or (rawget self :summary)
    (do (local summary (fennel.view (rawget self :constant)))
        (set self.summary summary)
        summary)))

(fn typeSerializeFmt [t]
  (case t
    {:kind :int : bits : signed}
      (let [words (math.floor (/ (+ bits 31) 32))
            sigil (if signed "i" "I")]
        (.. sigil (* words 4)))
    {:kind :float : bits}
      (if (> bits 32) "d" "f")))

(fn nodeReifyConstant [self ctx]
  (local tid (ctx:typeID self.type))
  (local (existing cid) (ctx:constantID tid (nodeConstantSummary self)))
  (when (not existing)
    (fn constituentIDs [elem constants]
      (icollect [_ v (ipairs constants)]
        (ctx:nodeID (Node.constant elem v))))
    (local op
      (if (= nil self.constant) (Op.OpConstantNull tid cid)
        (case self.type.kind
          :bool
            (if self.constant (Op.OpConstantTrue tid cid) (Op.OpConstantFalse tid cid))
          (where (or :int :float))
            (Op.OpConstant tid cid (base.serializableWithFmt (typeSerializeFmt self.type) self.constant))
          (where (or :vector :array))
            (Op.OpConstantComposite tid cid (constituentIDs self.type.elem self.constant))
          :matrix
            (Op.OpConstantComposite tid cid (constituentIDs (Type.vector self.type.elem self.type.rows) self.constant))
          :struct
            (Op.OpConstantComposite tid cid 
              (icollect [i m (ipairs self.type.fieldNames)]
                (ctx:nodeID (Node.constant (. self.type.fieldTypes i) (. self.constant m))
          :pointer
            (error (.. "Cannot have a constant non-null pointer, tried to provide value: " self.constant))
          :function
            (error "Cannot define constant function. Function nodes are already constants.")
          :void
            (error "Cannot define constant void. Values of void do not exist.")))))))
    (ctx:instruction op))
  cid)

(fn nodeReifySpecConstant [self ctx]
  (local tid (ctx:typeID self.type))
  (local cid (ctx:freshID))
  (fn constituentIDs [elem constants]
    (icollect [_ v (ipairs constants)]
      (ctx:nodeID (Node.constant elem v))))
  (local op
    (case self.type.kind
      :bool
        (if self.constant (Op.OpSpecConstantTrue tid cid) (Op.OpSpecConstantFalse tid cid))
      (where (or :int :float))
        (Op.OpSpecConstant tid cid (base.serializableWithFmt (typeSerializeFmt self.type) self.constant))
      (where (or :vector :array))
        (Op.OpSpecConstantComposite tid cid (constituentIDs self.type.elem self.constant))
      :matrix
        (Op.OpSpecConstantComposite tid cid (constituentIDs (Type.vector self.type.elem self.type.rows) self.constant))
      :struct
        (Op.OpSpecConstantComposite tid cid 
          (icollect [i m (ipairs self.type.fieldNames)]
            (ctx:nodeID (Node.constant (. self.type.fieldTypes i) (. self.constant m))
      :pointer
        (error (.. "Cannot declare a specConstant pointer; tried to provide value: " self.constant))
      :function
        (error "Cannot define a specConstant function. Function nodes are already constants.")
      :void
        (error "Cannot define a specConstant of type void. Values of void do not exist."))))))
  (ctx:instruction op)
  cid)


(fn Node.aux.adjustConstantValue [ty value]
  (local value (if (node? value) value.constant value))
  ; (print :Node.aux.adjustConstantValue ty value)
  (case ty
    {:kind :int : signed : bits}
      (if (> bits 62)
        (if (or signed (>= value 0))
            (assert (math.tointeger (math.floor value)) (.. "Cannot represent as integer: " value))
            (error (.. "Cannot represent as unsigned integer: " value)))
        (let [maxValue (^ 2 bits)
              sign (if (>= value 0) 1 -1)
              wrappedValue (% (math.modf value) (* sign maxValue))]
          (assert 
            (math.tointeger
              (if (and (not signed) (< wrappedValue 0)) (+ wrappedValue maxValue)
                wrappedValue)) (.. "Cannot represent as integer: " value))))
    {:kind :float}
      value ; nothing really needs to happen since all numbers can be converted to floats
    (where (or {:kind :vector : elem} {:kind :array : elem}))
      (icollect [_ v (ipairs value)] (Node.aux.adjustConstantValue elem v))
    {:kind :matrix : elem : rows}
      (let [colType (Type.vector elem rows)]
        (icollect [_ col (ipairs value)] (Node.aux.adjustConstantValue colType col)))
    ))

(fn Node.constant [type value]
  ; (print :Node.constant type.summary (if (node? value) value (fennel.view value)))
  (if (node? value)
    (if (= value.type type) value
      (Node.new
        { :kind :constant
          :type type
          :constant (Node.aux.adjustConstantValue type value.constant)
          :reify nodeReifyConstant
        }))    
    (Node.new
      { :kind :constant
        :type type
        :constant (Node.aux.adjustConstantValue type value)
        :reify nodeReifyConstant
      })))

(fn Node.specConstant [type value]
  (local const (Node.constant type value))
  (set const.kind :specConstant)
  (set const.reify nodeReifySpecConstant)
  const)

(fn nodeReifyComposite [self ctx]
  (local tid (ctx:typeID self.type))
  (local argids
    (icollect [_ arg (ipairs self.operands)]
      (ctx:nodeID arg)))
  (local id (ctx:freshID))
  (local op ((. Op self.operation) tid id argids))
  (ctx:instruction op)
  id)

(fn Node.composite [type components kind]
  (local operation
    (case (or kind :expr)
      :expr :OpCompositeConstruct
      :specConstant :OpSpecConstantComposite
      :constant :OpConstantComposite
      ))
  (Node.new
    { :kind (or kind :expr)
      :type type
      :operation operation
      :operands components
      :reify nodeReifyComposite
    }))


(fn Node.aux.basePointer [ptr]
  (assert (= ptr.type.kind :pointer) (.. "Node is not a pointer: " (tostring ptr)))
  (var base ptr)
  (while (and (= :expr base.kind) (= :OpAccessChain base.operation))
    (set base (. base.operands 1)))
  base)


(fn nodeReifyLoad [self ctx]
  (local [source memoryOps] self.operands)

  ; (assert (not source.type.elem.opaque)
  ;   (.. "Cannot load unsized type from memory: " source.type.summary))

  (local tid (ctx:typeID self.type))
  (local sourceid (ctx:nodeID source))
  (local id (ctx:freshID))

  (local memoryOps
    (if (= source.type.storage.tag :PhysicalStorageBuffer)
        (MemoryAccess (MemoryAccess.Aligned source.type.elem.alignment) memoryOps)
        memoryOps))

  (local op (Op.OpLoad tid id sourceid memoryOps))
  (ctx:instruction op)

  (local base (Node.aux.basePointer source))
  (when (and (= base.kind :variable) (not= base.storage StorageClass.Function))
    (ctx:interfaceID (ctx:nodeID base))) ; already requested so won't change instructions
  
  id)

(fn Node.deref [node]
  (case node.type.kind
    :pointer
      (Node.new
        { :kind :expr
          :type (node.type:deref)
          :operation :OpLoad
          :operands [node]
          :reify nodeReifyLoad
        })
    _ (error "Cannot dereference non-pointer value")))

(fn Node.aux.bitcastConvert [self type]
  (if (= self.kind :constant)
    (Node.constant type self.constant)
    (Node.aux.op :OpBitcast type self)))

(fn Node.any? [vec]
  (local bool (Type.bool))
  (local (prim count) (vec.type:primCount))
  (assert (= bool prim) (.. "Cannot take disjunction of type: " vec.type.summary))
  (if (= 1 count) vec
    (Node.aux.op :OpAny bool vec)))

(fn Node.all? [vec]
  (local bool (Type.bool))
  (local (prim count) (vec.type:primCount))
  (assert (= bool prim) (.. "Cannot take conjunction of type: " vec.type.summary))
  (if (= 1 count) vec
    (Node.aux.op :OpAll bool vec)))


; This is only primitive type conversion,
; e.g. numbers and vectors of them.
; Anything else will need a dedicated routine, since
; only these simple types have conversion ops in spirv
(fn Node.convert [node type]
  (local node (Node.aux.autoderef node))

  (local (nPrim nCount) (node.type:primCount))
  (local (tPrim tCount) (type:primCount))

  ; cannot convert from vector to scalar
  ; (bitcast is a different operation)
  (when (not= nCount 1)
    (assert (= nCount tCount) (.. "Incompatible counts for conversion: " nCount " " tCount " from types: " node.type.summary " " type.summary)))

  (var out node)

  ; handle primitive conversion first
  (when (not= nPrim tPrim)
    (case (values nPrim tPrim)
      ({:kind :int :signed nSign :bits nBits}
       {:kind :int :signed tSign :bits tBits})
        (do
          ; need to sign extend before casting signed-ness
          (when (not= tBits nBits)
            (local extended (Type.vector (Type.int tBits nSign) nCount))
            (set out 
              (Node.aux.op
                (if nSign :OpSConvert :OpUConvert)
                extended
                out)))
          (when (not= tSign nSign)
            (set out (Node.aux.bitcastConvert out (Type.vector tPrim nCount)))))
      ({:kind :int :signed nSign} {:kind :float})
        (set out
          (Node.aux.op
            (if nSign :OpConvertSToF :OpConvertUToF)
            (Type.vector tPrim nCount)
            out))
      ({:kind :float} {:kind :int :signed tSign})
        (set out
          (Node.aux.op
            (if tSign :OpConvertFToS :OpConvertFToU)
            (Type.vector tPrim nCount)
            out))
      ({:kind :float} {:kind :float})
        (set out
          (Node.aux.op
            :OpFConvert
            (Type.vector tPrim nCount)
            out))))
            
  ; handle scalar-to-vector broadcast
  (when (not= nCount tCount)
    (case (Node.aux.commonNodeKindOf [out])
      :constant (set out (Node.constant type (fcollect [i 1 tCount] out.constant)))
      _ (set out (Node.composite type (fcollect [i 1 tCount] out)))))
    
  out)


(fn nodeReifyOp [self ctx]
  (local tid (ctx:typeID self.type))
  (local argIDs
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:nodeID arg) arg)))
  (local id (ctx:freshID))
  (local op ((. Op self.operation) tid id (table.unpack argIDs)))
  (ctx:instruction op)
  id)

(fn nodeReifySpecConstantOp [self ctx]
  (local tid (ctx:typeID self.type))
  (local argIDs
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:nodeID arg) arg)))
  (local id (ctx:freshID))
  (local op (Op.OpSpecConstantOp tid id ((. SpecConstantOp self.operation) (table.unpack argIDs))))
  (ctx:instruction op)
  id)

(fn nodeReifyGLSL [self ctx]
  (local extID (ctx:extInstID :GLSL.std.450))
  (local tid (ctx:typeID self.type))
  (local argIDs
    (icollect [_ arg (ipairs self.operands)]
      (if (node? arg) (ctx:nodeID arg) arg)))
  (local id (ctx:freshID))
  (local op (Op.OpExtInst tid id extID ((. ExtGLSL self.operation) (table.unpack argIDs))))
  (ctx:instruction op)
  id)


(fn Type.primCommonSupertype [t0 ...]
  (accumulate [t t0 _ t1 (ipairs [...])]
    (Type.aux.primCommonSupertype t t1)))

(fn Type.aux.primCommonSupertype [lt rt]
  (local (lPrim lCount) (lt:primCount))
  (local (rPrim rCount) (rt:primCount))

  (when (and (not= 1 lCount) (not= 1 rCount))
    (assert (= lCount rCount) (.. "Cannot find common result for these types: " lt.summary " " rt.summary)))
  
  (local outPrim
    (if (= lPrim.kind rPrim.kind :bool) lPrim
      (do 
        (assert (and (not= lPrim.kind :bool) (not= rPrim.kind :bool)) "Cannot mix bool with number.")
        (local outKind
          (if (or (= lPrim.kind :float) (= rPrim.kind :float)) :float :int))
        (local outSigned
          (if (or (= lPrim.kind :float) (= rPrim.kind :float)) true (or lPrim.signed rPrim.signed)))
        (local outBits
          (math.max lPrim.bits rPrim.bits))
        (case outKind
          :int (Type.int outBits outSigned)
          :float (Type.float outBits)))))

  (Type.vector outPrim (math.max lCount rCount)))



(fn Node.aux.makeOpInternal [operation type ...]
  (Node.new
    { :kind :expr
      :type type
      :operation operation
      :operands [...]
      :reify nodeReifyOp
    }))

(fn Node.aux.makeGLSLOpInternal [operation type ...]
  (Node.new
    { :kind :expr
      :type type
      :operation operation
      :operands [...]
      :reify nodeReifyGLSL
    }))

(fn Node.aux.makeSpecConstantOpInternal [operation type ...]
  (Node.new
    { :kind :specConstant
      :type type
      :operation operation
      :operands [...]
      :reify nodeReifySpecConstantOp
    }))

(fn Node.aux.op [operation type ...]
  (local specializedFuncs
    [ (. Node.constantImpl operation) 
      (. Node.specConstantImpl operation)
      Node.aux.makeOpInternal ])
  (local startIx
    (case (Node.aux.commonNodeKindOf [...])
      :constant 1
      :specConstant 2
      :expr 3 ))
  (faccumulate [value nil i startIx 3 &until value]
    (let [f (. specializedFuncs i)]
      (when (not= nil f)
        (local (valid result) (pcall f operation type ...))
        ; (when (not valid) (print result))
        (if valid result)))))


(fn Node.glsl.op [operation type ...]
  (local specializedFuncs
    [ (. Node.constantImpl (.. "GLSL" operation))
      (. Node.specConstantImpl (.. "GLSL" operation))
      Node.aux.makeGLSLOpInternal ])
  (local startIx
    (case (Node.aux.commonNodeKindOf [...])
      :constant 1
      :specConstant 2
      :expr 3 ))
  (faccumulate [value nil i startIx 3 &until value]
    (let [f (. specializedFuncs i)]
      (when (not= nil f)
        (local (valid result) (pcall f operation type ...))
        (when (not valid) (print result))
        (if valid result)))))

(fn Node.aux.autoderef [node]
  (if (and (node? node) (= node.type.kind :pointer))
    (Node.deref node)
    node))

(fn nodeSimpleUnop [{ : name :sint sintOp :uint uintOp :float floatOp :bool boolOp }]
  (fn [node]
    (local node (Node.aux.autoderef node))
    (local opcode
      (case (node.type:primCount)
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :bool} boolOp
        {:kind :float} floatOp))
    (if (= nil opcode)
      (error (.. "Cannot " name " value of type: " node.type.summary)))
    (Node.aux.op
      opcode node.type node)))

(fn nodeCompareUnop
  [{ :sint sintOp
     :uint uintOp
     :float floatOp
     :bool boolOp }]
  (fn [node]
    (local node (Node.aux.autoderef node))
    (local (prim count) (node.type:primCount))
    (local opcode
     (case prim
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :bool} boolOp
        {:kind :float} floatOp))
    (if (= nil opcode)
      (error (.. "Cannot compare value of type: " node.type.summary)))
    (local outBool (Type.vector (Type.bool) count))
    (Node.aux.op
      opcode outBool node)))

(fn nodeGLSLUnop [{ : name :sint sintOp :uint uintOp :float floatOp :bool boolOp : nof64? : noi64? }]
  (fn [node]
    (local node (Node.aux.autoderef node))
    (var (outPrim outCount) (node.type:primCount))
    (var opcode
      (case outPrim
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :bool} boolOp
        {:kind :float} floatOp))
    (when (and (= nil opcode) (= outPrim.kind :int))
      (set opcode floatOp)
      (set outPrim (Type.float 32)))
    (if (= nil opcode)
      (error (.. "Cannot " name " value of type: " node.type.summary)))
    (when nof64?
      (case outPrim
        (where {:kind :float : bits} (> bits 32))
          (set outPrim (Type.float 32))))
    (when noi64?
      (case outPrim
        (where {:kind :int : signed : bits} (> bits 32))
          (set outPrim (Type.int 32 signed))))
    (local outType (Type.vector outPrim outCount))
    (Node.glsl.op
      opcode outType (outType node))))

(fn nodeSimpleBinop
  [{ : name 
     :sint sintOp
     :uint uintOp
     :float floatOp
     :bool boolOp }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local outType
      (if (and (node? lhs) (node? rhs)) (Type.primCommonSupertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (local opcode
      (case (outType:primCount)
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :bool} boolOp
        {:kind :float} floatOp))
    (if (= nil opcode)
      (error (.. "Cannot " name " values of type: " outType.summary)))
    (Node.aux.op opcode outType 
      (outType lhs)
      (outType rhs))))

(fn nodeCompareBinop
  [{ :sint sintOp
     :uint uintOp
     :float floatOp }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local outType
      (if (and (node? lhs) (node? rhs)) (Type.primCommonSupertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (local (_ outCount) (outType:primCount))
    (local outBool (Type.vector (Type.bool) outCount))
    (local opcode
      (case (outType:primCount)
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :float} floatOp))
    (if (= nil opcode)
      (error (.. "Cannot compare values of type: " outType.summary)))
    (Node.aux.op opcode outBool
      (outType lhs)
      (outType rhs))))

(fn nodeGLSLBinop
  [{ : name 
     :sint sintOp
     :uint uintOp
     :float floatOp
     :bool boolOp
     : nof64?
     : noi64? }]
  (fn [lhs rhs]
    (local lhs (Node.aux.autoderef lhs))
    (local rhs (Node.aux.autoderef rhs))
    (local outType
      (if (and (node? lhs) (node? rhs)) (Type.primCommonSupertype lhs.type rhs.type)
          (node? lhs) lhs.type
          (node? rhs) rhs.type))
    (var (outPrim outCount) (outType:primCount))
    (var opcode
      (case outPrim
        {:kind :int :signed true} sintOp
        {:kind :int :signed false} uintOp
        {:kind :bool} boolOp
        {:kind :float} floatOp))
    (when (and (= nil opcode) (= outPrim.kind :int))
      (set opcode floatOp)
      (set outPrim (Type.float 32)))
    (if (= nil opcode)
      (error (.. "Cannot " name " values of type: " outType.summary)))
    (when nof64?
      (case outPrim
        (where {:kind :float : bits} (> bits 32))
          (set outPrim (Type.float 32))))
    (when noi64?
      (case outPrim
        (where {:kind :int : signed : bits} (> bits 32))
          (set outPrim (Type.int 32 signed))))
    (local outType (Type.vector outPrim outCount))
    (Node.glsl.op opcode outType 
      (outType lhs)
      (outType rhs))))

(fn nodeGLSLPackOp
  [{ : inType
     : outType 
     : op }]
  (fn [v]
    (local v (Node.aux.autoderef v))
    (Node.glsl.op op outType (inType v))))

;
; Constant propagation implementations
; NOTE: should review to ensure that Node.constant handles wrapping etc. in a way consistent with spirv.
; 

(fn Node.aux.constIntFloatConvert [operation type node]
  (Node.constant type node.constant))
  ; (print operation type node)
  ; (local prim (type:primCount))
  ; (case prim.kind
  ;   :int (Node.constant type (math.floor node.constant))
  ;   :float (Node.constant type node.constant)))

(macro vectorizedConstImplUnop [op ...]
  (fn vectorizeUnop [op]
    `(fn [operation# type# lhs#]
      ; (print operation# lhs#)
      (Node.constant type#
        (if (= (type lhs#.constant) :table)
            (icollect [_# l# (ipairs lhs#.constant)] (,op l#))
            (,op lhs#.constant)))))
  `(each [_# op# (ipairs [,...])]
    (tset Node.constantImpl op# ,(vectorizeUnop op))))

(macro vectorizedConstImplBinop [op ...]
  (fn vectorizeBinop [op]
    `(fn [operation# type# lhs# rhs#]
      ; (print operation# lhs# rhs#)
      (Node.constant type#
        (if (= (type lhs#.constant) :table) ; both are already of the correct type so must match.
            (icollect [i# l# (ipairs lhs#.constant)]
              (,op l# (. rhs#.constant i#)))
            (,op lhs#.constant rhs#.constant)))))
  `(each [_# op# (ipairs [,...])]
    (tset Node.constantImpl op# ,(vectorizeBinop op))))


(each [_ op (ipairs [:OpSConvert :OpUConvert :OpFConvert :OpConvertSToF :OpConvertUToF :OpConvertFToS :OpConvertFToU])]
  (tset Node.constantImpl op Node.aux.constIntFloatConvert))

(vectorizedConstImplUnop -
  :OpFNegate :OpSNegate)

(vectorizedConstImplUnop bnot
  :OpNot)

(vectorizedConstImplUnop not
  :OpLogicalNot)

(vectorizedConstImplBinop +
  :OpFAdd :OpIAdd)

(vectorizedConstImplBinop -
  :OpFSub :OpISub)

(vectorizedConstImplBinop *
  :OpFMul :OpIMul)

(vectorizedConstImplBinop /
  :OpFDiv :OpSDiv :OpUDiv)

(vectorizedConstImplBinop %
  :OpFMod :OpSMod :OpUMod)

(vectorizedConstImplBinop ^
  :GLSLPow)

(vectorizedConstImplBinop and
  :OpLogicalAnd)

(vectorizedConstImplBinop or
  :OpLogicalOr)

(vectorizedConstImplBinop band
  :OpBitwiseAnd)

(vectorizedConstImplBinop bor
  :OpBitwiseOr)

(vectorizedConstImplBinop bxor
  :OpBitwiseXor)

(vectorizedConstImplBinop <
  :OpSLessThan :OpULessThan :OpFOrdLessThan)
  
(vectorizedConstImplBinop <=
  :OpSLessThanEqual :OpULessThanEqual :OpFOrdLessThanEqual)

(vectorizedConstImplBinop >=
  :OpSGreaterThanEqual :OpUGreaterThanEqual :OpFGreaterThanEqual)

(vectorizedConstImplBinop >
  :OpSGreaterThan :OpUGreaterThan :OpFGreaterThan)

(vectorizedConstImplBinop =
  :OpIEqual :OpFOrdEqual :OpLogicalEqual)

(vectorizedConstImplBinop not=
  :OpINotEqual :OpFOrdNotEqual :OpLogicalNotEqual)


(fn Node.aux.constantImplMin [_ ty lhs rhs]
  (Node.constant ty
    (if (= (type lhs.constant) :table) ; both are already of the correct type so must match.
        (icollect [i l (ipairs lhs.constant)]
          (math.min l (. rhs.constant i)))
        (math.min lhs.constant rhs.constant))))

(fn Node.aux.constantImplMax [_ ty lhs rhs]
  (Node.constant ty
    (if (= (type lhs.constant) :table) ; both are already of the correct type so must match.
        (icollect [i l (ipairs lhs.constant)]
          (math.max l (. rhs.constant i)))
        (math.max lhs.constant rhs.constant))))

(set Node.constantImpl.GLSLFMin Node.aux.constantImplMin)
(set Node.constantImpl.GLSLSMin Node.aux.constantImplMin)
(set Node.constantImpl.GLSLUMin Node.aux.constantImplMin)
(set Node.constantImpl.GLSLFMax Node.aux.constantImplMax)
(set Node.constantImpl.GLSLSMax Node.aux.constantImplMax)
(set Node.constantImpl.GLSLUMax Node.aux.constantImplMax)

(fn Node.constantImpl.GLSLFma [_ type v0 v1 v2]
  (+ (* v0 v1) v2))

;
; Spec constant ops supported by Shader capability.
; Some listed in the spec are handled elsewhere as they do not have trivial (all id) operands.
;

(local specConstantShaderOps
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

(each [_ op (ipairs specConstantShaderOps)]
  (tset Node.specConstantImpl op Node.aux.makeSpecConstantOpInternal))

;
; Binary arithmetic operations
;

(set Node.neg
  (nodeSimpleUnop { :name :negate :sint :OpSNegate :uint :OpSNegate :float :OpFNegate }))

(set Node.add
  (nodeSimpleBinop { :name :add :sint :OpIAdd :uint :OpIAdd :float :OpFAdd }))

(set Node.sub
  (nodeSimpleBinop { :name :subtract :sint :OpISub :uint :OpISub :float :OpFSub }))

(set Node.aux.mul
  (nodeSimpleBinop { :name :multiply :sint :OpIMul :uint :OpIMul :float :OpFMul }))

(set Node.div
  (nodeSimpleBinop { :name :divide :sint :OpSDiv :uint :OpUDiv :float :OpFDiv }))

(set Node.mod
  (nodeSimpleBinop { :name :modulate :sint :OpSMod :uint :OpUMod :float :OpFMod }))

(set Node.lsl
  (nodeSimpleBinop { :name "logical shift left" :sint :OpShiftLeftLogical :uint :OpShiftLeftLogical }))

(set Node.lsr
  (nodeSimpleBinop { :name "logical shift right" :sint :OpShiftRightLogical :uint :OpShiftRightLogical }))

(set Node.asr
  (nodeSimpleBinop { :name "arithmetic shift right" :sint :OpShiftRightArithmetic :uint :OpShiftRightArithmetic }))

(set Node.rshift
  (nodeSimpleBinop { :name "shift right" :sint :OpShiftRightArithmetic :uint :OpShiftRightLogical }))

(set Node.band
  (nodeSimpleBinop { :name "binary and" :sint :OpBitwiseAnd :uint :OpBitwiseAnd }))
  
(set Node.bor
  (nodeSimpleBinop { :name "binary or" :sint :OpBitwiseOr :uint :OpBitwiseOr }))
  
(set Node.bxor
  (nodeSimpleBinop { :name "binary exclusive or" :sint :OpBitwiseXor :uint :OpBitwiseXor }))
  

(set Node.lt?
  (nodeCompareBinop { :sint :OpSLessThan :uint :OpULessThan :float :OpFOrdLessThan }))

(set Node.gt?
  (nodeCompareBinop { :sint :OpSGreaterThan :uint :OpUGreaterThan :float :OpFOrdGreaterThan }))

(set Node.eq?
  (nodeCompareBinop { :sint :OpIEqual :uint :OpIEqual :float :OpFOrdEqual :bool :OpLogicalEqual }))

(set Node.neq?
  (nodeCompareBinop { :sint :OpINotEqual :uint :OpINotEqual :float :OpFOrdNotEqual :bool :OpLogicalNotEqual }))

(set Node.lte?
  (nodeCompareBinop { :sint :OpSLessThanEqual :uint :OpULessThanEqual :float :OpFOrdLessThanEqual }))

(set Node.gte?
  (nodeCompareBinop { :sint :OpSGreaterThanEqual :uint :OpUGreaterThanEqual :float :OpFOrdGreaterThanEqual }))


(set Node.bnot
  (nodeSimpleUnop { :name "binary not" :sint :OpNot :uint :OpNot }))

(set Node.breverse
  (nodeSimpleUnop { :name "binary reverse" :sint :OpBitReverse :uint :OpBitReverse }))

(set Node.bcount
  (nodeSimpleUnop { :name "bit count" :sint :OpBitCount :uint :OpBitCount }))


; TODO: bitfield insert/extract


(set Node.infinite?
  (nodeCompareUnop { :name "check infiniteness" :float :OpIsInf }))

(set Node.nan?
  (nodeCompareUnop { :name "check for NaN" :float :OpIsNan }))

(set Node.unordered
  { :lt? (nodeCompareBinop { :float :OpFUnordLessThan })
    :gt? (nodeCompareBinop { :float :OpFUnordGreaterThan })
    :eq? (nodeCompareBinop { :float :OpFUnordEqual })
    :neq? (nodeCompareBinop { :float :OpFUnordNotEqual })
    :lte? (nodeCompareBinop { :float :OpFUnordLessThanEqual })
    :gte? (nodeCompareBinop { :float :OpFUnordGreaterThanEqual })
  })


(set Node.!
  (nodeSimpleUnop { :name "logical not" :bool :OpLogicalNot }))

(set Node.aux.|
  (nodeSimpleBinop { :name "take disjunction of" :bool :OpLogicalOr }))
  
(set Node.aux.&
  (nodeSimpleBinop { :name "take conjunction of" :bool :OpLogicalAnd }))

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
  
  (local lhs (if (node? lhs) lhs ((rhs.type:primElem) lhs)))
  (local rhs (if (node? rhs) rhs ((lhs.type:primElem) rhs)))

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
      (do (local outElem (Type.primCommonSupertype lt.elem rt))
          (local outVec (Type.vector outElem lt.count))
          (Node.aux.op
            :OpVectorTimesScalar
            outVec
            (Node.convert lhs outVec) (Node.convert rhs outElem)))
    
    (where ({:kind k} {:kind :vector :elem {:kind vk}}) (or (= k :float) (and (= k :int) (= vk :float))))
      (do (local outElem (Type.primCommonSupertype lt rt.elem))
          (local outVec (Type.vector outElem rt.count))
          (Node.aux.op
            :OpVectorTimesScalar
            outVec
            (Node.convert rhs outVec) (Node.convert lhs outElem)))

    _ (Node.aux.mul lhs rhs)
  ))


(fn Node.dot [lhs rhs]
  (local lhs (Node.aux.autoderef lhs))
  (local rhs (Node.aux.autoderef rhs))
  
  (assert (and (node? lhs) (node? rhs)) "Dot product arguments must be vectors.")

  ; TODO: expose packed dot products, OpSUDot and Op{S,U,SU}DotAccSat via another function with options
  (local outType (Type.primCommonSupertype lhs.type rhs.type))

  (local (outPrim outCount) (outType:primCount))

  (if (= outCount 1)
    (Node.aux.mul (outPrim lhs) (outPrim rhs)) ; might as well allow this for more generic code
    (do 
      (local opcode 
        (case outPrim
          {:kind :float} :OpDot
          {:kind :int :signed true} :OpSDot
          {:kind :int :signed false} :OpUDot
          _ (error (.. "Cannot take dot product of value with type: " outPrim.summary))))
      (Node.aux.op
        opcode outPrim (outType lhs) (outType rhs)))))


(fn Node.d/dx [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:primCount))
  (local outType (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpDPdx outType (outType value)))

(fn Node.d/dy [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:primCount))
  (local outType (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpDPdy outType (outType value)))

(fn Node.fwidth [value]
  (local value (Node.aux.autoderef value))
  (local (prim count) (value.type:primCount))
  (local outType (Type.vector (Type.float 32) count))
  (Node.aux.op
    :OpFwidth outType (outType value)))


;
; Image operations
; 

(fn Node.sampledWith [image sampler]
  (local image (Node.aux.autoderef image))
  (local sampler (Node.aux.autoderef sampler))
  (assert (= sampler.type.kind :sampler)
    (.. "Cannot sample image with non-sampler, got: " (tostring sampler)))
  (Node.aux.op :OpSampledImage (Type.sampled image.type) image sampler))

(local constOffsetsType (Type.array (Type.vector i32 2) 4))

(local imageCoordDims
  { :1D 1
    :2D 2
    :3D 3
    :Cube 3
    :Buffer 1
    :SubpassData 2 ; but must be constant [0, 0]
    ; other types are not allowed or cannot be sampled
  })

(local imageOpCoordType
  { :Sample f32
    :Fetch u32
    :Gather f32
    :Write u32
  })


(fn Node.aux.imageCoord [imageType imageOp coord ?proj]
  (local coord (Node.aux.autoderef coord))

  (local baseCoordCount (. imageCoordDims imageType.dim.tag))
  (local (defaultCoordPrim reqCoordCount)
    (values (. imageOpCoordType imageOp)
            (+ baseCoordCount (if (or imageType.array ?proj) 1 0))))

  (local coordPrim (if (node? coord) (coord.type:primCount) defaultCoordPrim))

  (local resultPrim (if (= coordPrim.kind defaultCoordPrim.kind) coordPrim defaultCoordPrim))
  (local coordType (Type.vector resultPrim reqCoordCount))
  (coordType coord))


(fn Node.queryImageSize [image]
  (local image (Node.image image))
  (local imageType image.type)
  (local coords (. imageCoordDims imageType.dim.tag))
  (local resultType (Type.vector u32 coords))
  (Node.aux.op :OpImageQuerySize resultType image))


(fn Node.queryImageSizeLod [image lod]
  (local image (Node.image image))
  (local imageType image.type)
  (local coords (. imageCoordDims imageType.dim.tag))
  (local resultType (Type.vector u32 coords))
  (Node.aux.op :OpImageQuerySizeLod resultType image (u32 lod)))
  

(fn Node.queryImageLod [image coord]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :sampledImage) (.. "Cannot query lod from non-sampled image type: " image.type.summary))
  (local imageType image.type.image)
  (local coord (Node.aux.imageCoord imageType :Sample coord))
  (Node.aux.op :OpImageQueryLod (Type.vector f32 2) image coord))


(fn Node.queryImageLevels [image]
  (local image (Node.image image))
  (local imageType image.type)
  (Node.aux.op :OpImageQueryLevels u32 image))


(fn Node.queryImageSamples [image]
  (local image (Node.image image))
  (local imageType image.type)
  (Node.aux.op :OpImageQuerySamples u32 image))
 

; utility to help make all the various instructions appear more uniform
(fn Node.aux.collectImageOperands [...]
  (local imageOpProperties {})
  (local imageOperandsList [])
  (fn go [...]
    (local (consumed newValue)
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

        :Sparse (do (set imageOpProperties.Sparse true) 1)
        :Proj (do (set imageOpProperties.Proj true) 1)
        (:Dref d) (do (set imageOpProperties.Dref d) 2)
      ))
    (when (not= nil newValue)
      (table.insert imageOperandsList newValue))
    (if (not= nil consumed)
      (go (select (+ consumed 1) ...))))

  (go ...)

  (local imageOperands
    (if (not= 0 (# imageOperandsList))
      (ImageOperands (table.unpack imageOperandsList))))
  (values imageOpProperties imageOperands))

(fn Node.aux.reifyImageOperands [ctx ops]
  (base.mapOperands ops (fn [arg desc]
    (if (node? arg) (ctx:nodeID arg)
        (enum? arg) arg))))

(fn nodeReifyImageOp [self ctx]
  (local tid (ctx:typeID self.type))
  (local argIDs
    (icollect [_ arg (ipairs self.operands)]
      (if (enum? arg) (Node.aux.reifyImageOperands ctx arg)
          (node? arg) (ctx:nodeID arg))))
  (local id (ctx:freshID))
  (local op ((. Op self.operation) tid id (table.unpack argIDs)))
  (ctx:instruction op)
  id)


(local imageFormatComponentCount
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

(fn Node.aux.imageWrite [ctx image coord texel ...]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :image) (.. "Cannot write texel data to non-image type: " image.type.summary))
  (assert (= image.type.usage :storage) (.. "Cannot write texel data to non-storage image: " image.type.summary))
  (local imageType image.type)

  (local (properties imageOperands) (Node.aux.collectImageOperands ...))
  
  (assert (not (or properties.Proj (not= nil properties.Dref) properties.Sparse))
          (.. "Invalid additional options :Proj/:Dref/:Sparse specified for image write: " image.type.summary))

  (assert (not (or (?. imageOperands :Bias)
                  ;  (and (not sampledImage?) (?. imageOperands :Lod))
                   (?. imageOperands :Grad)
                   (?. imageOperands :ConstOffsets)
                   (?. imageOperands :MinLod)
                   (?. imageOperands :MakeTexelVisible)))
          (.. "Invalid image operands present for image write: " (tostring imageOperands) " " image.type.summary))
  
  (local coord (Node.aux.imageCoord imageType :Write coord))

  (local texel (Node.aux.autoderef texel))
  (assert (node? texel) "Texel value for image write must be a typed node. Try casting to a vector if necessary.")
  (local (texelPrim texelCount) (texel.type:primCount))

  (when (not= imageType.format.tag :Unknown)
    (assert (>= texelCount (. imageFormatComponentCount imageType.format.tag))
            (.. "Input texel has too few components for image format: " texel.type.summary imageType.format.tag)))

  (local texelFinalType (Type.vector imageType.elem texelCount))
  (local texel (texelFinalType texel))

  (local baseCoordCount (. imageCoordDims imageType.dim.tag))
  (local baseVecI32 (Type.vector i32 baseCoordCount))
  (local imageOperands
    (if imageOperands (base.mapOperands imageOperands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (baseVecI32 arg)
        :Offset (baseVecI32 arg)
        :Sample (u32 arg)
      )))))

  (local op
    (Op.OpImageWrite
      (ctx:nodeID image) (ctx:nodeID coord) (ctx:nodeID texel)
      (if imageOperands (Node.aux.reifyImageOperands ctx imageOperands))))

  (ctx:instruction op))

(fn Node.sample [image coord ...]
  (local image (Node.aux.autoderef image))
  (assert (= image.type.kind :sampledImage) (.. "Cannot sample from non-sampled image type: " image.type.summary))
  (local imageType image.type.image)

  (local (properties imageOperands) (Node.aux.collectImageOperands ...))
  (assert (not (and properties.Proj imageType.array))
          (.. "Cannot use Projective sampling on an Array image: " image.type.summary))
  
  (local coord (Node.aux.imageCoord imageType :Sample coord properties.Proj))

  (local explicitLod?
    (or (?. imageOperands :Lod) (?. imageOperands :Grad)))
  
  (assert (not (or (and explicitLod? (?. imageOperands :Bias))
                   (and (?. imageOperands :Lod) (?. imageOperands :Grad))
                   (and (or explicitLod? (?. imageOperands :Lod)) (?. imageOperands :MinLod))
                   (?. imageOperands :ConstOffsets)
                   (?. imageOperands :MakeTexelAvailable)
                   (?. imageOperands :MakeTexelVisible)))
          (.. "Invalid image operands present for image sample: " (tostring imageOperands)))
  
  (local resultCount (if properties.Dref 1 4))
  (var resultType (Type.vector imageType.elem resultCount))
  (when properties.Sparse 
    (set resultType (Type.struct [i32 resultType] [:0 :1])))

  (local dref (if (not= nil properties.Dref) (f32 properties.Dref)))

  (local operands [image coord])
  (when dref (table.insert operands dref))

  (local baseCoordCount (. imageCoordDims imageType.dim.tag))
  (local baseVecF32 (Type.vector f32 baseCoordCount))
  (local baseVecI32 (Type.vector i32 baseCoordCount))
  (local imageOperands
    (if imageOperands (base.mapOperands imageOperands (fn [arg desc tag]
      (case tag
        :Lod (f32 arg)
        :Grad (baseVecF32 arg)
        :ConstOffset (baseVecI32 arg)
        :Offset (baseVecI32 arg)
        :ConstOffsets (constOffsetsType arg)
        :Sample (u32 arg)
        :MinLod (f32 arg)
      )))))

  (when imageOperands
    (table.insert operands imageOperands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      "Sample"
      (if properties.Proj :Proj "")
      (if (not= nil properties.Dref) :Dref "")
      (if explicitLod?
        :ExplicitLod :ImplicitLod)))

  (Node.new
    { :kind :expr
      :type resultType
      :operation opcode
      :operands operands
      :reify nodeReifyImageOp
    }))


(fn Node.gather [image coord component? ...]
  (local image (Node.aux.autoderef image)) ; allow fetch on sampled images by extracting image from combined object
  (assert (= image.type.kind :sampledImage) (.. "Cannot gather from non-sampled image type: " image.type.summary))
  (local imageType image.type.image)

  (local coord (Node.aux.imageCoord imageType :Gather coord))
  
  (local (properties imageOperands) 
    (if (not= :string (type component?))
      (Node.aux.collectImageOperands ...)
      (Node.aux.collectImageOperands component? ...)))

  (local component? (if (not= :string (type component?)) component?))

  (assert (not properties.Proj)
          (.. "Cannot use Projective coordinates in image gather: " imageType.summary))

  (assert (not (or (?. imageOperands :Bias)
                  ;  (?. imageOperands :Lod)
                   (?. imageOperands :Grad)
                   (?. imageOperands :MinLod)
                   (?. imageOperands :MakeTexelAvailable)
                   (?. imageOperands :MakeTexelVisible)))
          (.. "Invalid image operands present for image gather: " (tostring imageOperands)))

  (var resultType (Type.vector imageType.elem 4))
  (when properties.Sparse 
    (set resultType (Type.struct [i32 resultType] [:0 :1])))

  (local baseCoordCount (. imageCoordDims imageType.dim.tag))
  (local baseVecI32 (Type.vector i32 baseCoordCount))
  (local imageOperands
    (if imageOperands (base.mapOperands imageOperands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (baseVecI32 arg)
        :ConstOffsets (constOffsetsType arg)
        :Offset (baseVecI32 arg)
        :Sample (u32 arg)
      )))))

  (assert (not (and (not= nil properties.Dref) component?))
          "Image gather operation must either use :Dref or provide component index, but not both")

  (local drefOrComponent 
    (if (not= nil properties.Dref) (f32 properties.Dref)
        component? (u32 component?)
        (u32 0)))

  (local operands [image coord drefOrComponent])
  (when imageOperands
    (table.insert operands imageOperands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      (if (not= nil properties.Dref) :Dref "")
      "Gather"))

  (Node.new
    { :kind :expr
      :type resultType
      :operation opcode
      :operands operands
      :reify nodeReifyImageOp
    }))


(fn Node.image [maybeSampledImage]
  (local maybeSampledImage (Node.aux.autoderef maybeSampledImage))
  (case maybeSampledImage.type.kind
    :image maybeSampledImage
    :sampledImage (Node.aux.op :OpImage maybeSampledImage.type.image maybeSampledImage)
    other (error (.. "Cannot extract image from non-(sampled-)image argument: " maybeSampledImage.type.summary))))


(fn Node.fetch [image coord ...]
  (local image (Node.image image)) ; allow fetch on sampled images by extracting image from combined object
  (local imageType image.type)
  (local sampledImage? (= imageType.usage :texture))

  (assert (not (and sampledImage? (= imageType.dim.tag :Cube)))
    (.. "Cannot fetch from cube image: " image.type.summary))

  (local coord (Node.aux.imageCoord imageType :Fetch coord))
  
  (local (properties imageOperands) (Node.aux.collectImageOperands ...))
  (assert (not (or properties.Proj properties.Dref))
          (.. "Cannot use Projective or Depth in image fetch/read: " image.type.summary))

  (assert (not (or (?. imageOperands :Bias)
                   (and (not sampledImage?) (?. imageOperands :Lod))
                   (?. imageOperands :Grad)
                   (?. imageOperands :ConstOffsets)
                   (?. imageOperands :MinLod)
                   (?. imageOperands :MakeTexelAvailable)
                   (and sampledImage? (?. imageOperands :MakeTexelVisible))))
          (.. "Invalid image operands present for image fetch/read: " (tostring imageOperands) " " image.type.summary))
  
  (var resultType (Type.vector imageType.elem 4))
  (when properties.Sparse 
    (set resultType (Type.struct [i32 resultType] [:0 :1])))

  (local baseCoordCount (. imageCoordDims imageType.dim.tag))
  (local baseVecI32 (Type.vector i32 baseCoordCount))
  (local imageOperands
    (if imageOperands (base.mapOperands imageOperands (fn [arg desc tag]
      (case tag
        :Lod (u32 arg)
        :ConstOffset (baseVecI32 arg)
        :Offset (baseVecI32 arg)
        :Sample (u32 arg)
      )))))

  (local operands [image coord])
  (when imageOperands
    (table.insert operands imageOperands))

  (local opcode
    (.. "OpImage"
      (if properties.Sparse :Sparse "")
      (if sampledImage? "Fetch" "Read")))

  (Node.new
    { :kind :expr
      :type resultType
      :operation opcode
      :operands operands
      :reify nodeReifyImageOp
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

(fn Node.subgroup.inverseBallot [value]
  (Node.aux.op :OpGroupNonUniformInverseBallot bool SubgroupScope (uvec4 value)))

(fn Node.subgroup.inverseBallotAtIndex [value index]
  (Node.aux.op :OpGroupNonUniformBallotBitExtract bool SubgroupScope (uvec4 value) (u32 index)))
  
(fn Node.subgroup.ballotBitCount [value]
  (Node.aux.op :OpGroupNonUniformBallotBitCount u32 SubgroupScope (uvec4 value)))
  
(fn Node.subgroup.ballotLSB [value]
  (Node.aux.op :OpGroupNonUniformBallotFindLSB u32 SubgroupScope (uvec4 value)))
  
(fn Node.subgroup.ballotMSB [value]
  (Node.aux.op :OpGroupNonUniformBallotFindMSB u32 SubgroupScope (uvec4 value)))

(fn Node.subgroup.broadcast [value index]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.broadcastQuad [value index]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformQuadBroadcast value.type SubgroupScope value (u32 index)))

(fn Node.subgroup.broadcastFirst [value]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot broadcast non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcastFirst value.type SubgroupScope value))

(fn Node.subgroup.swapQuad [value direction]
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

(fn Node.subgroup.shuffleXor [value mask]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 mask)))

(fn Node.subgroup.shuffleUp [value delta]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 delta)))
  
(fn Node.subgroup.shuffleDown [value delta]
  (local value (Node.aux.autoderef value))
  (case value.type.kind
    (where (or :int :float :bool :vector)) nil
    _ (error (.. "Cannot shuffle non-vector non-scalar value, got: " value.type.summary)))
  (Node.aux.op :OpGroupNonUniformBroadcast value.type SubgroupScope value (u32 delta)))

(fn nodeSubgroupOp [{ :name name :sint sintOp :uint uintOp :float floatOp :bool boolOp }]
  (fn [value ?groupOp ?cluster]
    (local value (Node.aux.autoderef value))
    (local (prim count) (value.type:primCount))
    (local opcode
      (case prim
        {:kind :int : signed} (if signed sintOp uintOp)
        {:kind :float} floatOp
        {:kind :bool} boolOp
        _ (error (.. "Cannot " name " values (within subgroup) of type: " value.type.summary))))
    (local groupOp
      (if 
        (= nil ?groupOp) GroupOperation.Reduce
        (= (enum? ?groupOp) :GroupOperation) ?groupOp
        (= (type ?groupOp) :string) (. GroupOperation ?groupOp)
        (error (.. "Unrecognized group operation: " (tostring ?groupOp)))))
    (local cluster
      (case groupOp.tag
        :ClusteredReduce
          (do (assert ?cluster "Cluster size required for ClusteredReduce subgroup operation.")
              (local ?cluster (u32 ?cluster))
              (assert (or (= ?cluster.kind :constant) (= ?cluster.kind :specConstant))
                (.. "Cluster size argument must be constant, got: " (tostring ?cluster)))
              ?cluster)
        (where (or :PartitionedReduceNV :PartitionedInclusiveScanNV :PartitionedExclusiveScanNV))
          (do (assert ?cluster "Partition required for PartitionedNV subgroup operation.")
              (uvec4 ?cluster))))
    
    (Node.aux.op opcode value.type SubgroupScope groupOp value cluster)))


(set Node.subgroup.add
  (nodeSubgroupOp { :name "add" :sint :OpGroupNonUniformIAdd :uint :OpGroupNonUniformIAdd :float :OpGroupNonUniformFAdd }))

(set Node.subgroup.mul
  (nodeSubgroupOp { :name "multiply" :sint :OpGroupNonUniformIMul :uint :OpGroupNonUniformIMul :float :OpGroupNonUniformFMul }))

(set Node.subgroup.min
  (nodeSubgroupOp { :name "find minimum" :sint :OpGroupNonUniformSMin :uint :OpGroupNonUniformUMin :float :OpGroupNonUniformFMin }))
  
(set Node.subgroup.max
  (nodeSubgroupOp { :name "find maximum" :sint :OpGroupNonUniformSMax :uint :OpGroupNonUniformUMax :float :OpGroupNonUniformFMax }))

(set Node.subgroup.band
  (nodeSubgroupOp { :name "bitwise and" :sint :OpGroupNonUniformBitwiseAnd :uint :OpGroupNonUniformBitwiseAnd }))
  
(set Node.subgroup.bor
  (nodeSubgroupOp { :name "bitwise or" :sint :OpGroupNonUniformBitwiseOr :uint :OpGroupNonUniformBitwiseOr }))
  
(set Node.subgroup.bxor
  (nodeSubgroupOp { :name "bitwise xor" :sint :OpGroupNonUniformBitwiseXor :uint :OpGroupNonUniformBitwiseXor }))
  
(set Node.subgroup.and
  (nodeSubgroupOp { :name "logical and" :bool :OpGroupNonUniformLogicalAnd }))
  
(set Node.subgroup.or
  (nodeSubgroupOp { :name "logical or" :bool :OpGroupNonUniformLogicalAnd }))
  
(set Node.subgroup.xor
  (nodeSubgroupOp { :name "logical xor" :bool :OpGroupNonUniformLogicalAnd }))


(fn Node.subgroup.all? [value]
  (Node.aux.op :OpSubgroupAllKHR bool (bool value)))

(fn Node.subgroup.any? [value]
  (Node.aux.op :OpSubgroupAnyKHR bool (bool value)))

(fn Node.subgroup.eq? [value]
  (Node.aux.op :OpSubgroupAllEqualKHR bool (bool value)))

(fn Node.subgroup.partitionNV [value]
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
    (assert (or (= cluster.kind :constant) (= cluster.kind :specConstant))
      (.. "Rotation clustering argument must be constant, got: " cluster)))

  (Node.aux.op :OpGroupNonUniformRotateKHR value.type SubgroupScope value delta cluster))

;
; Atomics
;

(set Node.atomic {})

(fn Node.aux.validateAtomicElem [type]
  (assert (or (= type.kind :int) (= type.kind :float))
    (.. "Atomically accessed value must be scalar integer or float, got: " type.summary)))
    
(fn Node.aux.validateAtomicElemInt [type]
  (assert (= type.kind :int))
    (.. "Atomically accessed value must be scalar integer, got: " type.summary))

(fn Node.aux.atomicScopeValue [scope]
  (Node.aux.enumValue Scope scope))

(fn Node.aux.atomicMemorySemanticsValue [memorySemantics]
  (Node.aux.enumValue MemorySemantics memorySemantics))

(fn Node.atomic.load [ptr scope memorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElem ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
  (Node.aux.op :OpAtomicLoad ptr.type.elem ptr scope memorySemantics))
  
(fn Node.aux.atomicStore [ctx ptr value scope memorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElem ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
  (ctx:instruction
    (Op.OpAtomicStore
      (ctx:nodeID ptr)
      (ctx:nodeID scope)
      (ctx:nodeID memorySemantics)
      (ctx:nodeID (ptr.type.elem value)))))

(fn Node.atomic.swap [ptr value scope memorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElem ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
  (Node.aux.op :OpAtomicExchange ptr.type.elem ptr scope memorySemantics (ptr.type.elem value)))

(fn Node.atomic.compareSwap [ptr value compareValue scope eqMemorySemantics uneqMemorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElem ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local eqMemorySemantics (Node.aux.atomicMemorySemanticsValue eqMemorySemantics))
  (local uneqMemorySemantics (Node.aux.atomicMemorySemanticsValue uneqMemorySemantics))
  (Node.aux.op :OpAtomicCompareExchange ptr.type.elem ptr scope eqMemorySemantics uneqMemorySemantics (ptr.type.elem value) (ptr.type.elem compareValue)))

(fn Node.atomic.increment [ptr scope memorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElemInt ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
  (Node.aux.op :OpAtomicIIncrement ptr.type.elem ptr scope memorySemantics))
  
(fn Node.atomic.decrement [ptr scope memorySemantics]
  (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
  (Node.aux.validateAtomicElemInt ptr.type.elem)
  (local scope (Node.aux.atomicScopeValue scope))
  (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
  (Node.aux.op :OpAtomicIDecrement ptr.type.elem ptr scope memorySemantics))

(fn nodeAtomicBinop [{ :name name :sint sintOp :uint uintOp :float floatOp }]
  (fn [ptr value scope memorySemantics]
    (assert (= ptr.type.kind :pointer) (.. "Atomic access must be to pointer, got: " (tostring ptr)))
    (Node.aux.validateAtomicElem ptr.type.elem)
    (local scope (Node.aux.atomicScopeValue scope))
    (local memorySemantics (Node.aux.atomicMemorySemanticsValue memorySemantics))
    (local opcode
      (case ptr.type.elem
        {:kind :int : signed} (if signed sintOp uintOp)
        {:kind :float} floatOp
        _ (error (.. "Cannot atomically " name " values of type: " ptr.type.elem.summary))))
    (Node.aux.op opcode ptr.type.elem ptr scope memorySemantics (ptr.type.elem value))))

(set Node.atomic.add
  (nodeAtomicBinop { :name "add" :sint :OpAtomicIAdd :uint :OpAtomicIAdd :float :OpAtomicFAddEXT }))

(set Node.aux.atomicSub
  (nodeAtomicBinop { :name "subtract" :sint :OpAtomicISub :uint :OpAtomicISub }))

(fn Node.atomic.sub [ptr value scope memorySemantics]
  (case (?. ptr :type :elem :kind)
    :float (Node.atomic.add [ptr (- (ptr.type.elem value)) scope memorySemantics])
    _ (Node.aux.atomicSub ptr value scope memorySemantics)))
  
(set Node.atomic.min
  (nodeAtomicBinop { :name "take minimum" :sint :OpAtomicSMin :uint :OpAtomicUMin :float :OpAtomicFMinEXT }))

(set Node.atomic.max
  (nodeAtomicBinop { :name "take maximum" :sint :OpAtomicSMax :uint :OpAtomicUMax :float :OpAtomicFMaxEXT }))

(set Node.atomic.band
  (nodeAtomicBinop { :name "binary and" :sint :OpAtomicAnd :uint :OpAtomicAnd }))
  
(set Node.atomic.bor
  (nodeAtomicBinop { :name "binary or" :sint :OpAtomicOr :uint :OpAtomicOr }))
  
(set Node.atomic.bxor
  (nodeAtomicBinop { :name "binary xor" :sint :OpAtomicXor :uint :OpAtomicXor }))

;
; Primitive Emitters
;

(fn Node.aux.emitVertex [ctx]
  (ctx:instruction Op.OpEmitVertex))

(fn Node.aux.endPrimitive [ctx]
  (ctx:instruction Op.OpEndPrimitive))

(fn Node.aux.emitStreamVertex [ctx id]
  (local id (ctx:nodeID (u32 id)))
  (ctx:instruction (Op.OpEmitStreamVertex id)))

(fn Node.aux.endStreamPrimitive [ctx id]
  (local id (ctx:nodeID (u32 id)))
  (ctx:instruction (Op.OpEndStreamPrimitive id)))

;
; Mesh shader instructions
; 

(fn Node.aux.setMeshOutputs [ctx verts prims]
  (local vid (ctx:nodeID (u32 verts)))
  (local pid (ctx:nodeID (u32 prims)))
  (ctx:instruction (Op.OpSetMeshOutputsEXT vid pid)))

(fn Node.aux.emitMeshTasks [ctx x y z payload]
  (local xid (ctx:nodeID (u32 x)))
  (local yid (ctx:nodeID (u32 y)))
  (local zid (ctx:nodeID (u32 z)))

  (local payload
    (if (= nil payload) nil
      (do 
        (assert (node? payload) (.. "Payload for emitMeshTasks must be a node; cannot infer type of: " payload))
        (assert (= payload.kind :variable) (.. "Payload for emitMeshTasks must be a variable; got: " payload))
        (assert (= payload.storage StorageClass.TaskPayloadWorkgroupEXT)
                (.. "Payload for emitMeshTasks must have storage class TaskPayloadWorkgroupEXT, got: " payload.storage))
        (ctx:nodeID payload)
      )))

  (ctx:instruction (Op.OpEmitMeshTasksEXT xid yid zid payload)))

;
; Ray tracing instructions
; 

(fn Node.aux.validateRayQuery [rqy name]
  (assert (and (node? rqy) (= rqy.type.kind :pointer) (= rqy.type.elem.kind :rayQuery))
          (.. "Argument to " name " must be a pointer to a ray query, got: " (tostring rqy))))

(fn Node.aux.initializeRayQuery [ctx rqy acc flags cullmask origin tmin direction tmax]
  (Node.aux.validateRayQuery rqy :initializeRayQuery)

  (local acc (Node.aux.autoderef acc))
  (assert (and (node? acc) (= acc.type.kind :accelerationStructure))
          (.. "Argument 2 to initializeRayQuery must be an acceleration structure, got: " (tostring acc)))

  (local flags (Node.aux.enumValue spirv.RayFlags flags))

  (local vec3f32 (Type.vector (Type.float 32) 3))

  (local rqyid (ctx:nodeID rqy))
  (local accid (ctx:nodeID acc))
  (local flagsid (ctx:nodeID flags))
  (local maskid  (ctx:nodeID (u32 cullmask)))
  (local originid (ctx:nodeID (vec3f32 origin)))
  (local directionid (ctx:nodeID (vec3f32 direction)))
  (local tminid (ctx:nodeID (f32 tmin)))
  (local tmaxid (ctx:nodeID (f32 tmax)))

  (ctx:instruction (Op.OpRayQueryInitializeKHR rqyid accid flagsid maskid originid tminid directionid tmaxid)))

(fn Node.aux.terminateRayQuery [ctx rqy]
  (Node.aux.validateRayQuery rqy :terminateRayQuery)
  (local rqyid (ctx:nodeID rqy))
  (ctx:instruction (Op.OpRayQueryTerminateKHR rqyid)))

(fn Node.aux.confirmRayQueryIntersection [ctx rqy]
  (Node.aux.validateRayQuery rqy :confirmRayQueryIntersection)
  (local rqyid (ctx:nodeID rqy))
  (ctx:instruction (Op.OpRayQueryConfirmIntersectionKHR rqyid)))

(fn Node.aux.generateRayQueryIntersection [ctx rqy hitt]
  (Node.aux.validateRayQuery rqy :generateRayQueryIntersection)
  (local rqyid (ctx:nodeID rqy))
  (local hittid (ctx:nodeID (f32 hitt)))
  (ctx:instruction (Op.OpRayQueryGenerateIntersectionKHR rqyid hittid)))

; This is only done this way because proceedRayQuery can be used often while ignoring its result.
(fn Node.aux.proceedRayQuery [ctx rqy]
  (Node.aux.validateRayQuery rqy :proceedRayQuery)
  (local node (Node.aux.op :OpRayQueryProceedKHR (Type.bool) rqy))
  (ctx:nodeID node)
  node)

(fn Node.aux.getRayQueryIntersectionType [rqy intersection]
  (Node.aux.validateRayQuery rqy :getRayQueryIntersectionType)
  (local intersection (Node.aux.enumValue spirv.RayQueryIntersection intersection))
  (Node.aux.op :OpRayQueryGetIntersectionTypeKHR u32 rqy intersection))

(fn Node.aux.getRayQueryTMin [rqy]
  (Node.aux.validateRayQuery rqy :getRayQueryTMin)
  (Node.aux.op :OpRayQueryGetRayTMinKHR f32 rqy))
  
(fn Node.aux.getRayQueryFlags [rqy]
  (Node.aux.validateRayQuery rqy :getRayQueryFlags)
  (Node.aux.op :OpRayQueryGetRayFlagsKHR u32 rqy))

(fn Node.aux.getRayQueryWorldRayDirection [rqy]
  (Node.aux.validateRayQuery rqy :getRayQueryWorldRayDirection)
  (Node.aux.op :OpRayQueryGetWorldRayDirectionKHR (Type.vector f32 3) rqy))

(fn Node.aux.getRayQueryWorldRayOrigin [rqy]
  (Node.aux.validateRayQuery rqy :getRayQueryWorldRayOrigin)
  (Node.aux.op :OpRayQueryGetWorldRayOriginKHR (Type.vector f32 3) rqy))

(fn nodeRayQueryIntersectionOp [{ :op op :name name :return return }]
  (fn [rqy intersection]
    (Node.aux.validateRayQuery rqy name)
    (local intersection (Node.aux.enumValue spirv.RayQueryIntersection intersection))
    (Node.aux.op op return rqy intersection)))

(set Node.aux.getRayQueryIntersectionT
  (nodeRayQueryIntersectionOp { :op :OpRayQueryGetIntersectionTKHR :name :getRayQueryIntersectionT :return f32 }))
  
(set Node.aux.getRayQueryIntersectionInstanceCustomIndex
  (nodeRayQueryIntersectionOp { :op :OpRayQueryGetIntersectionInstanceCustomIndexKHR :name :getRayQueryIntersectionInstanceCustomIndex :return u32 }))
  
(set Node.aux.getRayQueryIntersectionInstanceShaderBindingTableRecordOffset
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionInstanceShaderBindingTableRecordOffsetKHR
      :name :getRayQueryIntersectionInstanceShaderBindingTableRecordOffset
      :return u32 
    }))
    
(set Node.aux.getRayQueryIntersectionGeometryIndex
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionGeometryIndexKHR
      :name :getRayQueryIntersectionGeometryIndex
      :return u32 
    }))
    
(set Node.aux.getRayQueryIntersectionPrimitiveIndex
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionPrimitiveIndexKHR
      :name :getRayQueryIntersectionPrimitiveIndex
      :return u32 
    }))
    
(set Node.aux.getRayQueryIntersectionBarycentrics
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionBarycentricsKHR
      :name :getRayQueryIntersectionBarycentrics
      :return (Type.vector f32 2) 
    }))

(set Node.aux.getRayQueryIntersectionFrontFace
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionFrontFaceKHR
      :name :getRayQueryIntersectionFrontFace
      :return bool 
    }))

(set Node.aux.getRayQueryIntersectionCandidateAABBOpaque
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionCandidateAABBOpaqueKHR
      :name :getRayQueryIntersectionCandidateAABBOpaque
      :return bool 
    }))

(set Node.aux.getRayQueryIntersectionObjectRayDirection
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionObjectRayDirectionKHR
      :name :getRayQueryIntersectionObjectRayDirection
      :return (Type.vector f32 3)
    }))

(set Node.aux.getRayQueryIntersectionObjectRayOrigin
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionObjectRayOriginKHR
      :name :getRayQueryIntersectionObjectRayOrigin
      :return (Type.vector f32 3)
    }))

(set Node.aux.getRayQueryIntersectionObjectToWorld
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionObjectToWorldKHR
      :name :getRayQueryIntersectionObjectToWorld
      :return (Type.matrix f32 4 3)
    }))

(set Node.aux.getRayQueryIntersectionWorldToObject
  (nodeRayQueryIntersectionOp
    { :op :OpRayQueryGetIntersectionWorldToObjectKHR
      :name :getRayQueryIntersectionWorldToObject
      :return (Type.matrix f32 4 3)
    }))

(fn Node.aux.ignoreIntersection [ctx]
  (ctx:instruction Op.OpIgnoreIntersectionKHR))

(fn Node.aux.terminateRay [ctx]
  (ctx:instruction Op.OpTerminateRayKHR))

(fn Node.aux.executeCallable [ctx sbtid callableData]
  (assert 
    (and (node? callableData)
         (= callableData.kind :variable)
         (or (= callableData.storage StorageClass.CallableDataKHR)
             (= callableData.storage StorageClass.IncomingCallableDataKHR)))
    (.. "Argument to executeCallable must be a variable with storage of "
        "CallableDataKHR or IncomingCallableDataKHR, got:" 
        (tostring callableData)))

  (local sbtid (u32 (Node.aux.autoderef sbtid)))

  (ctx:instruction
    (Op.OpExecuteCallableKHR
      (ctx:nodeID sbtid)
      (ctx:nodeID callableData))))

(fn Node.aux.reportIntersection [ctx hitT hitKind]
  (local hitKind (u32 hitKind))
  (local hitT (f32 (Node.aux.autoderef hitT)))
  (local node (Node.aux.op :OpReportIntersectionKHR bool hitT hitKind))
  (ctx:nodeID node)
  node)

(fn Node.aux.traceRay
  [ctx acc flags mask sbtOffset sbtStride missIndex rayOrigin rayTMin rayDirection rayTMax payload]
  
  (local acc (Node.aux.autoderef acc))
  (assert (and (node? acc) (= acc.type.kind :accelerationStructure))
          (.. "Argument 1 of tracyRay must be an acceleration structure, got: " (tostring acc)))

  (assert 
    (and (node? payload)
         (= payload.kind :variable)
         (or (= payload.storage StorageClass.RayPayloadKHR)
             (= payload.storage StorageClass.IncomingRayPayloadKHR)))
    (.. "Payload of traceRay must be a variable with storage of "
        "RayPayloadKHR or IncomingRayPayloadKHR, got:" 
        (tostring payload)))

  (local flags (Node.aux.enumValue spirv.RayFlags flags))
  (local mask (u32 (Node.aux.autoderef mask)))
  (local sbtOffset (u32 (Node.aux.autoderef sbtOffset)))
  (local sbtStride (u32 (Node.aux.autoderef sbtStride)))
  (local missIndex (u32 (Node.aux.autoderef missIndex)))

  (local vec3f (Type.vector f32 3))
  (local rayOrigin (vec3f (Node.aux.autoderef rayOrigin)))
  (local rayDirection (vec3f (Node.aux.autoderef rayDirection)))

  (local rayTMin (f32 (Node.aux.autoderef rayTMin)))
  (local rayTMax (f32 (Node.aux.autoderef rayTMax)))    
  
  (ctx:instruction
    (Op.OpTraceRayKHR
      (ctx:nodeID acc)
      (ctx:nodeID flags)
      (ctx:nodeID mask)
      (ctx:nodeID sbtOffset)
      (ctx:nodeID sbtStride)
      (ctx:nodeID missIndex)
      (ctx:nodeID rayOrigin)
      (ctx:nodeID rayTMin)
      (ctx:nodeID rayDirection)
      (ctx:nodeID rayTMax)
      (ctx:nodeID payload))))

;
; Barriers
; 

(fn Node.aux.controlBarrier [ctx executionScope memoryScope memorySemantics]
  (local executionScope (Node.aux.enumValue Scope executionScope))
  (local memoryScope (Node.aux.enumValue Scope memoryScope))
  (local memorySemantics (Node.aux.enumValue MemorySemantics memorySemantics))
  (ctx:instruction 
    (Op.OpControlBarrier (ctx:nodeID executionScope) 
                         (ctx:nodeID memoryScope)
                         (ctx:nodeID memorySemantics))))

(fn Node.aux.memoryBarrier [ctx memoryScope memorySemantics]
  (local memoryScope (Node.aux.enumValue Scope memoryScope))
  (local memorySemantics (Node.aux.enumValue MemorySemantics memorySemantics))
  (ctx:instruction 
    (Op.OpMemoryBarrier (ctx:nodeID (u32 memoryScope)) 
                        (ctx:nodeID (u32 memorySemantics)))))

;
; ExtGLSL operations
;

(set Node.pow
  (nodeGLSLBinop { :name "exponentiate" :float :Pow :nof64? true }))

(set Node.arctan2
  (nodeGLSLBinop { :name "compute arctangent" :float :Atan2 :nof64? true }))

(set Node.aux.max
  (nodeGLSLBinop { :name "take maximum" :sint :SMax :uint :UMax :float :FMax }))

(set Node.aux.min
  (nodeGLSLBinop { :name "take minimum" :sint :SMin :uint :UMin :float :FMin }))

(set Node.aux.nmax
  (nodeGLSLBinop { :name "take maximum (ignoring NaN)" :float :NMax }))

(set Node.aux.nmin
  (nodeGLSLBinop { :name "take minimum (ignoring NaN)" :float :NMin }))

(set Node.step
  (nodeGLSLBinop { :name "step function" :float :Step }))

(set Node.reflect
  (nodeGLSLBinop { :name "reflect across" :float :Reflect }))

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
  (nodeGLSLUnop { :name "round" :float :Round }))

(set Node.roundEven
  (nodeGLSLUnop { :name "round to nearest even" :float :RoundEven }))

(set Node.trunc
  (nodeGLSLUnop { :name "truncate" :float :Trunc }))

(set Node.floor
  (nodeGLSLUnop { :name "take floor of" :float :Floor }))

(set Node.ceil
  (nodeGLSLUnop { :name "take ceiling of" :float :Ceil }))

(set Node.fract
  (nodeGLSLUnop { :name "take fractional part of" :float :Fract }))

(set Node.degreesToRadians
  (nodeGLSLUnop { :name "convert degrees to radians" :float :Radians :nof64? true }))

(set Node.radiansToDegrees
  (nodeGLSLUnop { :name "convert radians to degrees" :float :Degrees :nof64? true }))

(set Node.sign
  (nodeGLSLUnop { :name "find sign of" :sint :SSign :float :FSign }))
  
(set Node.abs
  (nodeGLSLUnop { :name "find absolute value of" :sint :SAbs :float :FAbs }))

(set Node.sin
  (nodeGLSLUnop { :name "compute sine" :float :Sin :nof64? true }))
  
(set Node.cos
  (nodeGLSLUnop { :name "compute cosine" :float :Cos :nof64? true }))
  
(set Node.tan
  (nodeGLSLUnop { :name "compute tangent" :float :Tan :nof64? true }))
  
(set Node.arcsin
  (nodeGLSLUnop { :name "compute arcsine" :float :Asin :nof64? true }))
  
(set Node.arccos
  (nodeGLSLUnop { :name "compute arccosine" :float :Acos :nof64? true }))
  
(set Node.arctan
  (nodeGLSLUnop { :name "compute arctangent" :float :Atan :nof64? true }))
  
(set Node.sinh
  (nodeGLSLUnop { :name "compute hyperbolic sine" :float :Sinh :nof64? true }))
  
(set Node.cosh
  (nodeGLSLUnop { :name "compute hyperbolic cosine" :float :Cosh :nof64? true }))
  
(set Node.tanh
  (nodeGLSLUnop { :name "compute hyperbolic tangent" :float :Tanh :nof64? true }))
  
(set Node.arcsinh
  (nodeGLSLUnop { :name "compute hyperbolic arcsine" :float :Asinh :nof64? true }))
  
(set Node.arccosh
  (nodeGLSLUnop { :name "compute hyperbolic arccosine" :float :Acosh :nof64? true }))
  
(set Node.arctanh
  (nodeGLSLUnop { :name "compute hyperbolic arctangent" :float :Atanh :nof64? true }))
  
(set Node.exp
  (nodeGLSLUnop { :name "exponentiate" :float :Exp :nof64? true }))

(set Node.exp2
  (nodeGLSLUnop { :name "exponentiate" :float :Exp2 :nof64? true }))

(set Node.log
  (nodeGLSLUnop { :name "find natural logarithm" :float :Log :nof64? true }))

(set Node.log2
  (nodeGLSLUnop { :name "find base-2 logarithm" :float :Log2 :nof64? true }))

(set Node.sqrt
  (nodeGLSLUnop { :name "find square root" :float :Sqrt }))

(set Node.inverseSqrt
  (nodeGLSLUnop { :name "find inverse square root" :float :InverseSqrt }))

(set Node.normalize
  (nodeGLSLUnop { :name "normalize" :float :Normalize }))

(set Node.lsb
  (nodeGLSLUnop { :name "find leastSignificant bit" :sint :FindILsb :uint :FindILsb :noi64? true }))

(set Node.msb
  (nodeGLSLUnop { :name "find mostSignificant bit" :sint :FindSMsb :uint :FindUMsb :noi64? true }))

(fn Node.norm [v]
  (local f32 (Type.float 32))
  (local v (Node.aux.autoderef v))
  (local v (if (node? v) v (f32 v)))
  (var (outPrim outCount) (v.type:primCount))
  (when (= outPrim.kind :int)
    (set outPrim (Type.float 32)))
  (local outType (Type.vector outPrim outCount))
  (Node.glsl.op :Length outPrim (outType v)))

(fn Node.distance [lhs rhs]
  (local lhs (Node.aux.autoderef lhs))
  (local rhs (Node.aux.autoderef rhs))
  (local outType
    (if (and (node? lhs) (node? rhs)) (Type.primCommonSupertype lhs.type rhs.type)
        (node? lhs) lhs.type
        (node? rhs) rhs.type))
  (var (outPrim outCount) (outType:primCount))
  (when (= outPrim.kind :int)
    (set outPrim (Type.float 32)))
  (local outType (Type.vector outPrim outCount))
  (Node.glsl.op :Distance outPrim
    (outType lhs)
    (outType rhs)))

(fn Node.length [v]
  (if (not (node? v)) (# v)
    (case v.type.kind
      :array (assert v.type.count "Cannot have a reference to an unsized array which is not a pointer!")
      :pointer
        (case v.type.elem.kind
          :array
            (or v.type.count
              (do (local base (Node.aux.basePtr v))
                  (local baseType base.type.elem)
                  (assert (= baseType.kind :struct)
                    "Cannot take length of unsized array not originating from a buffer!")
                  (local fields (# baseType.fieldTypes))
                  (local finalMemberType (. baseType.fieldTypes fields))
                  (assert (= finalMemberType v.type.elem)
                    (.. "Cannot take length of unsized array not immediately nested within buffer: " baseType))
                  (Node.aux.op :OpArrayLength (Type.int 32) base (- fields 1))))
          _ (Node.norm v)
        )
      _ (Node.norm v)
      )))


(fn Node.select [cond then else]
  (local bool (Type.bool))

  (local cond (Node.aux.autoderef cond))
  (local then (Node.aux.autoderef then))
  (local else (Node.aux.autoderef else))

  (local f32 (Type.float 32))
  (local thenType (if (node? then) then.type f32))
  (local elseType (if (node? else) else.type f32))

  ; FIXME: OpSelect can also work on pointers or composites
  (local outType
    (Type.primCommonSupertype thenType elseType))

  (local (outPrim outCount) (outType:primCount))
  (local condType (Type.vector bool outCount))

  (Node.aux.op
    :OpSelect outType (condType cond) (outType then) (outType else)))


(fn Node.faceForward [v0 v1 v2]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local v2 (Node.aux.autoderef v2))
    
  (local f32 (Type.float 32))
  (local v0t (if (node? v0) v0.type f32))
  (local v1t (if (node? v1) v1.type f32))
  (local v2t (if (node? v2) v2.type f32))

  (local outType
    (Type.primCommonSupertype v0t v1t v2t))

  (Node.glsl.op :FaceForward outType (outType v0) (outType v1) (outType v2)))


(fn Node.refract [v0 v1 eta]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local eta (Node.aux.autoderef eta))
    
  (local f32 (Type.float 32))
  (local v0t  (if (node? v0)  v0.type f32))
  (local v1t  (if (node? v1)  v1.type f32))
  (local etat (if (node? eta) eta.type f32))

  (local outType
    (Type.primCommonSupertype v0t v1t etat))
  (local outPrim (outType:primCount))

  (Node.glsl.op :Refract outType (outType v0) (outType v1) (outPrim eta)))


(fn Node.smoothstep [v0 v1 vt]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local vt (Node.aux.autoderef vt))
  (if (not (or (node? v0) (node? v1) (node? vt)))
    (do
      ; FIXME: put this into constant folding definition instead of here
      (local t (/ (- vt v0) (- v1 v0)))
      (local t (math.min 1 (math.max t 0)))
      (* t t (- 3 (* t 2))))
    (do 
      (local f32 (Type.float 32))
      (local v0t (if (node? v0) v0.type f32))
      (local v1t (if (node? v1) v1.type f32))
      (local vtt (if (node? vt) vt.type f32))

      (local outType
        (Type.primCommonSupertype v0t v1t vtt))
      
      (local (outPrim outCount) (outType:primCount))
      (assert (= :float outPrim.kind) "Cannot smoothstep non-floating values.")

      (Node.glsl.op
        :SmoothStep outType (outType v0) (outType v1) (outType vt)))))


(fn Node.mix [v0 v1 vt]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
  (local vt (Node.aux.autoderef vt))
  (if (not (or (node? v0) (node? v1) (node? vt)))
    ; FIXME: put this into constant folding definition instead of here
    (+ v0 (* (- v1 v0) vt))   
    (do 
      (local f32 (Type.float 32))
      (local v0 (if (node? v0) v0 (f32 v0)))
      (local v1 (if (node? v1) v1 (f32 v1)))
      (local vt (if (node? vt) vt (f32 vt)))

      (local outType
        (Type.primCommonSupertype v0.type v1.type vt.type))
      
      (local (outPrim outCount) (outType:primCount))
      (assert (= :float outPrim.kind) "Cannot mix non-floating values.")

      (Node.glsl.op
        :FMix outType (outType v0) (outType v1) (outType vt)))))


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

      (local outType
        (Type.primCommonSupertype v0.type v1.type v2.type f32))
      
      (local (outPrim outCount) (outType:primCount))

      (Node.glsl.op
        :Fma outType (outType v0) (outType v1) (outType v2))))


(fn Node.cross [v0 v1]
  (local v0 (Node.aux.autoderef v0))
  (local v1 (Node.aux.autoderef v1))
    
  (local f32 (Type.float 32))
  (local vec3f32 (Type.vector f32 3))

  (local v0t (if (node? v0) v0.type f32))
  (local v1t (if (node? v1) v1.type f32))

  (local outType
    (Type.primCommonSupertype v0t v1t))

  (local outPrim (outType:primCount))

  (local outType 
    (case outPrim.kind
      :int vec3f32
      :float outType))

  (Node.glsl.op :Cross outType (outType v0) (outType v1)))


(fn Node.determinant [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot find determinant of non-matrix value.")
  
  (local matType mat.type)
  (assert (= matType.rows matType.cols) (.. "Argument to determinant must be a square matrix, got: " mat.type.summary))
  
  (Node.glsl.op
    :Determinant matType.elem mat))


(fn Node.matrixInverse [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot invert non-matrix value.")
  
  (local matType mat.type)
  (assert (= matType.rows matType.cols) (.. "Matrix to invert must be a square matrix, got: " mat.type.summary))
  
  (Node.glsl.op
    :MatrixInverse matType mat))


(fn Node.matrixTranspose [mat]
  (local mat (Node.aux.autoderef mat))
  (assert (and (node? mat) (= mat.type.kind :matrix)) "Cannot invert non-matrix value.")
  
  (local matType mat.type)
  (local outType (Type.matrix matType.elem matType.cols matType.rows))

  (Node.aux.op
    :OpTranspose outType mat))


(fn Node.modf [value]
  (local value (Node.aux.autoderef value))
  (if (= :number (type value)) (math.modf value)
    (do 
      (local (prim count) (value.type:primCount))
      (assert (= prim.kind :float) (.. "Argument to modf must be floating, got: " value.type.summary))

      (local outType (Type.struct [value.type value.type] [:0 :1]))

      (local modfResult
        (Node.glsl.op :ModfStruct outType value))
      (values
        modfResult.1 modfResult.0)
    )))


(fn Node.frexp [value]
  (local i32 (Type.int 32 true))

  (assert (node? value) "Argument to frexp must be node, got comptime value")
  (local value (Node.aux.autoderef value))

  (local (prim count) (value.type:primCount))
  (assert (= prim.kind :float) (.. "Argument to frexp must be floating, got: " value.type.summary))

  (local expType (Type.vector i32 count))
  (local outType (Type.struct [value.type expType] [:0 :1]))

  (local frexpResult (Node.glsl.op :FrexpStruct outType value))
  (values frexpResult.1 frexpResult.0))


(fn Node.ldexp [v exp]
  (assert (and (node? v) (node? exp)) "Arguments to ldexp must be nodes, got comptime value(s)")

  (local v (Node.aux.autoderef v))
  (local exp (Node.aux.autoderef exp))

  (local (vPrim vCount) (v.type:primCount))
  (local (expPrim expCount) (exp.type:primCount))

  (assert (= vPrim.kind :float) (.. "First argument to ldexp must be floating, got: " v.type.summary))
  (assert (= expPrim.kind :int) (.. "Second argument to ldexp must be integral, got: " exp.type.summary))

  ; done just to make sure the vector lengths are compatible
  (local supertype (Type.primCommonSupertype v.type exp.type))
  (local (_ superCount) (supertype:primCount))
  (local vType (Type.vector vPrim superCount))
  (local expType (Type.vector expPrim superCount))
  
  (Node.glsl.op :Ldexp vType (vType v) (expType exp)))

;
; pack/unpack operations
;

(set Node.packSnorm4x8
  (nodeGLSLPackOp { :op :PackSnorm4x8 :inType (Type.vector f32 4) :outType u32 }))

(set Node.packUnorm4x8
  (nodeGLSLPackOp { :op :PackUnorm4x8 :inType (Type.vector f32 4) :outType u32 }))

(set Node.packSnorm2x16
  (nodeGLSLPackOp { :op :PackSnorm2x16 :inType (Type.vector f32 2) :outType u32 }))

(set Node.packUnorm2x16
  (nodeGLSLPackOp { :op :PackUnorm2x16 :inType (Type.vector f32 2) :outType u32 }))

(set Node.packHalf2x16
  (nodeGLSLPackOp { :op :PackHalf2x16 :inType (Type.vector f32 2) :outType u32 }))

(set Node.packDouble2x32
  (nodeGLSLPackOp { :op :PackDouble2x32 :inType (Type.vector u32 2) :outType f64 }))

(set Node.unpackSnorm2x16
  (nodeGLSLPackOp { :op :UnpackSnorm2x16 :inType u32 :outType (Type.vector f32 2) }))

(set Node.unpackUnorm2x16
  (nodeGLSLPackOp { :op :UnpackUnorm2x16 :inType u32 :outType (Type.vector f32 2) }))

(set Node.unpackHalf2x16
  (nodeGLSLPackOp { :op :UnpackHalf2x16 :inType u32 :outType (Type.vector f32 2) }))

(set Node.unpackSnorm4x8
  (nodeGLSLPackOp { :op :UnpackSnorm4x8 :inType u32 :outType (Type.vector f32 4) }))
  
(set Node.unpackUnorm4x8
  (nodeGLSLPackOp { :op :UnpackUnorm4x8 :inType u32 :outType (Type.vector f32 4) }))
  
(set Node.unpackDouble2x32
  (nodeGLSLPackOp { :op :UnpackDouble2x32 :inType f64 :outType (Type.vector u32 2) }))

;
; internal node types required to support syntax and basic features
;

(fn nodeReifyReturnvalue [self ctx]
  (local id (ctx:nodeID (. self.operands 1)))
  (local op (Op.OpReturnValue id))
  (ctx:instruction op)
  id)

(fn Node.returnvalue [node]
  (Node.new
    { :kind :expr
      :type (Type.void)
      :operation :OpReturnValue
      :operands [node]
      :reify nodeReifyReturnvalue
    }))


(fn nodeReifyAccessChain [self ctx]
  (local [base indices] self.operands)
  (local tid (ctx:typeID self.type))
  (local baseID (ctx:nodeID base))
  (local indexIDs (icollect [_ index (ipairs indices)] (ctx:nodeID index)))
  (local id (ctx:freshID))
  (ctx:instruction ((. Op self.operation) tid id baseID indexIDs))
  (when (and (= base.kind :variable) (not= base.storage StorageClass.Function))
    (ctx:interfaceID baseID))
  id)

; TODO: Consider using OpInBoundsAccessChain when it is possible to do so
(fn Node.access [base index]
  ; (print :Node.access base index)
  (local index (Node.aux.autoderef index))
  (var resultType (Type.access base.type index))
  (if (and (= base.kind :expr) (= base.operation :OpAccessChain))
      (do (local [base indices] base.operands)
          (local indices (icollect [_ v (ipairs indices)] v))
          (table.insert indices index)
          (Node.accessChain base resultType indices))
    (Node.accessChain base resultType [index])))

(fn Node.accessChain [base type indices]
  (Node.new
    { :kind :expr
      :type type
      :operation :OpAccessChain
      :operands [base indices]
      :reify nodeReifyAccessChain
    }))


(fn nodeReifyExtractChain [self ctx]
  (local tid (ctx:typeID self.type))
  (local baseID (ctx:nodeID (. self.operands 1)))
  (local indices (. self.operands 2))
  (local id (ctx:freshID))
  (ctx:instruction ((. Op self.operation) tid id baseID indices))
  id)

(fn Node.extract [base index]
  (var resultType (Type.extract base.type index))
  (if (= base.kind :constant) (Node.constant resultType (. base.constant (+ index 1)))
      (and (= base.kind :expr) (= base.operation :OpCompositeExtract))
      (do (local [base indices] base.operands)
          (local indices (icollect [_ v (ipairs indices)] v))
          (table.insert indices index)
          (Node.extractChain base resultType indices))
    (Node.extractChain base resultType [index])))

(fn Node.extractChain [base type indices]
  (Node.new
    { :kind :expr
      :type type
      :operation :OpCompositeExtract
      :operands [base indices]
      :reify nodeReifyExtractChain
    }))


(fn nodeReifyExtractDynamic [self ctx]
  (local [base index] self.operands)
  (local tid (ctx:typeID self.type))
  (local baseID (ctx:nodeID base))
  (local indexID (ctx:nodeID index))
  (local id (ctx:freshID))
  (ctx:instruction (Op.OpVectorExtractDynamic tid id baseID indexID))
  id)

; Extract a dynamic index of a vector
(fn Node.extractDynamic [self index]
  (assert (= index.type.kind :int) (.. "Vector must be indexed by an integer, got: " index.type.summary))
  (Node.new
    { :kind :expr
      :type self.elem
      :operation :OpVectorExtractDynamic
      :operands [self index]
      :reify nodeReifyExtractDynamic
    }))


(fn nodeReifyShuffle [self ctx]
  (local [vec1 vec2 indices] self.operands)
  (local tid (ctx:typeID self.type))
  (local vec1ID (ctx:nodeID vec1))
  (local vec2ID (ctx:nodeID vec2))
  (local id (ctx:freshID))
  (ctx:instruction (Op.OpVectorShuffle tid id vec1ID vec2ID indices))
  id)

(fn Node.shuffle [vec1 vec2 indices]
  (assert (and (= vec1.type.kind :vector) (= vec2.type.kind :vector))
    (.. "Cannot shuffle non-vector values: " vec1.type.summary " " vec2.type.summary))
  (assert (= vec1.type.elem vec2.type.elem)
    (.. "Shuffled vectors must have the same element type, got: " vec1.type.elem.summary " " vec2.type.elem.summary))

  (local combinedCount (+ vec1.type.count vec2.type.count))
  (each [_ index (ipairs indices)]
    (assert (< -1 index combinedCount) (.. "Index not in range for shuffle: " index)))

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
        :reify nodeReifyShuffle
      })))


(local swizzleIndex
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
      (. swizzleIndex (index:sub i i))))
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
      (Node.extract self (structMemberIndex self.type index))
    (where (:vector :string) (index:match "^[xyzwrgbauvst0123]+$"))
      (Node.swizzle self index)
    (where (:vector :table) (node? index))
      (Node.extractDynamic self index)
    (where (:pointer :string))
      (do (local elem self.type.elem)
          (if (= elem.kind :struct)
                (Node.access self (u32 (structMemberIndex elem index)))
              (and (= elem.kind :vector)
                   (index:match "^[xyzwrgbauvst0123]$"))
                (Node.access self (Node.constant (Type.int 32 true) (. swizzleIndex index)))
              (= index "*")
                (Node.deref self)
              (Node.index (Node.deref self) index)))
    (where (:pointer :table) (node? index))
      (Node.access self index)
    else (error (.. "Index " (tostring index) " invalid for value: " (tostring self)))))


(fn nodeReifyFunctionCall [self ctx]
  (local [func args] self.operands)
  (local tid (ctx:typeID self.type))
  (local argIDs [])
  (each [i arg (ipairs args)]
    (table.insert argIDs (ctx:nodeID arg))
    (when (= arg.type.kind :pointer)
      (local base (Node.aux.basePointer arg))
      (when (and (= :variable base.kind) (not= base.storage StorageClass.Function))
        (ctx:interfaceID (ctx:nodeID base))))) ; already requested so won't change instructions
  (local id (ctx:freshID))
  (ctx:instruction (Op.OpFunctionCall tid id func.function.id argIDs))
  (each [iid _ (pairs func.function.interface)]
    (ctx:interfaceID iid))
  id)


(fn Node.functionCall [func args]
  (Node.new
    { :kind :expr
      :type func.function.type.return
      :operation :OpFunctionCall
      :operands [func args]
      :reify nodeReifyFunctionCall
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
        (local castArgs
          (icollect [i arg (ipairs args)] ((. self.type.params i) arg)))
        (Node.functionCall self castArgs))
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
    :constant (.. "(constant " self.type.summary " " (nodeConstantSummary self) ")")
    :specConstant (.. "(specConstant " self.type.summary (if (rawget self :operation) (.. " " self.operation) "") ")")
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