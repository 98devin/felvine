;
; Based on the 'meshshader' example by Sascha Willems.
; https://github.com/SaschaWillems/Vulkan/blob/master/shaders/glsl/meshshader/meshshader.mesh
;

(require-macros :dsl.v1)
(capability Shader MeshShadingEXT)
(extension :SPV_EXT_mesh_shader)


(uniform (0 0) UBO {
  projection (mat4 f32)
  model      (mat4 f32)
  view       (mat4 f32)
})


(var* globalInvocation (vec3 u32) Input (BuiltIn GlobalInvocationId))
(var* localInvocation u32 Input (BuiltIn LocalInvocationIndex))

(local OUTPUT_VERTS 3)
(local OUTPUT_PRIMS 1)

(var* outColors           [OUTPUT_VERTS (vec4 f32)] Output (Location 0))
(var* outPositions        [OUTPUT_VERTS (vec4 f32)] Output (BuiltIn Position))
(var* outPrimitiveIndices [OUTPUT_PRIMS (vec3 u32)] Output (BuiltIn PrimitiveTriangleIndicesEXT))

(var* positions [OUTPUT_VERTS (vec4 f32)] Private NonWritable
  := [
    [ 0 -1 0 1]
    [-1  1 0 1]
    [ 1  1 0 1]
  ])

(var* colors [OUTPUT_VERTS (vec4 f32)] Private NonWritable
  := [
    [1 0 0 1]
    [0 1 0 1]
    [0 0 1 1]
  ])


(entrypoint meshMain MeshEXT
  [ (OutputVertices OUTPUT_VERTS) (OutputPrimitivesEXT OUTPUT_PRIMS) OutputTrianglesEXT (LocalSizeId 1 1 1) ]

  (local* offset ((vec4 f32) 0 0 globalInvocation.x 0))

  (mesh.set-mesh-outputs OUTPUT_VERTS OUTPUT_PRIMS)

  (local* mvp (* UBO.projection UBO.view UBO.model))

  (for [i 0 2]
    (set* (outPositions i) (* mvp (+ (positions i) offset)))
    (set* (outColors i)    (colors i)))
  
  (set* (outPrimitiveIndices localInvocation) [0 1 2]))