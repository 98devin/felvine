(local fennel (require :fennel))

(fn enum? [value]
  (when (= :table (type value))
    (local valueMT (getmetatable value))
    (if (?. valueMT :__enum) (?. valueMT :__name))))

(fn getCapabilities [item caps]
  (local caps (or caps {}))
  (local mt (getmetatable item))
  (local method (. mt :__capabilities))
  (when (not= nil method)
    (method item caps))
  caps)

(fn getExtensions [item exts]
  (local exts (or exts {}))
  (local mt (getmetatable item))
  (local method (. mt :__extensions))
  (when (not= nil method)
    (method item exts))
  exts)

(fn mapOperands [item f]
  (local mt (getmetatable item))
  (local method (. mt :__mapoperands))
  (if (not= nil method)
    (method item f)))

(fn serialize [buffer item]
  (local mt (getmetatable item))
  (local method (. mt :__serialize))
  (when (not= nil method)
    (method buffer item))) 

(fn serializableWith [serialize item]
  (fn wrappedSerialize [buffer o]
    (serialize buffer o.value))
  (fn wrappedToString [o]
    (tostring o.value))
  (local mt { :__serialize wrappedSerialize :__tostring wrappedToString })
  (setmetatable { :value item } mt))

(fn serizlizeTmpWith [serialize item]
  (local buffer [])
  (serialize buffer item)
  buffer)

(fn serializeTmp [item]
  (serizlizeTmpWith serialize item))

(fn serializeAppendSubBuffer [buffer subBuffer]
  (each [_ s (ipairs subBuffer)]
    (table.insert buffer s)))

(fn serializeFmt [fmt buffer ...]
  (let [s (string.pack (.. "!4<" fmt "XI4") ...)] (table.insert buffer s)))
    
(fn serializeVia [fmt] (partial serializeFmt fmt))

(fn serializableWithFmt [fmt item]
  (serializableWith (serializeVia fmt) item))
  
(fn serializeListVia [fmt]
  (fn [buffer item] (serializeFmt fmt buffer (table.unpack item))))

(fn serializeListWith [serialize buffer item]
  (each [_ v (ipairs item)] (serialize buffer v)))

(local serializeList (partial serializeListWith serialize))


(local basicSerializers {
  :Id (serializeVia "I4")                             ; u32
  :IdRef (serializeVia "I4")                          ; u32
  :IdMemorySemantics (serializeVia "I4")              ; u32
  :IdScope (serializeVia "I4")                        ; u32
  :IdResult (serializeVia "I4")                       ; u32
  :IdResultType (serializeVia "I4")                   ; u32
  :LiteralInteger (serializeVia "i4")                 ; i32
  :LiteralFloat (serializeVia "f")                    ; f32
  :LiteralString (serializeVia "z XI4")               ; string
  :LiteralExtInstInteger (serializeVia "I4")          ; u32
  :PairLiteralIntegerIdRef (serializeListVia "i4 I4") ; (i32, u32)
  :PairIdRefIdRef (serializeListVia "I4 I4")          ; (u32, u32)
})


; enumerant-value structure
; .tag      string
; .value    number
; .operands ?list[any]
(local enumerantValueProto
  { :operands []
  })

(fn valueEnumerantMT [enum]
  (local mt { :__enum true :__name enum.name })
  (set mt.__index enumerantValueProto)
  (fn mt.__eq [x y] (= x.value y.value))
  (fn mt.__lt [x y] (< x.value y.value))
  (fn mt.__le [x y] (<= x.value y.value))
  (fn mt.__tostring [v]
    (local desc (. enum.enumerants v.tag))
    (local argstrings (icollect [i arg (ipairs v.operands)]
      (let [opdesc (. desc.operands i)]
        (case opdesc.quantifier
          :* (do (local opstrings (icollect [_ v (ipairs arg)] (fennel.view v)))
                 (.. "[" (table.concat opstrings " ") "]"))
          _  (tostring arg)))))
    (if (= 0 (# desc.operands))
        (.. enum.name "." v.tag)
        (.. "(" enum.name "." v.tag " " (table.concat argstrings " ") ")")))

  (fn mt.__mapoperands [v f]
    (local desc (. enum.enumerants v.tag))
    (if (= 0 (# desc.operands)) v ; nothing to map
      (do 
        (local mappedOperands [])
        (icollect [i arg (ipairs v.operands) &into mappedOperands]
          (let [opdesc (. desc.operands i)] (f arg opdesc v.tag enum.name)))
        ((. enum v.tag) (table.unpack mappedOperands))
      )))

  (fn mt.__capabilities [v caps]
    (local desc (. enum.enumerants v.tag))
    (when desc.capabilities
      (each [_ cap (ipairs desc.capabilities)]
        (tset caps cap true)))
    (when v.operands
      (each [_ arg (ipairs v.operands)]
        (when (enum? arg) (getCapabilities arg caps)))))

  (fn mt.__extensions [v exts]
    (local desc (. enum.enumerants v.tag))
    (when desc.extensions
      (each [_ ext (ipairs desc.extensions)]
        (tset exts ext true)))
    (when v.operands
      (each [_ arg (ipairs v.operands)]
        (when (enum? arg) (getExtensions arg exts)))))

  (fn mt.__serialize [buffer v]
    (local desc (. enum.enumerants v.tag))
    (serializeFmt "I4" buffer v.value)
    (each [i opdesc (ipairs desc.operands)]
      (local arg (?. v.operands i))
      (local serializer (or (?. basicSerializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serializeListWith serializer buffer arg)
        (_  arg) (serializer buffer arg))))
  mt)

(fn opEnumerantMT [enum]
  (local mt (valueEnumerantMT enum))
  (fn mt.__serialize [buffer op]
    (local desc (. enum.enumerants op.tag))
    (local subBuffer [])
    (each [i opdesc (ipairs desc.operands)]
      (local arg (?. op.operands i))
      ; (print enum.name op.tag opdesc.name (tostring arg))
      (local serializer (or (?. basicSerializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serializeListWith serializer subBuffer arg)
        (_  arg) (serializer subBuffer arg)))
    (local opLen
      (accumulate [len 1 _ s (ipairs subBuffer)]
        (+ len (/ (s:len) 4))))
    (serializeFmt "I2 I2" buffer op.value opLen)
    (serializeAppendSubBuffer buffer subBuffer))
  mt)

(fn bitsEnumerantMT [enum]
  (local mt (valueEnumerantMT enum))
  (fn mt.__serialize [buffer v]
    (local desc (. enum.enumerants v.tag))
    (local opdescs (or desc.operands []))
    (each [i opdesc (ipairs opdescs)]
      (local arg (?. v.operands i))
      ; (print enum.name v.tag opdesc.name (tostring arg))
      (local serializer (or (?. basicSerializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serializeListWith serializer buffer arg)
        (_  arg) (serializer buffer arg))))
  mt)

; bits-enumerant-list structure
; .value         number
; .getTag        table[string, enumerant-value]
; .getValue      table[number, enumerant-value]
; .constituents  list[enumerant] # sorted by value

(fn bitsEnumerantListMT [enum]
  (local mt { :__enum true :__name enum.name })
  (fn mt.__index [self t/v]
    (or (. self.getTag t/v) (. self.getValue t/v) (. mt t/v)))

  (fn mt.__tostring [self]
    (case (# self.constituents)
      0 (.. "(" enum.name ")")
      _ (.. "(" enum.name " " 
          (table.concat (icollect [_ c (ipairs self.constituents)] (tostring c)) " ") ")")))
      
  (fn mt.__mapoperands [v f]
    (local mappedConstituents [])
    (icollect [_ constituent (ipairs v.constituents) &into mappedConstituents]
      (mapOperands constituent f))
    (enum (table.unpack mappedConstituents)))

  (fn mt.__capabilities [v caps]
    (each [_ e (ipairs v.constituents)]
      (getCapabilities e caps)))

  (fn mt.__extensions [v exts]
    (each [_ e (ipairs v.constituents)]
      (getExtensions e exts)))

  (fn mt.__serialize [buffer v]
    (serializeFmt "I" buffer v.value)
    (each [_ constituent (ipairs v.constituents)]
      (serialize buffer constituent)))

  mt)

; operand-desc structure
; .kind        string
; .name        ?string
; .quantifier  "?" | "*" | nil

; enumerant-desc structure
; .tag          string
; .value        number
; .version      ?{ :major number :minor number }
; .operands     ?list[operand-desc]
; .extensions   ?list[string]
; .capabilities ?list[string]

(local enumerantDescProto
  { :operands []
    :extensions []
    :capabilities []
    :version { :major 1 :minor 1 }
  })

; value-enum structure
; .name         string
; .kind         :value
; .enumerants   table[string, enumerant-desc]
; .getValue    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer

; op-enum structure
; .name         string
; .kind         :op
; .enumerants   table[string, enumerant-desc]
; .getValue    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer

; bits-enum structure
; .name         string
; .kind         :bits
; .enumerants   table[string, enumerant-desc]
; .getValue    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer
; __call        -> create enumerant list value

(fn valueEnumMT [enum]
  (local mt { :__enum true :__name enum.name })
  (set mt.enumerantMT (valueEnumerantMT enum))

  (fn mt.makeValue [desc]
    (setmetatable { :tag desc.tag :value desc.value } mt.enumerantMT))

  (fn mt.makeValueFactory [desc]
    (fn [...] 
      (setmetatable { :tag desc.tag :value desc.value :operands [...] } mt.enumerantMT)))

  (fn mt.__index [self t/v]
    (local desc (or (. self.enumerants t/v) (. self.getValue t/v)))
    (when (= nil desc) (error (.. "Enum " self.name ": No such enumerant or value: " (tostring t/v))))
    (if (= 0 (# desc.operands))
      (mt.makeValue desc)
      (mt.makeValueFactory desc)))
  mt)


(fn bitsEnumMT [enum]
  (local mt (valueEnumMT enum))
  (set mt.enumerantMT (bitsEnumerantMT enum))
  (local enumerantListMT (bitsEnumerantListMT enum))
  
  (fn mt.__call [self ...]
  
    (local constituentInputs [])
    (each [_ arg (ipairs [...])]
      (local arg (if (= (enum? arg) enum.name) arg (. enum arg)))
      ; (assert (= (enum? arg) enum.name) (.. "Incorrect type usd in enum constructor for: " enum.name))
      (if arg.constituents
        (each [_ constituent (ipairs arg.constituents)] (table.insert constituentInputs constituent))
        (table.insert constituentInputs arg)))
  
    (local getValue
      (collect [_ e (ipairs constituentInputs)]
        e.value e))
    (local getTag
      (collect [_ e (ipairs constituentInputs)]
        e.tag e))
    (local value
      (accumulate [union 0 _ e (ipairs constituentInputs)]
        (bor union e.value)))
    (local constituents
      (icollect [_ e (pairs getValue)] e))
    (table.sort constituents)

    (local o
      { : value
        : getValue
        : getTag
        : constituents
      })
    (setmetatable o enumerantListMT))

  mt)


(fn opEnumMT [enum]
  (local mt (valueEnumMT enum))
  (set mt.enumerantMT (opEnumerantMT enum))
  mt)


(fn extEnumMT [enum]
  (local mt (valueEnumMT enum))
  (fn mt.makeValue [desc] desc.value)
  (fn mt.makeValueFactory [desc]
    (fn [...] (values desc.value [...])))
  mt)


(fn mkEnum [name kind enumerants]
  (local makeMT
    (case kind
      :bits bitsEnumMT
      :value valueEnumMT
      :ext extEnumMT
      :op opEnumMT))
  (local descMT { :__index enumerantDescProto })
  (local getValue
    (collect [tag desc (pairs enumerants)]
      desc.value (setmetatable desc descMT)))
  (local enum
    { : name 
      : kind
      : enumerants
      : getValue })
  (setmetatable enum (makeMT enum)))


(local SpirvHeader {})
(set SpirvHeader.prototype
  { 
    :magicNumber "\x03\x02\x23\x07"
    :version { :major 1 :minor 6 }
    :generatorMagic 0
    :identifierBound 0
  })

(set SpirvHeader.mt { :__index SpirvHeader.prototype })
(fn SpirvHeader.mt.__serialize [buffer self]
  (let [fmt "!4< c4 I I I I"
        v (+ (lshift self.version.minor 8) (lshift self.version.major 16))
        s (string.pack fmt self.magicNumber v self.generatorMagic self.identifierBound 0)]
    (table.insert buffer s)))

(fn SpirvHeader.mt.__tostring [self]
  (.. "(SpirvHeader.new { " 
    (table.unpack
      (icollect [k v (pairs self)]
        (.. ":" k " " (tostring v) " ")))
    "})"))

(fn SpirvHeader.new [o]
  (let [o (or o {})] (setmetatable o SpirvHeader.mt)))

{: serialize
 : serializableWith
 : serializeFmt
 : serializableWithFmt
 : serializeTmp
 : serizlizeTmpWith
 : serializeList
 : serializeListWith
 : getCapabilities
 : getExtensions
 : mapOperands
 : mkEnum
 : enum?
 : SpirvHeader
 }