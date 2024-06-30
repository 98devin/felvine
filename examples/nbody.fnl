(require-macros :dsl.v1)
(capability Shader)

(type* Particle {
  pos (vec4 f32)
  vel (vec4 f32)
})

(const* LOCAL_SIZE_X     u32 := 0     (SpecId 0))
(const* SHARED_DATA_SIZE u32 := 1024  (SpecId 1))
(const* GRAVITY          f32 := 0.002 (SpecId 2))
(const* POWER            f32 := 0.75  (SpecId 3))
(const* SOFTEN           f32 := 0.05  (SpecId 4))

(local TIME_FACTOR 0.5)

(var* sharedData [SHARED_DATA_SIZE (vec4 f32)] Workgroup)
(var* globalInvocation (vec3 u32) Input (BuiltIn GlobalInvocationId))
(var* localInvocation (vec3 u32) Input (BuiltIn LocalInvocationId))

(buffer (0 0) Pos {
  particles [Particle]
})

(uniform (0 1) UBO {
  deltaT f32
  particleCount u32
})

(entrypoint main GLCompute [(LocalSizeId LOCAL_SIZE_X 1 1)]
  (local index globalInvocation.x)

  (when* (lt? index UBO.particleCount)

    (local localIndex localInvocation.x)
    (local position (Pos.particles index :pos))
    (local velocity (Pos.particles index :vel))
    (var* acceleration (vec3 f32) := 0.0)

    (for* [(i u32) 0 (- UBO.particleCount 1) SHARED_DATA_SIZE]

      (if* (lt? (+ i localIndex) UBO.particleCount)
        (set* (sharedData localIndex) (Pos.particles (+ i localIndex) :pos))
        (set* (sharedData localIndex) 0.0))

      (barrier)

      (for* [(j u32) 0 (- LOCAL_SIZE_X 1)]
        (local other (sharedData j))
        (local len (- other.xyz position.xyz))
        (set* acceleration
          (+ acceleration
            (* GRAVITY len
              (/ other.w (^ (+ SOFTEN (dot len len)) POWER))))))

      (barrier))
    
    (set* velocity
      ((vec4 f32)        (+ velocity.xyz (* UBO.deltaT TIME_FACTOR acceleration))
                  (fract (+ velocity.w   (* UBO.deltaT TIME_FACTOR 0.1)))))
  
    ))