;
; A kitchen-sink demonstration of various builtins, syntax, etc.
;

(require-macros :dsl.v1)

(local
  { : ExecutionModel
    : ExecutionMode
    : StorageClass
    : Op
    : Decoration
    : BuiltIn
    : MemoryAccess
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
  GroupNonUniformArithmetic
  GroupNonUniformClustered
  PhysicalStorageBufferAddresses)

(extension
  :SPV_EXT_descriptor_indexing)

(when (supported? :SPV_EXT_mesh_shader)
  (capability :MeshShadingEXT))

(var* Position (vec4 f32) StorageClass.Input
  (Location 0))

(type* Material {
  albedo u32
  normal u32
  roughness u32
})

(type* Data {
  vector (vec3 f32)
  matrix (mat3x3 f32)
  array [10 f32]
  pointer [*P { x f32 y f32 }]
})

(refTypes*
  Node { left Node right Node content f32 }
  Tree { root Node all-children Node })

(buffer (0 0) MaterialData {
  materials [Material]
} NonWritable)

(buffer (0 2) GeometryData [128 {
  positions [(vec3 f32)]
}])

(pushConstant CameraData { 
  position (vec3 f32)
  transform ((mat4x3 f32) RowMajor)
  inv-transform [2 2 (mat3x4 f32)]
  fov f32
})


(uniform (0 1) MaterialTextures [1024 (sampledImage :2D)])


(var* Color (vec4 f32) StorageClass.Output
  (Decoration.Location 0))


(fn testOperations [x y] 
  (+ (- x)   ; __unm
     (+ x y) ; __add
     (- x y) ; __sub
     (* x y) ; __mul
     (/ x y) ; __div
     (% x y) ; __mod
     (^ x y) ; __pow via glsl ext
     (*+ x x y) ; fma via glsl ext
    ))


(fn* testNumberOperations f32 [(s8 i8) (s16 i16) (s32 i32) (s64 i64)
                            (w8 u8) (w16 u16) (w32 u32) (w64 u64)
                            (f f32) (d f64)]
  (local args [s8 s16 s32 s64 w8 w16 w32 w64 f d])
  (var* total f32 := 0)
  (each [_ x (ipairs args)]
    (set* total (+ total (testOperations x x))))
  (deref total))


(fn* testVectorProjections f32 [(v (vec4 f32))]
  (local singleComponent 
    (+ (+ v.x v.y v.z v.w)
     (+ v.r v.g v.b v.a)
     (+ v.u v.v v.s v.t)
     (+ v.0 v.1 v.2 v.3)
     (+ (v 0) (v 1) (v 2) (v 3))))
  (local twoComponent
    ((+ v.xy v.yz v.zw v.wx) 1))
  (local threeComponent
    ((+ v.xxx v.ggg v.sss v.333) 2))
  (local fourComponent
    ((+ v.wzwz v.abgr v.stuv v.0213) 3))
  (+ singleComponent twoComponent threeComponent fourComponent))

(fn* testConditionalOperations f32 [(a i32) (b i32) (c f32) (d f32) (e (vec2 i32)) (f (vec2 i32))]
  (if* (any? (lt? e f)) (f32 e.0)
       (all? (gt? e f)) (f32 f.0)
       (gte? a b) (f32 a)
       (neq? c d) (if* (lte? a c) c d)
       (any? (eq? b e)) c d))

(fn* testLoopOperations f32 [(a i32) (b i32)]
  (var* j i32 := 0)

  (while* (lt? j b)
    (set* j (+ j a)))
    
  (for* [(i i32) j 10]
    (set* j (+ j i)))


  (for< [(i i32) j 10]
    (set* j (- j i)))


  (for* [(i i32) j (* 2 j) 2]
    (set* j (+ j i)))

  j)

(fn* testConstantPropagation i32 [(a i32)]
  (+ a (+
    (testOperations (i32 10) (i32 2))
    (testOperations (u32 10) (u32 2))
    (testOperations (f32 10) (f32 2))
    ((testOperations ((vec3 f32) 10) ((vec3 f32) 2)) 0)
    ((testOperations ((vec3 u32) 10) ((vec3 u32) 2)) 0)
    (testOperations (u64 10) (u64 2)))))


(fn* testMatrixOperations (mat3 f32) [(m (mat3 f32))]
  (local det (determinant (invert m)))
  (local v (m 0))
  (local (vwhole vfrac) (modf v))
  (local w (dot v (*r m vwhole)))
  (* m (+ det w)))


(fn* testSubgroupOperations f32 [(a f32)]
  (local addTotal (subgroup.add a))
  (local addInclusive (subgroup.add a :InclusiveScan))
  (local addExclusive (subgroup.add a :ExclusiveScan))
  (local addClustered (subgroup.add a :ClusteredReduce 4))

  (+ addTotal
     addInclusive
     addExclusive
     addClustered))


(local image1D        (sampledImage :1D          f32))
(local image2D        (sampledImage :2D          f32))
(local image3D        (sampledImage :3D          f32))
(local imageCube      (sampledImage :Cube        f32))
(local image1DArray   (sampledImage :1D   :array f32))
(local image2DArray   (sampledImage :2D   :array f32))
(local imageCubeArray (sampledImage :Cube :array f32))

(local storageImage1D        (image :storage :1D          f32 :Rgba32f))
(local storageImage2D        (image :storage :2D          f32 :Rgba32f))
(local storageImage3D        (image :storage :3D          f32 :Rgba32f))
(local storageImageCube      (image :storage :Cube        f32 :Rgba32f))
(local storageImage1DArray   (image :storage :1D   :array f32 :Rgba32f))
(local storageImage2DArray   (image :storage :2D   :array f32 :Rgba32f))
(local storageImageCubeArray (image :storage :Cube :array f32 :Rgba32f))

(local uniformTexelBuffer (image :sampled :Buffer :R32f))
(local storageTexelBuffer (image :storage :Buffer :R32f))

(fn* testImageSampleOperations (vec4 f32)
  [ (im1D image1D)          
    (im2D image2D)          
    (im3D image3D)          
    (imCube imageCube)        
    (im1DArray image1DArray)    
    (im2DArray image2DArray)    
    (imCubeArray imageCubeArray)
    (uv1D f32)
    (uv2D (vec2 f32))
    (uv3D (vec3 f32))
    (uvCube (vec3 f32))
    (uv1DArray (vec2 f32))
    (uv2DArray (vec3 f32))
    (uvCubeArray (vec4 f32)) ]

  (+ (sample im1D         uv1D)
     (sample im2D         uv2D)
     (sample im3D         uv3D)
     (sample imCube       uvCube)
     (sample im1DArray   uv1DArray)
     (sample im2DArray   uv2DArray)
     (sample imCubeArray uvCubeArray)

     ((sample im1D         uv1D         :Sparse) :1)
     ((sample im2D         uv2D         :Sparse) :1)
     ((sample im3D         uv3D         :Sparse) :1)
     ((sample imCube       uvCube       :Sparse) :1)
     ((sample im1DArray   uv1DArray   :Sparse) :1)
     ((sample im2DArray   uv2DArray   :Sparse) :1)
     ((sample imCubeArray uvCubeArray :Sparse) :1)
     
     (sample im1D         uv1D         :Lod 0)
     (sample im2D         uv2D         :Lod 0)
     (sample im3D         uv3D         :Lod 0)
     (sample imCube       uvCube       :Lod 0)
     (sample im1DArray   uv1DArray   :Lod 0)
     (sample im2DArray   uv2DArray   :Lod 0)
     (sample imCubeArray uvCubeArray :Lod 0)

     (sample im1D         uv1D         :Grad uv1D uv1D)
     (sample im2D         uv2D         :Grad uv2D uv2D)
     (sample im3D         uv3D         :Grad uv3D uv3D)
     (sample imCube       uvCube       :Grad uvCube uvCube)
     (sample im1DArray   uv1DArray   :Grad uv1D uv1D)
     (sample im2DArray   uv2DArray   :Grad uv2D uv2D)
     (sample imCubeArray uvCubeArray :Grad uvCube uvCube)

     (sample im1D         uv1DArray   :Proj)
     (sample im2D         uv2DArray   :Proj)
     (sample im3D         uvCubeArray :Proj)
     
     (sample im1D         uv1DArray   :Proj :Lod 0)
     (sample im2D         uv2DArray   :Proj :Lod 0)
     (sample im3D         uvCubeArray :Proj :Lod 0)

     (sample im1D         uv1DArray   :Proj :Grad uv1D uv1D)
     (sample im2D         uv2DArray   :Proj :Grad uv2D uv2D)
     (sample im3D         uvCubeArray :Proj :Grad uv3D uv3D)

     (+ (sample im1D         uv1D         :Dref 0.0)
        (sample im2D         uv2D         :Dref 0.0)
        (sample imCube       uvCube       :Dref 0.0)
        (sample im1DArray   uv1DArray   :Dref 0.0)
        (sample im2DArray   uv2DArray   :Dref 0.0)
        (sample imCubeArray uvCubeArray :Dref 0.0)
        
        (sample im1D         uv1D         :Dref 0.0 :Lod 0)
        (sample im2D         uv2D         :Dref 0.0 :Lod 0)
        (sample imCube       uvCube       :Dref 0.0 :Lod 0)
        (sample im1DArray   uv1DArray   :Dref 0.0 :Lod 0)
        (sample im2DArray   uv2DArray   :Dref 0.0 :Lod 0)
        (sample imCubeArray uvCubeArray :Dref 0.0 :Lod 0)
    
        (sample im1D         uv1DArray   :Proj :Dref 0.0)
        (sample im2D         uv2DArray   :Proj :Dref 0.0)
        
        (sample im1D         uv1DArray   :Proj :Dref 0.0 :Lod 0)
        (sample im2D         uv2DArray   :Proj :Dref 0.0 :Lod 0)
        
        )))

(fn* testImageGatherOperations (vec4 f32)
  [ (im2D image2D)          
    (im3D image3D)          
    (imCube imageCube)        
    (im1DArray image1DArray)    
    (im2DArray image2DArray)    
    (imCubeArray imageCubeArray)
    
    (uv2D (vec2 f32))
    (uv3D (vec3 f32))
    (uvCube (vec3 f32))
    (uv1DArray (vec2 f32))
    (uv2DArray (vec3 f32))
    (uvCubeArray (vec4 f32)) ]

  (+ (gather im2D         uv2D         0)
     (gather imCube       uvCube       0)
     (gather im2DArray   uv2DArray   0)
     (gather imCubeArray uvCubeArray 0)
     
     (gather im2D         uv2D         0 :Offset uv2D)
     (gather im2DArray   uv2DArray   0 :Offset uv2D)
     
     (gather im2D         uv2D         0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
     (gather im2DArray   uv2DArray   0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])

     (+ (gather im2D         uv2D         :Dref 0.0 :Offset uv2D)
        (gather im2DArray   uv2DArray   :Dref 0.0 :Offset uv2D)
        
        (gather im2D         uv2D         :Dref 0.0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
        (gather im2DArray   uv2DArray   :Dref 0.0 :ConstOffsets [[1 1] [1 1] [1 1] [1 1]])
        )))

(fn* testImageFetchOperations (vec4 f32) 
  [ (im1D image1D)          
    (im2D image2D)          
    (im3D image3D)            
    (im1DArray image1DArray)    
    (im2DArray image2DArray)    
    
    (storageIm1D storageImage1D)          
    (storageIm2D storageImage2D)          
    (storageIm3D storageImage3D)            
    (storageImCube storageImageCube)    
    (storageIm1DArray storageImage1DArray)    
    (storageIm2DArray storageImage2DArray)    
    (storageImCubeArray storageImageCubeArray)    

    (utb uniformTexelBuffer)
    (stb storageTexelBuffer)

    (uv1D u32)
    (uv2D (vec2 u32))
    (uv3D (vec3 u32))
    (uvCube (vec3 u32))
    (uv1DArray (vec2 u32))
    (uv2DArray (vec3 u32))
    (uvCubeArray (vec4 u32)) ]

  (+ (fetch im1D         uv1D)
     (fetch utb           uv1D)
     (fetch stb           uv1D)
     (fetch im2D         uv2D)
     (fetch im3D         uv3D)
     (fetch im1DArray   uv1DArray)
     (fetch im2DArray   uv2DArray)
     
     (fetch im1D         uv1D         :Lod 1)
     (fetch im2D         uv2D         :Lod 1)
     (fetch im3D         uv3D         :Lod 1)
     (fetch im1DArray   uv1DArray   :Lod 1)
     (fetch im2DArray   uv2DArray   :Lod 1)
     
     (fetch storageIm1D         uv1D)
     (fetch storageIm2D         uv2D)
     (fetch storageIm3D         uv3D)
     (fetch storageImCube       uvCube)
     (fetch storageIm1DArray   uv1DArray)
     (fetch storageIm2DArray   uv2DArray)
     (fetch storageImCubeArray uvCubeArray)))


(fn* testIndexing void [(data Data) (otherPointerValue [*P { x f32 y f32 }] Aliased)]
  (var* data Data := data)

  (local v data.vector) ; Field access can use `.` in many cases
  (local v (data :vector)) ; Field access can also be written `(struct :field)` though. Allows computing field name at compile time.

  (local v0 (v 0)) ; Vector indexing is written `(vector index)`. indexing is zero-based (per SPIRV).
  (local vX v.x) ; Swizzling allows accessing vector elements by other names: xyzw, rgba, or 0123
  (local vXY (v :xy)) ; Swizzles can also be written like this.

  (local m00  (data :matrix 0 0))  ; When using the list style indexing, we can chain multiple accesses together to get deeper elements.
  (local m0yz (data.matrix 0 :yz)) ; Matrix indexing returns columns, which we can then swizzle if we desire.

  ; Note: p is a Function* PhysicalStorageBuffer* since variables are initially pointer-valued and indexing preserves the leading pointer in the type.
  (local p data.pointer) 

  ; Felvine auto-dereferences pointer indirections, here we have two!
  ; So all of the below are valid and equivalent, such that px is PhysicalStorageBuffer* f32

  (local px p.x) 
  (local px p.*.x)
  (local px (p :* :x)) 

  ; Often you do want the indexed value to be a pointer, as SPIRV has restrictions on the indexing available otherwise.
  ; For example, only pointers-toArrays can be dynamically indexed, while direct array indices must be constants.
  ; Usually the default semantics will be the ones you want though, and indexing will preserve the outermost pointer.

  (local a0ptr (data.array 0)) ; Function* f32, using dynamic indexing (happens to be constant here).
  (local a0 (data.array.* 0)) ; f32, using constant indexing. Worse choice since it technically copies the array.

  ; Felvine always auto-dereferences when needed so usually you will not need to do this, but all these are valid and equivalent:
  (local b (+ a0ptr.* 10))
  (local b (+ a0ptr 10))
  (local b (+ a0 10))

  ; Because the leading pointer type is preserved, the SAME indexing syntax is used for storing to variables/buffers etc.
  (set* data.vector data.vector.zyx)
  (set* (data :array 5) v0)

  (set* data.pointer.* { :x px :y px }) ; This is where the trailing * also matters!
  (set* data.pointer otherPointerValue) ; Without it, we are setting the pointer itself, not its contents.
)


(fn* testTypes f32
  [ (num f32)
    (vec (vec3 f32))
    (mat (mat4 f32))
    (array [10 f32])
    (runtimeArray [f32])
    (ptr [*P f32] Restrict)
    (struct {
      x f32
      y f32
    })
  ]
  num)


(fn floatOps [x]
  (+ (round x)
     (roundEven x)
     (ceil x)
     (floor x)
     (trunc x)
     (fract x)
     (abs x)
     (sign x)
     (sin x)
     (cosh x)
     (exp x)
     (sqrt x)))

(fn vectorOps [v0 v1]
  (+ (distance v0 v1)
     (norm v0)
     (normalize v0)
     (faceForward v0 v0 v1)
     (reflect v0 v1)
     (refract v0 v1 0.8)))

(fn* testFloatingOperations f32
  [(v0 (vec3 f32)) (v1 (vec3 f32))]
  (local a
    (+ (floatOps v0.0)
       (floatOps v0)
       (vectorOps v0 v1)))
  (dot a a))


(fn* testPackUnpack f64 [(v (vec2 f32)) (w (vec4 f32)) (d f64)]
  (local u1
    (+ (packUnorm2x16 v)
       (packSnorm2x16 v)
       (packHalf2x16 v)))
  (local u2
    (+ (packUnorm4x8 w)
       (packSnorm4x8 w)))
  (local u (+ ((vec2 u32) u1 u2) (unpackDouble2x32 d)))
  (packDouble2x32 u))


(entrypoint main Fragment []
  (set* Color (+ Position
    (testNumberOperations 1 1 1 1 1 1 1 1 1 1)
    (testVectorProjections 1)
    (testConditionalOperations 1 1 1 1 1 1)
    (testLoopOperations 1 1)
    (testConstantPropagation 1)
    (testSubgroupOperations 1))))


(executionMode main OriginUpperLeft)
(executionMode "main" DepthLess)