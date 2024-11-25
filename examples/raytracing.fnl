;
; Based on the 'ray_tracing_position_fetch' shader in Vulkan-Samples by Sascha Willems.
; https://github.com/KhronosGroup/Vulkan-Samples/tree/main/shaders/ray_tracing_position_fetch/glsl
;

(require-macros :dsl.v1)
(extension :SPV_KHR_ray_tracing :SPV_KHR_ray_tracing_position_fetch)
(capability
  Shader
  RayTracingKHR
  RayTracingPositionFetchKHR)


(uniform (0 0) topLevelAS accelerationStructure)
(uniform (0 1) renderTarget (image :storage :2D :Rgba8))
(uniform (0 2) CameraProperties {
  viewInverse (mat4 f32)
  projInverse (mat4 f32)
  displayMode i32
})


(entrypoint rgen RayGenerationKHR []
  (var* hitValue (vec3 f32) RayPayloadKHR)
  (var* launchID (vec3 u32) Input (BuiltIn LaunchIdKHR))
  (var* launchSize (vec3 u32) Input (BuiltIn LaunchSizeKHR))

  (local pixelCenter (+ launchID.xy (f32 0.5)))
  (local inUV (/ pixelCenter launchSize.xy))
  (local d (*+ inUV 2 -1))

  ; (local origin (* CameraProperties.viewInverse ((vec4 f32) 0 0 0 1))) 
  (local origin (CameraProperties.viewInverse 3))
  (local target (* CameraProperties.projInverse ((vec4 f32) d 1 1)))
  (local direction (* CameraProperties.viewInverse ((vec4 f32) (normalize target.xyz) 0)))

  (local TMIN 0.001)
  (local TMAX 10000.0)

  (set* hitValue [0 0 0])
  (rt.traceRay
    topLevelAS     ; accelerationStructure
    :OpaqueKHR     ; ray flags
    0xFF           ; cull mask
    0              ; SBT offset
    0              ; SBT stride
    0              ; miss index
    origin.xyz     ; ray origin
    TMIN           ; ray tmin
    direction.xyz  ; ray direction
    TMAX           ; ray tmax
    hitValue)      ; payload (by name)

  (write renderTarget launchID.xy ((vec4 f32) hitValue 0)))


(entrypoint rmiss MissKHR []
  (var* hitValue (vec3 f32) IncomingRayPayloadKHR)
  (set* hitValue [0.0 0.0 0.2]))


(entrypoint rchit ClosestHitKHR []
  (var* hitValue (vec3 f32) IncomingRayPayloadKHR)
  (var* attribs (vec2 f32) HitAttributeKHR)
  (var* hitPositions [3 (vec3 f32)] Input (BuiltIn HitTriangleVertexPositionsKHR))
  (var* worldToObject (mat3x4 f32) Input (BuiltIn WorldToObjectKHR))

  (local* pos0 (hitPositions 0 :*))
  (local* pos1 (hitPositions 1 :*))
  (local* pos2 (hitPositions 2 :*))
  (local barycentricCoords
    ((vec3 f32) (- 1 attribs.x attribs.y) attribs.xy))

  (local currentPos
    (+ (* barycentricCoords.x pos0)
       (* barycentricCoords.y pos1)
       (* barycentricCoords.z pos2)))

  (if* 
    (eq? CameraProperties.displayMode 0)
      (do (var normal (normalize (cross (- pos1 pos0) (- pos2 pos0))))
          (set* hitValue (normalize ((* normal worldToObject) :xyz))))
    (eq? CameraProperties.displayMode 1)
      (set* hitValue currentPos)
    (set* hitValue [0 0 0])))
