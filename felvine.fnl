
(local base (require :base))
(local fennel (require :fennel))
(local {: ExecutionEnvironment} (require :requirements))
(local {: Runtime : Dsl} (require :runtime))

(fn caps-list [e]
  (local caps (base.get-capabilities e))
  (icollect [cap _ (pairs caps)]
    cap))

(fn caps-unpacked [e]
  (table.unpack (caps-list e)))


(fn felvine-dofile [file runtime]
  (local runtime (or runtime (Runtime.new)))
  (local env (Dsl.create-exported-env runtime))
  (fennel.dofile file
    { :env env
      :compilerEnv _G
      :requireAsInclude true
    })
  runtime)


(fn asm-file [file execution-env]
  (local run (Runtime.new execution-env))
  (local start-time (os.clock))
  (var total-time 0)

  (felvine-dofile file run)
  (local ops (run.env:produce-ops))

  (local end-time (os.clock))
  (set total-time (+ total-time (- end-time start-time)))
  (print "finished in" total-time)
  
  (each [_ op (ipairs ops)]
    (print op (caps-unpacked op))))


(fn translate-file [file]
  (local runtime (Runtime.new))
  (local env (Dsl.create-exported-env runtime))

  (local (f err) (io.open file :r))
  (assert (= err nil) err)
  (local content (f:read :*a))
  (f:close)

  (local text
    (fennel.compileString content
      { :requireAsInclude true
        :filename file
        :env env
      }))

  (local out-file-name (file:gsub ".[%w]+$" ".lua"))
  (local out-file (assert (io.open out-file-name :w)))
  (out-file:write text)
  (out-file:close))
  

(fn compile-file [file execution-env]
  (local run (Runtime.new execution-env))
  (local start-time (os.clock))
  (var total-time 0)

  (felvine-dofile file run)
  
  (local ops (run.env:produce-ops))
  (local header (run.env:produce-header))
  
  (local buffer [])
  (base.serialize buffer header)
  (base.serialize-list buffer ops)

  (local out-file-name (file:gsub ".[%w]+$" ".spv"))
  (local out-file (assert (io.open out-file-name :wb)))
  (each [_ segment (ipairs buffer)]
    (out-file:write segment))
  (out-file:close)

  (local end-time (os.clock))
  (set total-time (+ total-time (- end-time start-time)))
  (print "finished in" total-time)

  (print "wrote" out-file-name))


(var use-execution-env false)
(var execution-env (ExecutionEnvironment.new { :vk-features {} :spv-features {} }))

(fn handle-args [...]
  (local consumed
    (case ...
      (:--spv-features features)
        (do (set use-execution-env true)
            (string.gsub features "([%w_]+)" (fn [f]
              (tset execution-env.spv-features f true)))
            2)
      (:--vk-features features)
        (do (set use-execution-env true)
            (string.gsub features "([%w_]+)" (fn [f]
              (tset execution-env.vk-features f true)))
            2)
      (:--vk-version version)
        (do (set use-execution-env true)
            (string.gsub version "(%d).*(%d)" (fn [major minor]
              (set execution-env.vk-version {:major (tonumber major) :minor (tonumber minor)})))
            2)
      (:-S file) (do (asm-file file (if use-execution-env execution-env)) 2)
      (:-c file) (do (compile-file file (if use-execution-env execution-env)) 2)
      (:-t file) (do (translate-file file) 2)
      unrecognized (do (print "unrecognized argument" unrecognized) 1)
      nil nil))
  (when (not= nil consumed)
    (handle-args (select (+ consumed 1) ...))))


(handle-args (table.unpack arg))