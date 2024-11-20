
(local base (require :base))
(local fennel (require :fennel))
(local {: ExecutionEnvironment} (require :requirements))
(local {: Runtime : Dsl} (require :runtime))

(fn capsList [e]
  (local caps (base.getCapabilities e))
  (icollect [cap _ (pairs caps)]
    cap))

(fn capsUnpacked [e]
  (table.unpack (capsList e)))


(fn felvineDofile [file runtime]
  (local runtime (or runtime (Runtime.new)))
  (local env (Dsl.createExportedEnv runtime))
  (fennel.dofile file
    { :env env
      :compilerEnv _G
      :requireAsInclude true
    })
  runtime)


(fn asmFile [file executionEnv]
  (local run (Runtime.new executionEnv))
  (local startTime (os.clock))
  (var totalTime 0)

  (felvineDofile file run)
  (local ops (run.env:produceOps))

  (local endTime (os.clock))
  (set totalTime (+ totalTime (- endTime startTime)))
  (print "finished in" totalTime)
  
  (print (run.env:produceHeader))
  (each [_ op (ipairs ops)]
    (print op (capsUnpacked op))))


(fn translateFile [file]
  (local runtime (Runtime.new))
  (local env (Dsl.createExportedEnv runtime))

  (local (f err) (io.open file :r))
  (assert (= err nil) err)
  (local content (f:read :*a))
  (f:close)

  (local text
    (fennel.compileString content
      { :requireAsInclude true
        :filename file
        :compilerEnv _G
        :env env
      }))

  (local outFileName (file:gsub ".[%w]+$" ".lua"))
  (local outFile (assert (io.open outFileName :w)))
  (outFile:write text)
  (outFile:close))
  

(fn compileFile [file executionEnv]
  (local run (Runtime.new executionEnv))
  (local startTime (os.clock))
  (var totalTime 0)

  (felvineDofile file run)
  
  (local ops (run.env:produceOps))
  (local header (run.env:produceHeader))
  
  (local buffer [])
  (base.serialize buffer header)
  (base.serializeList buffer ops)

  (local outFileName (file:gsub ".[%w]+$" ".spv"))
  (local outFile (assert (io.open outFileName :wb)))
  (each [_ segment (ipairs buffer)]
    (outFile:write segment))
  (outFile:close)

  (local endTime (os.clock))
  (set totalTime (+ totalTime (- endTime startTime)))
  (print "finished in" totalTime ":" outFileName))


(var useExecutionEnv false)
(var executionEnv (ExecutionEnvironment.new { :vkFeatures {} :spvFeatures {} }))

(fn handleArgs [...]
  (local consumed
    (case ...
      (:--spv-features features)
        (do (set useExecutionEnv true)
            (string.gsub features "([%w_]+)" (fn [f]
              (tset executionEnv.spvFeatures f true)))
            2)
      (:--vk-features features)
        (do (set useExecutionEnv true)
            (string.gsub features "([%w_]+)" (fn [f]
              (tset executionEnv.vkFeatures f true)))
            2)
      (:--vk-version version)
        (do (set useExecutionEnv true)
            (string.gsub version "(%d).*(%d)" (fn [major minor]
              (set executionEnv.vkVersion {:major (tonumber major) :minor (tonumber minor)})))
            2)
      (:-S file) (do (asmFile file (if useExecutionEnv executionEnv)) 2)
      (:-c file) (do (compileFile file (if useExecutionEnv executionEnv)) 2)
      (:-t file) (do (translateFile file) 2)
      unrecognized (do (print "unrecognized argument" unrecognized) 1)
      nil nil))
  (when (not= nil consumed)
    (handleArgs (select (+ consumed 1) ...))))


(handleArgs (table.unpack arg))