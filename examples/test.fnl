(require-macros :dsl)

(local
  { : ExecutionModel
    : ExecutionMode
    : StorageClass
    : Op
    : Decoration
    : BuiltIn
  } spirv)

(capability
  Shader
  SparseResidency
  SampledBuffer
  ImageBuffer
  Image1D
  ImageCubeArray
  ImageGatherExtended
  Sampled1D
  Int8
  Int16
  Int64
  Float64
  FragmentBarycentricKHR
  GroupNonUniformArithmetic
  GroupNonUniformClustered
  PhysicalStorageBufferAddresses)

(extension
  :SPV_EXT_descriptor_indexing)

(when (supported? :SPV_EXT_mesh_shader)
  (capability :MeshShadingEXT))

(var* Position (vec4 f32) StorageClass.Input
   (BuiltIn Position))

(type* Material {
  albedo u32
  normal u32
  roughness u32
})

(ref-types*
  Node { left Node right Node content f32 }
  Tree { root Node all-children [Node] })

(uniform (0 0) MaterialData {
  materials [Material]
})

(buffer (0 2) GeometryData [128 {
  positions [(vec3 f32)]
}])

(push-constant CameraData { 
  position (vec3 f32)
  transform ((mat4x3 f32) RowMajor)
  inv-transform [2 2 (mat3x4 f32)]
  fov f32
})


(uniform (0 1) MaterialTextures [1024 (sampled-image :2D)])


(var* Color (vec4 f32) StorageClass.Output
  (Decoration.Location 0))


(fn test-operations [x y] 
  (+ (- x)   ; __unm
     (+ x y) ; __add
     (- x y) ; __sub
     (* x y) ; __mul
     (/ x y) ; __div
     (% x y) ; __mod
     (^ x y) ; __pow via glsl ext
     (*+ x x y) ; fma via glsl ext
    ))

; (var* total f32             := 0)
; (var* total []f32           := [0 0 0])
; (var* total {:0 f32 :1 f32} := {:x 10 :y 20})

; (uniform* (0 0) Images2D
;   { sampledImage2D })
; (buffer* )

; (var* (Input) VertexInput 
;   { 
;     direction v3f32 })

; (var* (Output) VertexOutput
;   { position v4f32 (BuiltIn Position) })

; (set* VertexOutput.position (v4f32 0 0 0 1))


(fn* test-number-operations f32 [(s8 i8) (s16 i16) (s32 i32) (s64 i64)
                            (w8 u8) (w16 u16) (w32 u32) (w64 u64)
                            (f f32) (d f64)]
  (local args [s8 s16 s32 s64 w8 w16 w32 w64 f d])
  (var* total f32 := 0)
  (each [_ x (ipairs args)]
    (set* total (+ total (test-operations x x))))
  (deref total))


(fn* test-vector-projections f32 [(v (vec4 f32))]
  (local single-component 
    (+ (+ v.x v.y v.z v.w)
     (+ v.r v.g v.b v.a)
     (+ v.u v.v v.s v.t)
     (+ v.0 v.1 v.2 v.3)
     (+ (v 0) (v 1) (v 2) (v 3))))
  (local two-component
    ((+ v.xy v.yz v.zw v.wx) 1))
  (local three-component
    ((+ v.xxx v.ggg v.sss v.333) 2))
  (local four-component
    ((+ v.wzwz v.abgr v.stuv v.0213) 3))
  (+ single-component two-component three-component four-component))

(fn* test-conditional-operations f32 [(a i32) (b i32) (c f32) (d f32) (e (vec2 i32)) (f (vec2 i32))]
  (if* (any? (lt? e f)) (f32 e.0)
       (all? (gt? e f)) (f32 f.0)
       (gte? a b) (f32 a)
       (neq? c d) (if* (lte? a c) c d)
       (any? (eq? b e)) c d))

(fn* test-loop-operations f32 [(a i32) (b i32)]
  (var* j i32 := 0)

  (while* (lt? j b)
    (set* j (+ j a)))
    
  (for* [(i i32) j 10]
    (set* j (+ j i)))

  (for* [(i i32) j 20 2]
    (set* j (+ j i)))

  j)

(fn* test-constant-propagation i32 [(a i32)]
  (+ a (+
    (test-operations (i32 10) (i32 2))
    (test-operations (u32 10) (u32 2))
    (test-operations (f32 10) (f32 2))
    ((test-operations ((vec3 f32) 10) ((vec3 f32) 2)) 0)
    ((test-operations ((vec3 u32) 10) ((vec3 u32) 2)) 0)
    (test-operations (u64 10) (u64 2)))))


(fn* pbr-neutral-tonemapping (vec3 f32) [(color (vec3 f32))]
  (local start-compression (- 0.8 0.04))
  (local desaturation 0.15)
  
  (local x (min color.r color.g color.b))
  (local offset
    (select (lt? x 0.08) (* x x (- x 6.25)) 0.04))
  
  (local color (- color offset))
  (local peak (max color.r color.g color.b))
  
  (if* (lt? peak start-compression) color
    (do
      (local d (- 1 start-compression))
      (local new-peak
        (/ (- 1 (* d d)) (- (+ peak d) start-compression)))
      (local color (* color (/ new-peak peak)))

      (local g (- 1 (/ 1 (+ 1 (* desaturation (- peak new-peak))))))
      (mix color new-peak g)
    )))


(fn* test-matrix-operations (mat3 f32) [(m (mat3 f32))]
  (local det (determinant (invert m)))
  (local v (m 0))
  (local (vwhole vfrac) (modf v))
  (local w (dot v (*r m vwhole)))
  (* m (+ det w)))


(fn* test-subgroup-operations f32 [(a f32)]
  (local add-total (subgroup.add a))
  (local add-inclusive (subgroup.add a :InclusiveScan))
  (local add-exclusive (subgroup.add a :ExclusiveScan))
  (local add-clustered (subgroup.add a :ClusteredReduce 4))

  (+ add-total
     add-inclusive
     add-exclusive
     add-clustered))


(local image-1D         (sampled-image :1D          f32))
(local image-2D         (sampled-image :2D          f32))
(local image-3D         (sampled-image :3D          f32))
(local image-Cube       (sampled-image :Cube        f32))
(local image-1D-array   (sampled-image :1D   :array f32))
(local image-2D-array   (sampled-image :2D   :array f32))
(local image-Cube-array (sampled-image :Cube :array f32))

(local storage-image-1D         (image :storage :1D          f32))
(local storage-image-2D         (image :storage :2D          f32))
(local storage-image-3D         (image :storage :3D          f32))
(local storage-image-Cube       (image :storage :Cube        f32))
(local storage-image-1D-array   (image :storage :1D   :array f32))
(local storage-image-2D-array   (image :storage :2D   :array f32))
(local storage-image-Cube-array (image :storage :Cube :array f32))

(local uniform-texel-buffer (image :sampled :Buffer :R32f))
(local storage-texel-buffer (image :storage :Buffer :R32f))

(fn* test-image-sample-operations (vec4 f32)
  [ (im-1D image-1D)          
    (im-2D image-2D)          
    (im-3D image-3D)          
    (im-Cube image-Cube)        
    (im-1D-array image-1D-array)    
    (im-2D-array image-2D-array)    
    (im-Cube-array image-Cube-array)
    (uv-1D f32)
    (uv-2D (vec2 f32))
    (uv-3D (vec3 f32))
    (uv-Cube (vec3 f32))
    (uv-1D-array (vec2 f32))
    (uv-2D-array (vec3 f32))
    (uv-Cube-array (vec4 f32)) ]

  (+ (sample im-1D         uv-1D)
     (sample im-2D         uv-2D)
     (sample im-3D         uv-3D)
     (sample im-Cube       uv-Cube)
     (sample im-1D-array   uv-1D-array)
     (sample im-2D-array   uv-2D-array)
     (sample im-Cube-array uv-Cube-array)

     ((sample im-1D         uv-1D         :Sparse) :1)
     ((sample im-2D         uv-2D         :Sparse) :1)
     ((sample im-3D         uv-3D         :Sparse) :1)
     ((sample im-Cube       uv-Cube       :Sparse) :1)
     ((sample im-1D-array   uv-1D-array   :Sparse) :1)
     ((sample im-2D-array   uv-2D-array   :Sparse) :1)
     ((sample im-Cube-array uv-Cube-array :Sparse) :1)
     
     (sample im-1D         uv-1D         :Lod 0)
     (sample im-2D         uv-2D         :Lod 0)
     (sample im-3D         uv-3D         :Lod 0)
     (sample im-Cube       uv-Cube       :Lod 0)
     (sample im-1D-array   uv-1D-array   :Lod 0)
     (sample im-2D-array   uv-2D-array   :Lod 0)
     (sample im-Cube-array uv-Cube-array :Lod 0)

     (sample im-1D         uv-1D         :Grad uv-1D uv-1D)
     (sample im-2D         uv-2D         :Grad uv-2D uv-2D)
     (sample im-3D         uv-3D         :Grad uv-3D uv-3D)
     (sample im-Cube       uv-Cube       :Grad uv-Cube uv-Cube)
     (sample im-1D-array   uv-1D-array   :Grad uv-1D uv-1D)
     (sample im-2D-array   uv-2D-array   :Grad uv-2D uv-2D)
     (sample im-Cube-array uv-Cube-array :Grad uv-Cube uv-Cube)

     (sample im-1D         uv-1D-array   :Proj)
     (sample im-2D         uv-2D-array   :Proj)
     (sample im-3D         uv-Cube-array :Proj)
     
     (sample im-1D         uv-1D-array   :Proj :Lod 0)
     (sample im-2D         uv-2D-array   :Proj :Lod 0)
     (sample im-3D         uv-Cube-array :Proj :Lod 0)

     (sample im-1D         uv-1D-array   :Proj :Grad uv-1D uv-1D)
     (sample im-2D         uv-2D-array   :Proj :Grad uv-2D uv-2D)
     (sample im-3D         uv-Cube-array :Proj :Grad uv-3D uv-3D)

     (+ (sample im-1D         uv-1D         :Dref 0.0)
        (sample im-2D         uv-2D         :Dref 0.0)
        (sample im-3D         uv-3D         :Dref 0.0)
        (sample im-Cube       uv-Cube       :Dref 0.0)
        (sample im-1D-array   uv-1D-array   :Dref 0.0)
        (sample im-2D-array   uv-2D-array   :Dref 0.0)
        (sample im-Cube-array uv-Cube-array :Dref 0.0)
        
        (sample im-1D         uv-1D         :Dref 0.0 :Lod 0)
        (sample im-2D         uv-2D         :Dref 0.0 :Lod 0)
        (sample im-3D         uv-3D         :Dref 0.0 :Lod 0)
        (sample im-Cube       uv-Cube       :Dref 0.0 :Lod 0)
        (sample im-1D-array   uv-1D-array   :Dref 0.0 :Lod 0)
        (sample im-2D-array   uv-2D-array   :Dref 0.0 :Lod 0)
        (sample im-Cube-array uv-Cube-array :Dref 0.0 :Lod 0)
    
        (sample im-1D         uv-1D-array   :Proj :Dref 0.0)
        (sample im-2D         uv-2D-array   :Proj :Dref 0.0)
        (sample im-3D         uv-Cube-array :Proj :Dref 0.0)
        
        (sample im-1D         uv-1D-array   :Proj :Dref 0.0 :Lod 0)
        (sample im-2D         uv-2D-array   :Proj :Dref 0.0 :Lod 0)
        (sample im-3D         uv-Cube-array :Proj :Dref 0.0 :Lod 0)
        
        )))

(fn* test-image-gather-operations (vec4 f32)
  [ (im-2D image-2D)          
    (im-3D image-3D)          
    (im-Cube image-Cube)        
    (im-1D-array image-1D-array)    
    (im-2D-array image-2D-array)    
    (im-Cube-array image-Cube-array)
    
    (uv-2D (vec2 f32))
    (uv-3D (vec3 f32))
    (uv-Cube (vec3 f32))
    (uv-1D-array (vec2 f32))
    (uv-2D-array (vec3 f32))
    (uv-Cube-array (vec4 f32)) ]

  (+ (gather im-2D         uv-2D         0)
     (gather im-Cube       uv-Cube       0)
     (gather im-2D-array   uv-2D-array   0)
     (gather im-Cube-array uv-Cube-array 0)
     
     (gather im-2D         uv-2D         0 :Offset uv-2D)
     (gather im-2D-array   uv-2D-array   0 :Offset uv-2D)
     
     (gather im-2D         uv-2D         0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
     (gather im-2D-array   uv-2D-array   0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])

     (+ (gather im-2D         uv-2D         :Dref 0.0 :Offset uv-2D)
        (gather im-2D-array   uv-2D-array   :Dref 0.0 :Offset uv-2D)
        
        (gather im-2D         uv-2D         :Dref 0.0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
        (gather im-2D-array   uv-2D-array   :Dref 0.0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
        )))

(fn* test-image-fetch-operations (vec4 f32) 
  [ (im-1D image-1D)          
    (im-2D image-2D)          
    (im-3D image-3D)            
    (im-1D-array image-1D-array)    
    (im-2D-array image-2D-array)    
    
    (storage-im-1D storage-image-1D)          
    (storage-im-2D storage-image-2D)          
    (storage-im-3D storage-image-3D)            
    (storage-im-Cube storage-image-Cube)    
    (storage-im-1D-array storage-image-1D-array)    
    (storage-im-2D-array storage-image-2D-array)    
    (storage-im-Cube-array storage-image-Cube-array)    

    (utb uniform-texel-buffer)
    (stb storage-texel-buffer)

    (uv-1D u32)
    (uv-2D (vec2 u32))
    (uv-3D (vec3 u32))
    (uv-Cube (vec3 u32))
    (uv-1D-array (vec2 u32))
    (uv-2D-array (vec3 u32))
    (uv-Cube-array (vec4 u32)) ]

  (+ (fetch im-1D         uv-1D)
     (fetch utb           uv-1D)
     (fetch stb           uv-1D)
     (fetch im-2D         uv-2D)
     (fetch im-3D         uv-3D)
     (fetch im-1D-array   uv-1D-array)
     (fetch im-2D-array   uv-2D-array)
     
     (fetch im-1D         uv-1D         :Lod 1)
     (fetch im-2D         uv-2D         :Lod 1)
     (fetch im-3D         uv-3D         :Lod 1)
     (fetch im-1D-array   uv-1D-array   :Lod 1)
     (fetch im-2D-array   uv-2D-array   :Lod 1)
     
     (fetch storage-im-1D         uv-1D)
     (fetch storage-im-2D         uv-2D)
     (fetch storage-im-3D         uv-3D)
     (fetch storage-im-Cube       uv-Cube)
     (fetch storage-im-1D-array   uv-1D-array)
     (fetch storage-im-2D-array   uv-2D-array)
     (fetch storage-im-Cube-array uv-Cube-array)))





(fn* test-types f32
  [ (num f32)
    (vec (vec3 f32))
    (mat (mat4 f32))
    (array [10 f32])
    (runtime-array [f32])
    (ptr [*P f32] Restrict)
    (struct {
      x (f32 (BuiltIn BaryCoordKHR))
      y (f32 (BuiltIn Position)) 
    })
  ]
  num)



(entrypoint main Fragment [OriginUpperLeft]

  (local pos (+ Position
    (test-number-operations 1 1 1 1 1 1 1 1 1 1)
    (test-vector-projections 1)
    (test-conditional-operations 1 1 1 1 1 1)
    (test-loop-operations 1 1)
    (test-constant-propagation 1)
    (test-subgroup-operations 1)))

  (set* Color ((vec4 f32) (pbr-neutral-tonemapping pos.xyz) pos.w)))
