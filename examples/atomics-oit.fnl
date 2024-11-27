;
; Based on the 'oit' (geometry.frag) example from Sascha Willems.
; https://github.com/SaschaWillems/Vulkan/tree/master/shaders/glsl/oit
;

(require-macros :dsl.v1)
(capability Shader)
(local { : Scope : MemorySemantics } spirv)


(type* Node {
  color (vec4 f32)
  depth f32
  next u32
})

(buffer (0 1) GeometrySBO {
  count u32
  maxNodeCount u32
})

(uniform (0 2) headIndexImage (image :storage :2D :R32ui) Coherent)

(buffer (0 3) LinkedListSBO {
  nodes [Node]
})

(pushConstant PushConsts {
  model (mat4 f32)
  color (vec4 f32)
})


(entrypoint main Fragment [OriginUpperLeft EarlyFragmentTests]

  (var* fragCoord (vec4 f32) Input (BuiltIn FragCoord))

  ; The default GLSL atomicAdd has a Device scope and no MemorySemantics flags (relaxed ordering).
  ; Here we can replicate this by passing equivalent settings.
  ; However, SPIRV is technically more flexible and depending on use case it might be useful to use e.g. 
  ; Scope.Workgroup, MemorySemantics.UniformMemory instead.
  (local nodeIdx (atomic.add GeometrySBO.count 1 Scope.Device (MemorySemantics))) 

  (when* (lt? nodeIdx GeometrySBO.maxNodeCount)

    ; SPIRV does not have separate atomic instructions for images.
    ; Instead we can retrieve a texel pointer from an image, and perform an atomic operation on its backing memory.
    (local* headIndexPtr (imageTexel headIndexImage fragCoord.xy))

    ; We want this operation to appear exactly here, not delayed until use, so local* enforces this.
    (local* prevHeadIdx (atomic.swap headIndexPtr nodeIdx :Device 0)) ; shorthands or integer values can be used for scope/memory semantics as well.

    (set* (LinkedListSBO.nodes nodeIdx :color) PushConsts.color)
    (set* (LinkedListSBO.nodes nodeIdx :depth) fragCoord.z)
    (set* (LinkedListSBO.nodes nodeIdx :next) prevHeadIdx)))