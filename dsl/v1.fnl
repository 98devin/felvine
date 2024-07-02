(local spirv (require :spirv))

(fn spirv-enum [enum item]
  (if (list? item)
    (do (var [head & rest] item)
        (local msyms (multi-sym? head))
        (when (and msyms (= (tostring (. msyms 1)) enum.name))
          (set head (. msyms (# msyms))))
        (local enum-desc (. enum.enumerants (tostring head)))
        (if enum-desc
          (do (local rest-args
                (icollect [i a (ipairs rest)]
                  (let [opdesc (. enum-desc.operands i)
                        arg-enum (. spirv opdesc.kind)]
                    (if arg-enum (spirv-enum arg-enum a) a))))
              `((. spirv ,enum.name ,(tostring head)) ,(table.unpack rest-args)))))
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
      (spirv-enum spirv.Decoration dec)))
  (if (not= 0 (# decs))
    `(dsl.decorate ,item ,(table.unpack decs))))

  
(fn decorate-member [item member ...]
  (local decs
    (icollect [_ dec (ipairs [...])]
      (spirv-enum spirv.Decoration dec)))
  (if (not= 0 (# decs))
    `(dsl.decorate-member ,item ,member ,(table.unpack decs))))


(fn type* [spec]
  (if
    ; array sugar [f32], [10 f32]
    ; [N ... M t] = [N [... [M t] ...]]
    ; pointer sugar [*P f32] [*I f32] [*G vec3f] etc.
    (sequence? spec)
    (let [elem (. spec (# spec))
          elem-type (type* elem)]
      (if (= (# spec) 1) `(Type.array ,elem-type) ; unsized array
        (do
          (var t elem-type)
          (for [i (- (# spec) 1) 1 -1]
            (local dim (. spec i))
            (case (and (sym? dim) (string.match (tostring dim) "%*(%w+)"))
              (where ptr-kind (not= false ptr-kind))
                (let [ptr-kind (case ptr-kind
                        :P :PhysicalStorageBuffer64
                        :W :Workgroup
                        :G :Generic
                        :I :Input
                        :O :Output
                        other other)]
                  (set t `(Type.pointer ,t (. spirv.StorageClass ,ptr-kind))))
              _ (set t `(Type.array ,t ,dim)))) ; assuming numeric array dim
          t)))

    ; struct sugar { x f32 y ([3 f32] (Location 0) (Builtin Foo)) }
    (and (table? spec) (not (list? spec)))
      (do (local field-types [])
          (local field-names [])
          (local field-decorations {})
          (var i 1)
          (each [k v (pairs spec)]
            (table.insert field-names (tostring k))
            (var (v0 decs)
              (if (list? v) (let [[v0 & decs] v] (values v0 decs)) v))
            (var valid-decs
              (and decs (icollect [_ d (ipairs decs)] (spirv-enum spirv.Decoration d))))
            (when (and valid-decs (not= (# valid-decs) (# decs)))
              (set v0 v)
              (set valid-decs nil))
            (when valid-decs
              (tset field-decorations i valid-decs))
            (table.insert field-types (type* v0))
            (set i (+ i 1)))
          `(Type.struct
              ,field-types
              ,field-names
              ,field-decorations))
    
    ; just a value of Type, probably
    spec ))


(fn ref-types* [...]
  (local names [])
  (local descs [])

  (local arglen (select :# ...))
  (assert-compile (= 0 (% arglen 2)) "Recursive typedef(s) must be given name/definition pairs." ...)

  (for [i 1 arglen 2]
    (local (name desc) (select i ...))
    (assert-compile (sym? name) "Typedef name must be identifier" name)
    (table.insert names name)
    (table.insert descs desc))

  (local forward-pointers
    (fcollect [i 1 (# names)]
      `(dsl.forward-pointer)))

  (local type-names
    (fcollect [i 1 (# names)]
      (gensym "n")))

  (local types
    (icollect [_ desc (ipairs descs)]
      (type* desc)))
    
  (local layout-types
    (icollect [_ ty (ipairs type-names)]
      `(dsl.layout ,ty)))

  (local ptr-init-elems
    (icollect [i ptr (ipairs names)]
      `(tset ,ptr :elem ,(. type-names i))))

  (local ptr-reify
    (icollect [i ptr (ipairs names)]
      `(dsl.finalize-forward-pointer ,ptr)))

  `(local (,(table.unpack names)) 
    (do (local (,(table.unpack names)) (values ,(table.unpack forward-pointers)))
        (local (,(table.unpack type-names)) (values ,(table.unpack types)))
        (do ,(table.unpack ptr-init-elems))
        (do ,(table.unpack ptr-reify))
        (do ,(table.unpack layout-types))
        (values ,(table.unpack names))
    )))


(fn def-type* [name desc ...]
  (local decs
    (icollect [_ dec (ipairs [...])]
      (spirv-enum spirv.Decoration dec)))
  `(local ,name
    (do (local t# ,(type* desc))
        ,(if (not= 0 (# decs))
           `(dsl.decorate t# ,(table.unpack decs)))
        (dsl.name t# ,(tostring name))
        t#)))


(fn if* [cond1 then1 else1/cond2 ...]
  (case (select :# ...)
    0 `(dsl.if-then-else ,cond1 (fn [] ,then1) (fn [] ,else1/cond2))
    _ `(dsl.if-then-else ,cond1 (fn [] ,then1) (fn [] (if* ,else1/cond2 ,...)))))


(fn when* [cond ...]
  `(dsl.if-then-else ,cond (fn [] ,...) (fn [])))


(fn fn* [name return args ...]
  (local arg-types [])
  (local arg-syms  [])
  (local arg-decs  [])
  (assert-compile (sym? name) "Function name must be symbol" name)
  (each [_ arg (ipairs args)]
    (assert-compile (list? arg) "Args must be (name type) lists" arg)
    (local [sym ty & decs] arg)
    (table.insert arg-types (type* ty))
    (table.insert arg-syms sym)
    (table.insert arg-decs decs))

  (fn arg-sym-debug-info [f]
    (local steps [])
    (each [i arg-sym (ipairs arg-syms)]
      (table.insert steps `(name (. ,f :params ,i) ,(tostring arg-sym)))
      (local decorate (decorate `(. ,f :params ,i) (table.unpack (. arg-decs i))))
      (when decorate (table.insert steps decorate)))
    steps)

  `(local ,name 
    (let [fun# (dsl.define-function ,(type* return) ,(tostring name) ,arg-types (fn ,arg-syms ,...))]
      (do (local f# fun#.function)
         ,(table.unpack (arg-sym-debug-info `f#)))
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
      (dec-or-storage)
        (do (local dec (spirv-enum spirv.Decoration dec-or-storage))
            (local sto (spirv-enum spirv.StorageClass dec-or-storage))
            (assert (or dec sto) "Unrecognized decoration or storage class" dec-or-storage)
            (when dec (table.insert decs dec))
            (when sto
              (assert (= nil storage) "Cannot have two storage classes for variable" dec-or-storage)
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
        (do (local dec (spirv-enum spirv.Decoration dec))
            (assert dec "Unrecognized decoration:" dec)
            (table.insert decs dec)
            (go (select 2 ...)))))

  (go ...)
  
  (assert-compile (not= nil init) "Constant must be given an initial value: " name)
  
  `(local ,name
    (do (local v# (Node.spec-constant ,(type* type) ,init))
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
  `(dsl.while-loop ,cond ,body ,control))


(fn for* [block ...]
  (assert-compile (sequence? block) "For loop must have binding block for iterator variable" block)

  (local [type-name init final ?step] block)
  (assert-compile (list? type-name) "For loop variable must have an accompanying type" type-name)

  (local [name type] type-name)
  (assert-compile (sym? name) "For loop variable name must be symbol" name)

  (local step (or ?step 1))
  (local (control body-content)
    (case ...
      (:control v) (values v [(select 3 ...)])
      _ (values nil [...])))
  `(do (var* ,name ,type := ,init)
       (local final# ,final)
       (dsl.reify final#)
       (dsl.for-loop (fn [] (lte? ,name final#))
                 (fn [] (dsl.set* ,name (+ ,name ,step)))
                 (fn [] ,(table.unpack body-content))
                 ,control)))
  

(fn capability [...]
  (local caps
    (icollect [_ c (ipairs [...])]
      (spirv-enum spirv.Capability c)))
  `(dsl.capability ,(table.unpack caps)))


(fn entrypoint [name execution-model execution-modes ...]
  (assert-compile (sequence? execution-modes) "Entrypoint must provide list of execution-modes, got: " execution-modes)
  (local execution-model (spirv-enum spirv.ExecutionModel execution-model))
  (local execution-modes
    (icollect [_ mode (ipairs execution-modes)] (spirv-enum spirv.ExecutionMode mode)))
  `(local ,name
    (do 
      (dsl.execution-mode ,(tostring name) ,(table.unpack execution-modes))
      (dsl.entrypoint
        ,(tostring name)
        ,execution-model
        (fn [] ,...)))))



(fn uniform [binding name utype ...]
  (assert-compile (and (list? binding) (= 2 (# binding))) "Uniform definition needs (set binding) information" binding)
  (assert-compile (sym? name) "Uniform must be given a name to bind variable" name)

  (local utype (type* utype))
  (local [uset ubinding] binding)

  `(local ,name 
    (do (local t# ,utype)
        (local v# (dsl.variable t# (dsl.uniform-storage-class t#)))
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
        (local v# (dsl.variable t# (dsl.buffer-storage-class t#)))
        (dsl.name v# ,(tostring name))
        ,(decorate `v# `(DescriptorSet ,uset) `(Binding ,ubinding) ...)
        v#
    )))


(fn push-constant [name utype ...]
  (assert-compile (sym? name) "Push constant must be given a name to bind variable" name)
  (local utype (type* utype))
  `(local ,name 
    (do (local t# ,utype)
        (local v# (dsl.variable t# (dsl.push-constant-storage-class t#)))
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
 : when*
 : while*
 : for*
 : fn*
 : var*
 : set* ; currently a passthrough but may not be later
 : const*

 :type* def-type*
 : ref-types*
 : uniform
 : buffer
 : push-constant

 : capability
 : decorate
 : decorate-member
 : entrypoint

 : *r
}
