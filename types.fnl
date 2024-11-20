(local {: enum?} (require :base))
(local {: Dim : ImageFormat : AccessQualifier : StorageClass} (require :spirv))
(local {: Type : type?} (require :ast))

(local void (Type.void))
(local bool (Type.bool))
(local sampler (Type.sampler))
(local accelerationStructure (Type.accelerationStructure))
(local rayQuery (Type.rayQuery))

(local i8  (Type.int 8  true))
(local i16 (Type.int 16 true))
(local i32 (Type.int 32 true))
(local i64 (Type.int 64 true))

(local u8  (Type.int 8  false))
(local u16 (Type.int 16 false))
(local u32 (Type.int 32 false))
(local u64 (Type.int 64 false))

(local f16 (Type.float 16))
(local f32 (Type.float 32))
(local f64 (Type.float 64))

(fn vec2 [elem] (Type.vector elem 2))
(fn vec3 [elem] (Type.vector elem 3))
(fn vec4 [elem] (Type.vector elem 4))

(fn mat2x2 [elem] (Type.matrix elem 2 2))
(fn mat2x3 [elem] (Type.matrix elem 2 3))
(fn mat3x2 [elem] (Type.matrix elem 3 2))
(fn mat2x4 [elem] (Type.matrix elem 2 4))
(fn mat4x2 [elem] (Type.matrix elem 4 2))
(fn mat3x3 [elem] (Type.matrix elem 3 3))
(fn mat3x4 [elem] (Type.matrix elem 3 4))
(fn mat4x3 [elem] (Type.matrix elem 4 3))
(fn mat4x4 [elem] (Type.matrix elem 4 4))

(fn mat2 [elem] (Type.matrix elem 2 2))
(fn mat3 [elem] (Type.matrix elem 3 3))
(fn mat4 [elem] (Type.matrix elem 4 4))

(local vector Type.vector)
(local array Type.array)
(local pointer Type.pointer)
(local struct Type.struct)

(fn *P [elem] (Type.pointer elem StorageClass.PhysicalStorageBuffer))
(fn *W [elem] (Type.pointer elem StorageClass.Workgroup))
(fn *G [elem] (Type.pointer elem StorageClass.Generic))
(fn *I [elem] (Type.pointer elem StorageClass.Input))
(fn *O [elem] (Type.pointer elem StorageClass.Output))

; types for builtins which cannot vary in type,
; ignoring whether they may be in an array.
(local simpleBuiltinTypes
  (do 
    (local vec4f (vec4 f32))
    (local vec3f (vec3 f32))
    (local vec2f (vec2 f32))
    (local vec4u (vec4 u32))
    (local vec3u (vec3 u32))
    (local vec2u (vec2 u32))
    { :BaryCoordKHR vec3f
      :BaryCoordNoPerspAMD vec2f
      :BaryCoordNoPerspKHR vec3f
      :BaryCoordNoPerspCentroidAMD vec3f
      :BaryCoordNoPerspSampleAMD vec2f
      :BaryCoordPullModelAMD vec3f
      :BaryCoordSmoothAMD vec2f
      :BaryCoordSmoothCentroidAMD vec2f
      :BaryCoordSmoothSampleAMD vec2f
      :BaseInstance u32
      :BaseVertex u32
      :ClipDistance f32          ; NOTE: must be arrayed
      :ClipDistancePerViewNV f32 ; NOTE: must be doubly arrayed, PerViewNV
      :ClusterIDHUAWEI u32
      :ClusterShadingRateHUAWEI u32
      :CullDistance f32          ; NOTE: must be arrayed
      :CullDistancePerViewNV f32 ; NOTE: must be doubly arrayed, PerViewNV
      :CullPrimitiveEXT bool     ; NOTE: must be arrayed, PerPrimitiveEXT
      :CullMaskKHR u32
      :CurrentRayTimeNV f32
      :DeviceIndex u32
      :DrawIndex u32
      :FirstIndexHUAWEI u32
      :FragCoord vec4f
      :FragDepth f32
      :FirstInstanceHUAWEI u32
      :FirstVertexHUAWEI u32
      :FragInvocationCountEXT u32
      :FragSizeEXT vec2u
      :FragStencilRefEXT u32 ; NOTE: Could make this u64, but would require Int64 cap
      :FragmentSizeNV vec2u
      :FrontFacing bool
      :FullyCoveredEXT bool
      :GlobalInvocationId vec3u
      :HelperInvocation bool
      :HitKindKHR u32
      :HitTNV f32
      :HitTriangleVertexPositionsKHR (Type.array vec3f 3)
      :IncomingRayFlagsKHR u32
      :IndexCountHUAWEI u32
      :InstanceCountHUAWEI u32
      :InstanceCustomIndexKHR u32
      :InstanceId u32
      :InvocationId u32
      :InvocationsPerPixelNV u32
      :InstanceIndex u32
      :LaunchIdKHR vec3u
      :LaunchSizeKHR vec3u
      :Layer u32
      :LayerPerViewNV u32   ; NOTE: must be arrayed, PerViewNV
      :LocalInvocationId vec3u
      :LocalInvocationIndex u32
      :MeshViewCountNV u32
      :MeshViewIndicesNV u32 ; NOTE: must be arrayed
      :NumSubgroups u32
      :NumWorkgroups vec3u
      :ObjectRayDirectionKHR vec3f
      :ObjectRayOriginKHR vec3f
      :ObjectToWorldKHR (mat4x3 f32)
      :PatchVertices u32
      :PointCoord vec2f
      :PointSize f32
      :Position vec4f
      :PositionPerViewNV vec4f  ; NOTE: must be arrayed
      :PrimitiveCountNV u32
      :PrimitiveId u32
      :PrimitiveIndicesNV u32          ; NOTE: must be arrayed
      :PrimitivePointIndicesEXT u32    ; NOTE: must be arrayed
      :PrimitiveLineIndicesEXT u32     ; NOTE: must be arrayed
      :PrimitiveTriangleIndicesEXT u32 ; NOTE: must be arrayed
      :PrimitiveShadingRateKHR u32
      :RayGeometryIndexKHR u32
      :RayTmaxKHR f32
      :RayTminKHR f32
      :SampleId u32
      :SampleMask u32 ; NOTE: weird, and must be (runtime) arrayed
      :SamplePosition vec2f
      :ShadingRateKHR u32
      :SMCountNV u32
      :SMIDNV u32
      :SubgroupId u32
      :SubgroupEqMask vec4u
      :SubgroupGeMask vec4u
      :SubgroupGtMask vec4u
      :SubgroupLeMask vec4u
      :SubgroupLtMask vec4u
      :SubgroupLocalInvocationId u32
      :SubgroupSize u32
      :TaskCountNV u32
      :TessCoord vec3f
      :TessLevelOuter (Type.array f32 4)
      :TessLevelInner (Type.array f32 2)
      :VertexCountHUAWEI u32
      :VertexIndex u32
      :VertexOffsetHUAWUI u32
      :ViewIndex u32
      :ViewportIndex u32
      :ViewportMaskNV u32 ; NOTE: weird, and must be very specifically arrayed
      :ViewportMaskPerViewNV u32 ; NOTE: must be arrayed
      :WarpsPerSMNV u32
      :WarpIDNV vec3u
      :WorkgroupSize vec3u ; NOTE: deprecated for LocalSizeId execution mode
      :WorldRayDirectionKHR vec3f
      :WorldRayOriginKHR vec3f
      :WorldToObjectKHR (mat4x3 f32)
      :CoreCountARM u32
      :CoreMaxIDARM u32
      :CoreIDARM u32
      :WarpMaxIDARM u32
      :WarpIDARM u32
      :CoalescedInputCountAMDX u32
      :ShaderIndexAMDX u32
    }))

(local imageFormatElement
  {
    ; floating formats
    :Rgba32f f32
    :Rg32f f32
    :R32f f32
    :Rgba16f f32
    :Rg16f f32
    :R16f f32
    :Rgba16 f32
    :Rg16 f32
    :R16 f32
    :Rgba16Snorm f32
    :Rg16Snorm f32
    :R16Snorm f32
    :Rgb10A2 f32
    :R11fG11fB10f f32
    :Rgba8 f32
    :Rg8 f32
    :R8 f32
    :Rgba8Snorm f32
    :Rg8Snorm f32
    :R8Snorm f32

    ; integer formats
    :Rgba32i i32
    :Rg32i i32
    :R32i i32
    :Rgba16i i32
    :Rg16i i32
    :R16i i32
    :Rgba8i i32
    :Rg8i i32
    :R8i i32

    ; unsigned integer formats
    :Rgba32ui u32
    :Rg32ui u32
    :R32ui u32
    :Rgba16ui u32
    :Rg16ui u32
    :R16ui u32
    :Rgb10a2ui u32
    :Rgba8ui u32
    :Rg8ui u32
    :R8ui u32

    ; 64 bit formats
    :R64i i64
    :R64ui u64
  })


(fn imageOpts [o ...]
  (each [_ v (ipairs [...])]
    (case v
      :storage (set o.usage :storage)
      :depth (set o.depth true)
      :array (set o.array true)
      :ms (set o.ms true)
      (where (or :texture :sampled)) (set o.usage :texture)
      (where t (type? t)) (set o.elem t)
      (where v (?. ImageFormat.enumerants v))
        (do (local format (. ImageFormat v))
            (set o.format format)
            (set o.elem (. imageFormatElement format.tag)))
      (where v (?. Dim.enumerants v)) (set o.dim (. Dim v))
      (where v (enum? v))
        (case (enum? v)
          nil nil ; just ignore this. it's not useful for us
          :ImageFormat
            (do (set o.format v)
                (set o.elem (. imageFormatElement v.tag)))
          :Dim (set o.dim v))
      _ nil))
  o)

(fn image [...]
  (local spec (imageOpts
    { :kind :image
      :opaque true
      :depth false
      :array false
      :ms false
      :elem f32
    } ...))
  (assert spec.dim "Image dim among (:1D, :2D, :3D, :Cube, :Buffer, :SubpassData) must be specified")
  (assert spec.usage "Image usage among (:texture/:sampled, :storage) must be specified")
  (Type.new spec))

(fn sampledImage [...]
  (Type.sampled (image :texture ...)))


{ : void
  : bool
  : sampler
  : accelerationStructure
  : rayQuery
  : i8
  : i16
  : i32
  : i64
  : u8
  : u16
  : u32
  : u64
  : f16
  : f32
  : f64
  : vec2
  : vec3
  : vec4
  : mat2x2
  : mat2x3
  : mat3x2
  : mat2x4
  : mat4x2
  : mat3x3
  : mat3x4
  : mat4x3
  : mat4x4
  : mat2
  : mat3
  : mat4
  : vector
  : array
  : pointer
  : *P
  : *W
  : *G
  : *I
  : *O
  : struct
  : image
  : sampledImage
  : Type
  : type?
}

