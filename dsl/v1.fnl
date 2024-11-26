(local spirv (require :spirv))

(fn spirvEnum [enum item]
  (if (list? item)
    (do (var [head & rest] item)
        (local msyms (multi-sym? head))
        (when (and msyms (= (tostring (. msyms 1)) enum.name))
          (set head (. msyms (# msyms))))
        (local enumDesc (. enum.enumerants (tostring head)))
        (if enumDesc
          (do (local restArgs
                (icollect [i a (ipairs rest)]
                  (let [opdesc (. enumDesc.operands i)
                        argEnum (. spirv opdesc.kind)]
                    (if argEnum (spirvEnum argEnum a) a))))
              `((. spirv ,enum.name ,(tostring head)) ,(table.unpack restArgs)))))
    (multi-sym? item)
      (let [[head name] (multi-sym? item)]
        (if (and (= enum.name (tostring head)) (. enum.enumerants (tostring name)))
          `(. spirv ,enum.name ,(tostring name))))
    (sym? item)
      (if (. enum.enumerants (tostring item))
        `(. spirv ,enum.name ,(tostring item)))

    (= :string (type item))
      (if (. enum.enumerants item)
        `(. spirv ,enum.name ,item))))


(fn decorate [item ...]
  (local decs
    (icollect [_ dec (ipairs [...])]
      (spirvEnum spirv.Decoration dec)))
  (if (not= 0 (# decs))
    `(dsl.decorate ,item ,(table.unpack decs))))

  
(fn decorateMember [item member ...]
  (local decs
    (icollect [_ dec (ipairs [...])]
      (spirvEnum spirv.Decoration dec)))
  (if (not= 0 (# decs))
    `(dsl.decorateMember ,item ,member ,(table.unpack decs))))


(fn type* [spec]
  (if
    ; array sugar [f32], [10 f32]
    ; [N ... M t] = [N [... [M t] ...]]
    ; pointer sugar [*P f32] [*I f32] [*G vec3f] etc.
    (sequence? spec)
    (let [elem (. spec (# spec))
          elemType (type* elem)]
      (if (= (# spec) 1) `(Type.array ,elemType) ; unsized array
        (do
          (var t elemType)
          (for [i (- (# spec) 1) 1 -1]
            (local dim (. spec i))
            (case (and (sym? dim) (string.match (tostring dim) "%*(%w+)"))
              (where ptrKind (not= false ptrKind))
                (let [ptrKind (case ptrKind
                        :P :PhysicalStorageBuffer
                        :W :Workgroup
                        :G :Generic
                        :I :Input
                        :O :Output
                        other other)]
                  (set t `(Type.pointer ,t (. spirv.StorageClass ,ptrKind))))
              _ (set t `(Type.array ,t ,dim)))) ; assuming numeric array dim
          t)))

    ; struct sugar { x f32 y ([3 f32] (Location 0) (Builtin Foo)) }
    (and (table? spec) (not (list? spec)))
      (do (local fieldTypes [])
          (local fieldNames [])
          (local fieldDecorations {})
          (var i 1)
          (local mt (getmetatable spec))
          (each [_ k (ipairs mt.keys)]
            (local v (. spec k))
            (table.insert fieldNames (tostring k))
            (var (v0 decs)
              (if (list? v) (let [[v0 & decs] v] (values v0 decs)) v))
            (var validDecs
              (and decs (icollect [_ d (ipairs decs)] (spirvEnum spirv.Decoration d))))
            (when (and validDecs (not= (# validDecs) (# decs)))
              (set v0 v)
              (set validDecs nil))
            (when validDecs
              (tset fieldDecorations i validDecs))
            (table.insert fieldTypes (type* v0))
            (set i (+ i 1)))
          `(Type.struct
              ,fieldTypes
              ,fieldNames
              ,fieldDecorations))
    
    ; just a value of Type, probably
    spec ))


(fn refTypes* [...]
  (local names [])
  (local descs [])

  (local arglen (select :# ...))
  (assert-compile (= 0 (% arglen 2)) "Recursive typedef(s) must be given name/definition pairs." ...)

  (for [i 1 arglen 2]
    (local (name desc) (select i ...))
    (assert-compile (sym? name) "Typedef name must be identifier" name)
    (table.insert names name)
    (table.insert descs desc))

  (local forwardPointers
    (fcollect [i 1 (# names)]
      `(dsl.forwardPointer)))

  (local typeNames
    (fcollect [i 1 (# names)]
      (gensym "n")))

  (local types
    (icollect [_ desc (ipairs descs)]
      (type* desc)))
    
  (local layoutTypes
    (icollect [_ ty (ipairs typeNames)]
      `(dsl.layout ,ty)))

  (local ptrInitElems
    (icollect [i ptr (ipairs names)]
      `(tset ,ptr :elem ,(. typeNames i))))

  (local ptrReify
    (icollect [i ptr (ipairs names)]
      `(dsl.finalizeForwardPointer ,ptr)))

  `(local (,(table.unpack names)) 
    (do (local (,(table.unpack names)) (values ,(table.unpack forwardPointers)))
        (local (,(table.unpack typeNames)) (values ,(table.unpack types)))
        (do ,(table.unpack ptrInitElems))
        (do ,(table.unpack ptrReify))
        (do ,(table.unpack layoutTypes))
        (values ,(table.unpack names))
    )))


(fn defType* [name desc ...]
  (local decs
    (icollect [_ dec (ipairs [...])]
      (spirvEnum spirv.Decoration dec)))
  `(local ,name
    (do (local t# ,(type* desc))
        ,(if (not= 0 (# decs))
           `(dsl.decorate t# ,(table.unpack decs)))
        (dsl.name t# ,(tostring name))
        t#)))


(fn if* [cond1 then1 else1/cond2 ...]
  (case (select :# ...)
    0 `(dsl.ifThenElse ,cond1 (fn [] ,then1) (fn [] ,else1/cond2))
    _ `(dsl.ifThenElse ,cond1 (fn [] ,then1) (fn [] (if* ,else1/cond2 ,...)))))


(fn switch* [disc ...]
  (local targets [])
  
  (local nargs (select :# ...))
  (assert-compile (= 0 (% nargs 2))
    (.. "switch* must have an even number of cases, got: " (tostring nargs)))

  (fn go [...]
    (case ...
      (exp body)
        (do (if (sequence? exp)
                (table.insert targets `{ :cases ,exp   :body (fn [] ,body) })
                (table.insert targets `{ :cases [,exp] :body (fn [] ,body )}))
            (go (select 3 ...)))))

  (go ...)

  `(dsl.switchCase ,disc [,(table.unpack targets)]))


(fn when* [cond ...]
  `(dsl.ifThenElse ,cond (fn [] ,...) (fn [])))


(fn fn* [name return args ...]
  (local argTypes [])
  (local argSyms  [])
  (local argDecs  [])
  (assert-compile (sym? name) "Function name must be symbol" name)
  (each [_ arg (ipairs args)]
    (assert-compile (list? arg) "Args must be (name type) lists" arg)
    (local [sym ty & decs] arg)
    (table.insert argTypes (type* ty))
    (table.insert argSyms sym)
    (table.insert argDecs decs))

  (fn argSymDebugInfo [f]
    (local steps [])
    (each [i argSym (ipairs argSyms)]
      (table.insert steps `(name (. ,f :params ,i) ,(tostring argSym)))
      (local decorate (decorate `(. ,f :params ,i) (table.unpack (. argDecs i))))
      (when decorate (table.insert steps decorate)))
    steps)

  `(local ,name 
    (let [fun# (dsl.defineFunction ,(type* return) ,(tostring name) ,argTypes (fn ,argSyms ,...))]
      (do (local f# fun#.function)
         ,(table.unpack (argSymDebugInfo `f#)))
      fun#)))


(fn var* [name type ...]
  (local decs [])
  (var storage nil)
  (var init nil)

  (local vtype (type* type))

  (fn go [...]
    (case ...
      (:= v)
        (do (assert-compile (= nil init) "Cannot have two initializers for variable" v)
            (set init v)
            (go (select 3 ...)))
      (decOrStorage)
        (do (local dec (spirvEnum spirv.Decoration decOrStorage))
            (local sto (spirvEnum spirv.StorageClass decOrStorage))
            (assert (or dec sto) "Unrecognized decoration or storage class" decOrStorage)
            (when dec (table.insert decs dec))
            (when sto
              (assert (= nil storage) "Cannot have two storage classes for variable" decOrStorage)
              (set storage sto))
            (go (select 2 ...)))))

  (go ...)

  `(local ,name 
      (do (local v# (dsl.variable ,vtype ,storage ,init))
          ,(if (not= 0 (# decs))
            `(dsl.decorate v# ,(table.unpack decs)))
          (dsl.name v# ,(tostring name))
          v#)))


(fn set* [...]
  `(dsl.set* ,...))


(fn local* [name value ...]
  `(local ,name
    (do (local v# ,value)
        (when (node? v#)
          (dsl.name v# ,(tostring name))
          (dsl.reify v#)
          ,(decorate `v# ...))
        v#)))


(fn const* [name type ...]
  (local decs [])
  (var init nil)

  (fn go [...]
    (case ...
      (:= v)
        (do (assert-compile (= nil init) "Cannot have two initializers for constant" v)
            (set init v)
            (go (select 3 ...)))
      dec
        (do (local dec (spirvEnum spirv.Decoration dec))
            (assert dec (.. "Unrecognized decoration: " (tostring dec)))
            (table.insert decs dec)
            (go (select 2 ...)))))

  (go ...)
  
  (assert-compile (not= nil init) "Constant must be given an initial value: " name)
  
  `(local ,name
    (do (local v# (Node.specConstant ,(type* type) ,init))
        (dsl.decorate v# ,(table.unpack decs))
        (dsl.name v# ,(tostring name))
        v#)))


(fn while* [cond ...]
  (local {: enum?} (require :base))
  (local cond `(fn [] ,cond))
  (local (control body)
    (case ...
      (:control v) (values v `(fn [] ,(select 3 ...)))
      _ (values nil `(fn [] ,...))))
  `(dsl.whileLoop ,cond ,body ,control))


(fn for* [block ...]
  (assert-compile (sequence? block) "For loop must have binding block for iterator variable" block)

  (local [typeName init final ?step] block)
  (assert-compile (list? typeName) "For loop variable must have an accompanying type" typeName)

  (local [name type] typeName)
  (assert-compile (sym? name) "For loop variable name must be symbol" name)

  (local step (or ?step 1))
  (local (control bodyContent)
    (case ...
      (:control v) (values v [(select 3 ...)])
      _ (values nil [...])))
  `(do (var* ,name ,type := ,init)
       (local final# ,final)
       (dsl.reify final#)
       (dsl.forLoop (fn [] (lte? ,name final#))
                 (fn [] (dsl.set* ,name (+ ,name ,step)))
                 (fn [] ,(table.unpack bodyContent))
                 ,control)))

                 
(fn for< [block ...]
  (assert-compile (sequence? block) "For loop must have binding block for iterator variable" block)

  (local [typeName init final ?step] block)
  (assert-compile (list? typeName) "For loop variable must have an accompanying type" typeName)

  (local [name type] typeName)
  (assert-compile (sym? name) "For loop variable name must be symbol" name)

  (local step (or ?step 1))
  (local (control bodyContent)
    (case ...
      (:control v) (values v [(select 3 ...)])
      _ (values nil [...])))
  `(do (var* ,name ,type := ,init)
       (local final# ,final)
       (dsl.reify final#)
       (dsl.forLoop (fn [] (lt? ,name final#))
                 (fn [] (dsl.set* ,name (+ ,name ,step)))
                 (fn [] ,(table.unpack bodyContent))
                 ,control)))
  

(fn capability [...]
  (local caps
    (icollect [_ c (ipairs [...])]
      (spirvEnum spirv.Capability c)))
  `(dsl.capability ,(table.unpack caps)))


(fn entrypoint [name executionModel executionModes ...]
  (assert-compile (sequence? executionModes) "Entrypoint must provide list of executionModes, got: " executionModes)
  (local executionModel (spirvEnum spirv.ExecutionModel executionModel))
  (local executionModes
    (icollect [_ mode (ipairs executionModes)] (spirvEnum spirv.ExecutionMode mode)))
  `(local ,name
    (do 
      (dsl.executionMode ,(tostring name) ,(table.unpack executionModes))
      (dsl.entrypoint
        ,(tostring name)
        ,executionModel
        (fn [] ,...)))))


(fn executionMode [nameOrEntrypoint ...]
  (local executionModes
    (icollect [_ mode (ipairs [...])] (spirvEnum spirv.ExecutionMode mode)))
  
  (local name
    (if (sym? nameOrEntrypoint) `(. ,nameOrEntrypoint :function :name)
        (tostring nameOrEntrypoint)))

  `(dsl.executionMode ,name ,(table.unpack executionModes)))


(fn uniform [binding name utype ...]
  (assert-compile (and (list? binding) (= 2 (# binding))) "Uniform definition needs (set binding) information" binding)
  (assert-compile (sym? name) "Uniform must be given a name to bind variable" name)

  (local utype (type* utype))
  (local [uset ubinding] binding)

  `(local ,name 
    (do (local t# ,utype)
        (local v# (dsl.variable t# (dsl.uniformStorageClass t#)))
        (dsl.name v# ,(tostring name))
        ,(decorate `v# `(DescriptorSet ,uset) `(Binding ,ubinding) ...)
        v#
    )))


(fn buffer [binding name utype ...]
  (assert-compile (and (list? binding) (= 2 (# binding))) "Uniform definition needs (set binding) information" binding)
  (assert-compile (sym? name) "Uniform must be given a name to bind variable" name)

  (local utype (type* utype))
  (local [uset ubinding] binding)

  `(local ,name 
    (do (local t# ,utype)
        (local v# (dsl.variable t# (dsl.bufferStorageClass t#)))
        (dsl.name v# ,(tostring name))
        ,(decorate `v# `(DescriptorSet ,uset) `(Binding ,ubinding) ...)
        v#
    )))


(fn pushConstant [name utype ...]
  (assert-compile (sym? name) "Push constant must be given a name to bind variable" name)
  (local utype (type* utype))
  `(local ,name 
    (do (local t# ,utype)
        (local v# (dsl.variable t# (dsl.pushConstantStorageClass t#)))
        (dsl.name v# ,(tostring name))
        v#
    )))


; right-associative multiplication
; useful for matrix-vector multiply chains etc.
(fn *r [...]
  (case ...
    nil `1
    (a nil) a
    (a b nil) `(* ,a ,b)
    a `(* ,a ,(*r (select 2 ...)))))
    

{
 : if* 
 : switch*
 : when*
 : while*
 : for*
 : for<
 : fn*
 : var*
 : set* ; currently a passthrough but may not be later
 : local*
 : const*

 :type* defType*
 : refTypes*
 : uniform
 : buffer
 : pushConstant

 : capability
 : decorate
 : decorateMember
 : entrypoint
 : executionMode

 : *r
}
