;
; Based on the 'geometryshader' (normaldebug.geom) example from Sascha Willems.
; https://github.com/SaschaWillems/Vulkan/blob/master/shaders/glsl/geometryshader/normaldebug.geom
;

(require-macros :dsl.v1)
(capability Shader Geometry)


(uniform (0 0) UBO {
  projection (mat4 f32)
  model      (mat4 f32)
})


(var* inPositions [3 (vec4 f32)] Input (BuiltIn Position))
(var* inNormals [3 (vec3 f32)] Input (Location 0))

(var* outPosition (vec4 f32) Output (BuiltIn Position))
(var* outColor (vec3 f32) Output (Location 0))


(entrypoint main Geometry
  [ Triangles (Invocations 1) OutputLineStrip (OutputVertices 6) ]

  (local normalLength 0.02)

  (for< [(i i32) 0 3]
    (local pos (inPositions i :xyz))
    (local normal (inNormals i))

    (set* outPosition (*r UBO.projection UBO.model ((vec4 f32) pos 1.0)))
    (set* outColor [1.0 0.0 0.0])
    (geometry.emitVertex)

    (set* outPosition (*r UBO.projection UBO.model ((vec4 f32) (*+ normal normalLength pos) 1.0)))
    (set* outColor [0.0 0.0 1.0])
    (geometry.emitVertex)
    (geometry.endPrimitive)))