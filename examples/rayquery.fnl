;
; Based on the 'rayquery' example by Sascha Willems.
; https://github.com/SaschaWillems/Vulkan/blob/master/shaders/glsl/rayquery/scene.frag
;

(require-macros :dsl.v1)
(capability Shader RayQueryKHR)
(extension :SPV_KHR_ray_query)

(local { : RayFlags : RayQueryCommittedIntersectionType } spirv)

(local v3f (vec3 f32))

(var* inNormal   v3f Input (Location 0))
(var* inColor    v3f Input (Location 1))
(var* inViewVec  v3f Input (Location 2))
(var* inLightVec v3f Input (Location 3))
(var* inWorldPos v3f Input (Location 4))

(var* outFragColor (vec4 f32) Output (Location 0))

(uniform (0 1) topLevelAS accelerationStructure)

(local ambient 0.1)


(entrypoint main Fragment [OriginUpperLeft] 
  (local N (normalize inNormal))
  (local L (normalize inLightVec))
  (local V (normalize inViewVec))
  (local R (normalize (- (reflect L N))))

  (local diffuse (* inColor (max ambient (dot N L))))

  (set* outFragColor ((vec4 f32) diffuse 1.0))

  (var* rq rayQuery)

  (rt.initializeRayQuery rq topLevelAS :TerminateOnFirstHitKHR 0xFF inWorldPos 0.01 L 1000.0)
  (rt.proceedRayQuery rq)

  (when* (eq? (rt.getRayQueryIntersectionType rq 1) RayQueryCommittedIntersectionType.RayQueryCommittedIntersectionTriangleKHR)
    (set* outFragColor (* outFragColor 0.1))))