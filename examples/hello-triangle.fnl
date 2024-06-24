(require-macros :dsl)
(capability Shader)


(var* positions [3 (vec2 f32)] Private NonWritable
  := [
    [ 0.0 -0.5]
    [ 0.5  0.5]
    [-0.5  0.5]
  ])

(var* colors [3 (vec3 f32)] Private NonWritable
  := [
    [1 0 0]
    [0 1 0]
    [0 0 1]
  ])

(entrypoint vertexMain Vertex []
  (var* vertexIndex u32 Input (BuiltIn VertexIndex))
  (var* position (vec4 f32) Output (BuiltIn Position))
  (var* fragColor (vec3 f32) Output (Location 0))

  (set* position ((vec4 f32) (positions vertexIndex) 0.0 1.0))
  (set* fragColor (colors vertexIndex)))

(entrypoint fragmentMain Fragment [OriginUpperLeft]
  (var* fragColor (vec3 f32) Input (Location 0))
  (var* outColor (vec4 f32) Output (Location 0))
  (set* outColor ((vec4 f32) fragColor 1.0)))