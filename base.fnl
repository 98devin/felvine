(local fennel (require :fennel))

(fn enum? [value]
  (when (= :table (type value))
    (local value-mt (getmetatable value))
    (if (?. value-mt :__enum) (?. value-mt :__name))))

(fn get-capabilities [item caps]
  (local caps (or caps {}))
  (local mt (getmetatable item))
  (local method (. mt :__capabilities))
  (when (not= nil method)
    (method item caps))
  caps)

(fn get-extensions [item exts]
  (local exts (or exts {}))
  (local mt (getmetatable item))
  (local method (. mt :__extensions))
  (when (not= nil method)
    (method item exts))
  exts)

(fn map-operands [item f]
  (local mt (getmetatable item))
  (local method (. mt :__mapoperands))
  (if (not= nil method)
    (method item f)))

(fn serialize [buffer item]
  (local mt (getmetatable item))
  (local method (. mt :__serialize))
  (when (not= nil method)
    (method buffer item))) 

(fn serializable-with [serialize item]
  (fn wrapped-serialize [buffer o]
    (serialize buffer o.value))
  (fn wrapped-tostring [o]
    (tostring o.value))
  (local mt { :__serialize wrapped-serialize :__tostring wrapped-tostring })
  (setmetatable { :value item } mt))

(fn serialize-tmp-with [serialize item]
  (local buffer [])
  (serialize buffer item)
  buffer)

(fn serialize-tmp [item]
  (serialize-tmp-with serialize item))

(fn serialize-append-sub-buffer [buffer sub-buffer]
  (each [_ s (ipairs sub-buffer)]
    (table.insert buffer s)))

(fn serialize-fmt [fmt buffer ...]
  (let [s (string.pack (.. "!4<" fmt "XI4") ...)] (table.insert buffer s)))
    
(fn serialize-via [fmt] (partial serialize-fmt fmt))

(fn serializable-with-fmt [fmt item]
  (serializable-with (serialize-via fmt) item))
  
(fn serialize-list-via [fmt]
  (fn [buffer item] (serialize-fmt fmt buffer (table.unpack item))))

(fn serialize-list-with [serialize buffer item]
  (each [_ v (ipairs item)] (serialize buffer v)))

(local serialize-list (partial serialize-list-with serialize))


(local basic-serializers {
  :Id (serialize-via "I4")                              ; u32
  :IdRef (serialize-via "I4")                           ; u32
  :IdMemorySemantics (serialize-via "I4")               ; u32
  :IdScope (serialize-via "I4")                         ; u32
  :IdResult (serialize-via "I4")                        ; u32
  :IdResultType (serialize-via "I4")                    ; u32
  :LiteralInteger (serialize-via "i4")                  ; i32
  :LiteralFloat (serialize-via "f")                     ; f32
  :LiteralString (serialize-via "z XI4")                ; string
  :LiteralExtInstInteger (serialize-via "I4")           ; u32
  :PairLiteralIntegerIdRef (serialize-list-via "i4 I4") ; (i32, u32)
  :PairIdRefIdRef (serialize-list-via "I4 I4")          ; (u32, u32)
})


; enumerant-value structure
; .tag      string
; .value    number
; .operands ?list[any]
(local enumerant-value-proto
  { :operands []
  })

(fn value-enumerant-mt [enum]
  (local mt { :__enum true :__name enum.name })
  (set mt.__index enumerant-value-proto)
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
        (local mapped-operands [])
        (icollect [i arg (ipairs v.operands) &into mapped-operands]
          (let [opdesc (. desc.operands i)] (f arg opdesc v.tag enum.name)))
        ((. enum v.tag) (table.unpack mapped-operands))
      )))

  (fn mt.__capabilities [v caps]
    (local desc (. enum.enumerants v.tag))
    (when desc.capabilities
      (each [_ cap (ipairs desc.capabilities)]
        (tset caps cap true)))
    (when v.operands
      (each [_ arg (ipairs v.operands)]
        (when (enum? arg) (get-capabilities arg caps)))))

  (fn mt.__extensions [v exts]
    (local desc (. enum.enumerants v.tag))
    (when desc.extensions
      (each [_ ext (ipairs desc.extensions)]
        (tset exts ext true)))
    (when v.operands
      (each [_ arg (ipairs v.operands)]
        (when (enum? arg) (get-extensions arg exts)))))

  (fn mt.__serialize [buffer v]
    (local desc (. enum.enumerants v.tag))
    (serialize-fmt "I4" buffer v.value)
    (each [i opdesc (ipairs desc.operands)]
      (local arg (?. v.operands i))
      (local serializer (or (?. basic-serializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serialize-list-with serializer buffer arg)
        (_  arg) (serializer buffer arg))))
  mt)

(fn op-enumerant-mt [enum]
  (local mt (value-enumerant-mt enum))
  (fn mt.__serialize [buffer op]
    (local desc (. enum.enumerants op.tag))
    (local sub-buffer [])
    (each [i opdesc (ipairs desc.operands)]
      (local arg (?. op.operands i))
      ; (print enum.name op.tag opdesc.name (tostring arg))
      (local serializer (or (?. basic-serializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serialize-list-with serializer sub-buffer arg)
        (_  arg) (serializer sub-buffer arg)))
    (local op-len
      (accumulate [len 1 _ s (ipairs sub-buffer)]
        (+ len (/ (s:len) 4))))
    (serialize-fmt "I2 I2" buffer op.value op-len)
    (serialize-append-sub-buffer buffer sub-buffer))
  mt)

(fn bits-enumerant-mt [enum]
  (local mt (value-enumerant-mt enum))
  (fn mt.__serialize [buffer v]
    (local desc (. enum.enumerants v.tag))
    (local opdescs (or desc.operands []))
    (each [i opdesc (ipairs opdescs)]
      (local arg (?. v.operands i))
      ; (print enum.name v.tag opdesc.name (tostring arg))
      (local serializer (or (?. basic-serializers opdesc.kind) serialize))
      (case (values opdesc.quantifier arg)
        (:? nil) nil
        (:* arg) (serialize-list-with serializer buffer arg)
        (_  arg) (serializer buffer arg))))
  mt)

; bits-enumerant-list structure
; .value-union   number
; .get-tag       table[string, enumerant-value]
; .get-value     table[number, enumerant-value]
; .constituents  list[enumerant] # sorted by value

(fn bits-enumerant-list-mt [enum]
  (local mt { :__enum true :__name enum.name })
  (fn mt.__index [self t/v]
    (or (. self.get-tag t/v) (. self.get-value t/v) (. mt t/v)))

  (fn mt.__tostring [self]
    (case (# self.constituents)
      0 (.. "(" enum.name ")")
      _ (.. "(" enum.name " " 
          (table.concat (icollect [_ c (ipairs self.constituents)] (tostring c)) " ") ")")))
      
  (fn mt.__mapoperands [v f]
    (local mapped-constituents [])
    (icollect [_ constituent (ipairs v.constituents) &into mapped-constituents]
      (map-operands constituent f))
    (enum (table.unpack mapped-constituents)))

  (fn mt.__capabilities [v caps]
    (each [_ e (ipairs v.constituents)]
      (get-capabilities e caps)))

  (fn mt.__extensions [v exts]
    (each [_ e (ipairs v.constituents)]
      (get-extensions e exts)))

  (fn mt.__serialize [buffer v]
    (serialize-fmt "I" buffer v.value-union)
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

(local enumerant-desc-proto
  { :operands []
    :extensions []
    :capabilities []
    :version { :major 1 :minor 1 }
  })

; value-enum structure
; .name         string
; .kind         :value
; .enumerants   table[string, enumerant-desc]
; .get-value    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer

; op-enum structure
; .name         string
; .kind         :op
; .enumerants   table[string, enumerant-desc]
; .get-value    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer

; bits-enum structure
; .name         string
; .kind         :bits
; .enumerants   table[string, enumerant-desc]
; .get-value    table[number, enumerant-desc]
; __index       -> get enumerant or enumerant initializer
; __call        -> create enumerant list value

(fn value-enum-mt [enum]
  (local mt { :__enum true :__name enum.name })
  (set mt.enumerant-mt (value-enumerant-mt enum))

  (fn mt.make-value [desc]
    (setmetatable { :tag desc.tag :value desc.value } mt.enumerant-mt))

  (fn mt.make-value-factory [desc]
    (fn [...] 
      (setmetatable { :tag desc.tag :value desc.value :operands [...] } mt.enumerant-mt)))

  (fn mt.__index [self t/v]
    (local desc (or (. self.enumerants t/v) (. self.get-value t/v)))
    (when (= nil desc) (error (.. "Enum " self.name ": No such enumerant or value: " (tostring t/v))))
    (if (= 0 (# desc.operands))
      (mt.make-value desc)
      (mt.make-value-factory desc)))
  mt)


(fn bits-enum-mt [enum]
  (local mt (value-enum-mt enum))
  (set mt.enumerant-mt (bits-enumerant-mt enum))
  (local enumerant-list-mt (bits-enumerant-list-mt enum))
  
  (fn mt.__call [self ...]
  
    (local constituent-inputs [])
    (each [_ arg (ipairs [...])]
      (assert (= (enum? arg) enum.name) (.. "Incorrect type used in enum constructor for: " enum.name))
      (if arg.constituents
        (each [_ constituent (ipairs arg.constituents)] (table.insert constituent-inputs constituent))
        (table.insert constituent-inputs arg)))
  
    (local get-value
      (collect [_ e (ipairs constituent-inputs)]
        e.value e))
    (local get-tag
      (collect [_ e (ipairs constituent-inputs)]
        e.tag e))
    (local value-union
      (accumulate [union 0 _ e (ipairs constituent-inputs)]
        (bor union e.value)))
    (local constituents
      (icollect [_ e (pairs get-value)] e))
    (table.sort constituents)

    (local o
      { : value-union
        : get-value
        : get-tag
        : constituents
      })
    (setmetatable o enumerant-list-mt))

  mt)


(fn op-enum-mt [enum]
  (local mt (value-enum-mt enum))
  (set mt.enumerant-mt (op-enumerant-mt enum))
  mt)


(fn ext-enum-mt [enum]
  (local mt (value-enum-mt enum))
  (fn mt.make-value [desc] desc.value)
  (fn mt.make-value-factory [desc]
    (fn [...] (values desc.value [...])))
  mt)


(fn mk-enum [name kind enumerants]
  (local make-mt
    (case kind
      :bits bits-enum-mt 
      :value value-enum-mt
      :ext ext-enum-mt
      :op op-enum-mt))
  (local desc-mt { :__index enumerant-desc-proto })
  (local get-value
    (collect [tag desc (pairs enumerants)]
      desc.value (setmetatable desc desc-mt)))
  (local enum
    { : name 
      : kind
      : enumerants
      : get-value })
  (setmetatable enum (make-mt enum)))


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
 : serializable-with
 : serialize-fmt
 : serializable-with-fmt
 : serialize-tmp
 : serialize-tmp-with
 : serialize-list
 : serialize-list-with
 : get-capabilities
 : get-extensions
 : map-operands
 : mk-enum
 : enum?
 : SpirvHeader}