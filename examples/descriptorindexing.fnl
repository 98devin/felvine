;
; Based on the 'descriptorindexing' example from Sascha Willems
; https://github.com/SaschaWillems/Vulkan/tree/master/shaders/glsl/descriptorindexing
;

(require-macros :dsl.v1)
(capability
  Shader 
  ShaderNonUniform
  RuntimeDescriptorArray
  SampledImageArrayNonUniformIndexing)


(uniform (0 0) Matrices {
	projection (mat4 f32)
	view (mat4 f32)
	model (mat4 f32)
})

(uniform (0 1) Textures [(sampled-image :2D)])


(entrypoint vertexMain Vertex []
  (var* inPos (vec3 f32) Input (Location 0))
  (var* inUV (vec2 f32) Input (Location 1))
  (var* inTextureIndex i32 Input (Location 2))

  (var* outUV (vec2 f32) Output (Location 0))
  (var* outTextureIndex i32 Output (Location 1) Flat)
  (var* outPos (vec4 f32) Output (BuiltIn Position))

  (set* outUV inUV)
  (set* outTextureIndex inTextureIndex)
  (local pos ((vec4 f32) inPos 1.0))
  (set* outPos
    (*r 
      Matrices.projection
      Matrices.view
      Matrices.model
      pos
    )))


(entrypoint fragMain Fragment [OriginUpperLeft]
  (var* inUV (vec2 f32) Input (Location 0))
  (var* inTextureIndex i32 Input (Location 1) Flat)

  (var* outFragColor (vec4 f32) Output (Location 0))
  
  (local* nonuniformTextureIndex (inTextureIndex :*) NonUniform)
  (local* nonuniformTexture (Textures nonuniformTextureIndex) NonUniform)

  (set* outFragColor (sample nonuniformTexture inUV)))