
(local base (require :base))
(local spirv (require :spirv))
(local fennel (require :fennel))

(local ExecutionEnvironment { :mt {} })

(set ExecutionEnvironment.mt.__index
  { :vk-version { :major 1 :minor 0 }
    :vk-features {}  ; features, extensions, denorm properties, and subgroup feature bits
    :spv-features {} ; capabilities, extensions
  })

(fn ExecutionEnvironment.new [o]
  (setmetatable (or o {}) ExecutionEnvironment.mt))


(fn ExecutionEnvironment.permissive []
  (fn all-true-index [] true)
  (local true-map (setmetatable {} { :__index all-true-index }))
  (ExecutionEnvironment.new
    { :vk-version { :major 99 :minor 99 }
      :vk-features true-map
      :spv-features true-map
    }))



(local Requirement { :mt {} })

(set Requirement.mt.__index Requirement)

(fn Requirement.new [o]
  (setmetatable (or o {}) Requirement.mt))

(fn Requirement.mk [name {: ver : vk}]
  (Requirement.new { :spv-feature name :vk-version ver :vk-features vk }))

(fn Requirement.vk-version-lte [v0 v1]
  (or (< v0.major v1.major)
      (and (= v0.major v1.major)
           (<= v0.minor v1.minor))))


(fn Requirement.validate [self execution-env]
  (or
    ; valid if explicitly allowed
    (if self.spv-feature (. execution-env.spv-features self.spv-feature))

    ; valid if vulkan version supported
    (if self.vk-version
      (Requirement.vk-version-lte self.vk-version execution-env.vk-version))

    ; valid any vulkan enabling feature is supported
    (if self.vk-features
      (accumulate [satisfied false _ f (ipairs self.vk-features) &until satisfied]
        (or satisfied (. execution-env.vk-features f))))))


(fn Requirement.mt.__tostring [self]
  (local reqs [])
  (when self.vk-version
    (table.insert reqs (.. "\tVK_VERSION_" self.vk-version.major "_" self.vk-version.minor)))
  (when self.vk-features
    (icollect [_ f (ipairs self.vk-features) &into reqs]
      (.. "\t" f)))
  (..
    self.spv-feature " requires: \n"
    (table.concat reqs " or\n")))


(fn mk-requirements-index [t]
  (collect [name opts (pairs t)]
    name (Requirement.mk name
      (case (type opts)
        :string { :vk [ opts ] }
        :table (if opts.major { :ver opts }
                   opts.ver opts
                   { :vk opts })))))


(local pre-index
  { :Matrix
      { :major 1 :minor 0 }

    :Shader
      { :major 1 :minor 0 }

    :InputAttachment
      { :major 1 :minor 0 }

    :Sampled1D
       { :major 1 :minor 0 }

    :Image1D
       { :major 1 :minor 0 }

    :SampledBuffer
       { :major 1 :minor 0 }

    :ImageBuffer
       { :major 1 :minor 0 }

    :ImageQuery
       { :major 1 :minor 0 }

    :DerivativeControl
       { :major 1 :minor 0 }

    :Geometry
      :geometryShader

    :Tessellation
      :tessellationShader

    :Float64
      :shaderFloat64

    :Int64
      :shaderInt64

    :Int64Atomics
      [ :shaderBufferInt64Atomics
        :shaderSharedInt64Atomics
        :shaderImageInt64Atomics ]

    :AtomicFloat16AddEXT
      [ :shaderBufferFloat16AtomicAdd
        :shaderSharedFloat16AtomicAdd ]

    :AtomicFloat32AddEXT
      [ :shaderBufferFloat32AtomicAdd
        :shaderSharedFloat32AtomicAdd
        :shaderImageFloat32AtomicAdd ]

    :AtomicFloat64AddEXT
      [ :shaderBufferFloat64AtomicAdd
        :shaderSharedFloat64AtomicAdd ]

    :AtomicFloat16MinMaxEXT
      [ :shaderBufferFloat16AtomicMinMax
        :shaderSharedFloat16AtomicMinMax ]

    :AtomicFloat32MinMaxEXT
      [ :shaderBufferFloat32AtomicMinMax
        :shaderSharedFloat32AtomicMinMax
        :shaderImageFloat32AtomicMinMax ]

    :AtomicFloat64MinMaxEXT
      [ :shaderBufferFloat64AtomicMinMax
        :shaderSharedFloat64AtomicMinMax ]

    :AtomicFloat16VectorNV
      :shaderFloat16VectorAtomics

    :Int64ImageEXT
      :shaderImageInt64Atomics

    :Int16
      :shaderInt16

    :TessellationPointSize
      :shaderTessellationAndGeometryPointSize

    :GeometryPointSize
      :shaderTessellationAndGeometryPointSize

    :ImageGatherExtended
      :shaderImageGatherExtended

    :StorageImageMultisample
      :shaderStorageImageMultisample

    :UniformBufferArrayDynamicIndexing
      :shaderUniformBufferArrayDynamicIndexing

    :SampledImageArrayDynamicIndexing
      :shaderSampledImageArrayDynamicIndexing

    :StorageBufferArrayDynamicIndexing
      :shaderStorageBufferArrayDynamicIndexing

    :StorageImageArrayDynamicIndexing
      :shaderStorageImageArrayDynamicIndexing

    :ClipDistance
      :shaderClipDistance

    :CullDistance
      :shaderCullDistance

    :ImageCubeArray
      :imageCubeArray

    :SampleRateShading
      :sampleRateShading

    :SparseResidency
      :shaderResourceResidency

    :MinLod
      :shaderResourceMinLod

    :SampledCubeArray
      :imageCubeArray

    :ImageMSArray
      :shaderStorageImageMultisample

    :StorageImageExtendedFormats
      { :major 1 :minor 0 }

    :InterpolationFunction
      :sampleRateShading

    :StorageImageReadWithoutFormat
      { :ver { :major 1 :minor 3 }
        :vk [ :shaderStorageImageReadWithoutFormat
              :VK_KHR_format_feature_flags2 ] }

    :StorageImageWriteWithoutFormat
      { :ver { :major 1 :minor 3 }
        :vk [ :shaderStorageImageWriteWithoutFormat
              :VK_KHR_format_feature_flags2 ] }

    :MultiViewport
      :multiViewport

    :DrawParameters
      [ :shaderDrawParameters
        :shaderDrawParameters
        :VK_KHR_shader_draw_parameters ]

    :MultiView
      :multiview

    :DeviceGroup
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_device_group ] }

    :VariablePointersStorageBuffer
      :variablePointersStorageBuffer

    :VariablePointers
      :variablePointers

    :ShaderClockKHR
      :VK_KHR_shader_clock

    :StencilExportEXT
      :VK_EXT_shader_stencil_export

    :SubgroupBallotKHR
      :VK_EXT_shader_subgroup_ballot

    :SubgroupVoteKHR
      :VK_EXT_shader_subgroup_vote

    :ImageReadWriteLodAMD
      :VK_AMD_shader_image_load_store_lod

    :ImageGatherBiasLodAMD
      :VK_AMD_texture_gather_bias_lod

    :FragmentMaskAMD
      :VK_AMD_shader_fragment_mask

    :SampleMaskOverrideCoverageNV
      :VK_NV_sample_mask_override_coverage

    :GeometryShaderPassthroughNV
      :VK_NV_geometry_shader_passthrough

    :ShaderViewportIndex
      :shaderOutputViewportIndex

    :ShaderLayer
      :shaderOutputLayer

    :ShaderViewportIndexLayerEXT
      :VK_EXT_shader_viewport_index_layer

    :ShaderViewportIndexLayerNV
      :VK_NV_viewport_array2

    :ShaderViewportMaskNV
      :VK_NV_viewport_array2

    :PerViewAttributesNV
      :VK_NVX_multiview_per_view_attributes

    :StorageBuffer16BitAccess
      :storageBuffer16BitAccess

    :UniformAndStorageBuffer16BitAccess
      :uniformAndStorageBuffer16BitAccess

    :StoragePushConstant16
      :storagePushConstant16

    :StorageInputOutput16
      :storageInputOutput16

    :GroupNonUniform
      :VK_SUBGROUP_FEATURE_BASIC_BIT

    :GroupNonUniformVote
      :VK_SUBGROUP_FEATURE_VOTE_BIT

    :GroupNonUniformArithmetic
      :VK_SUBGROUP_FEATURE_ARITHMETIC_BIT

    :GroupNonUniformBallot
      :VK_SUBGROUP_FEATURE_BALLOT_BIT

    :GroupNonUniformShuffle
      :VK_SUBGROUP_FEATURE_SHUFFLE_BIT

    :GroupNonUniformShuffleRelative
      :VK_SUBGROUP_FEATURE_SHUFFLE_RELATIVE_BIT

    :GroupNonUniformClustered
      :VK_SUBGROUP_FEATURE_CLUSTERED_BIT

    :GroupNonUniformQuad
      :VK_SUBGROUP_FEATURE_QUAD_BIT

    :GroupNonUniformPartitionedNV
      :VK_SUBGROUP_FEATURE_PARTITIONED_BIT_NV

    :SampleMaskPostDepthCoverage
      :VK_EXT_post_depth_coverage

    :ShaderNonUniform
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_EXT_descriptor_indexing ] }

    :RuntimeDescriptorArray
      :runtimeDescriptorArray

    :InputAttachmentArrayDynamicIndexing
      :shaderInputAttachmentArrayDynamicIndexing

    :UniformTexelBufferArrayDynamicIndexing
      :shaderUniformTexelBufferArrayDynamicIndexing

    :StorageTexelBufferArrayDynamicIndexing
      :shaderStorageTexelBufferArrayDynamicIndexing

    :UniformBufferArrayNonUniformIndexing
      :shaderUniformBufferArrayNonUniformIndexing

    :SampledImageArrayNonUniformIndexing
      :shaderSampledImageArrayNonUniformIndexing

    :StorageBufferArrayNonUniformIndexing
      :shaderStorageBufferArrayNonUniformIndexing

    :StorageImageArrayNonUniformIndexing
      :shaderStorageImageArrayNonUniformIndexing

    :InputAttachmentArrayNonUniformIndexing
      :shaderInputAttachmentArrayNonUniformIndexing

    :UniformTexelBufferArrayNonUniformIndexing
      :shaderUniformTexelBufferArrayNonUniformIndexing

    :StorageTexelBufferArrayNonUniformIndexing
      :shaderStorageTexelBufferArrayNonUniformIndexing

    :FragmentFullyCoveredEXT
      :VK_EXT_conservative_rasterization

    :Float16
      [ :shaderFloat16
        :VK_AMD_gpu_shader_half_float ]

    :Int8
      :shaderInt8

    :StorageBuffer8BitAccess
      :storageBuffer8BitAccess

    :UniformAndStorageBuffer8BitAccess
      :uniformAndStorageBuffer8BitAccess

    :StoragePushConstant8
      :storagePushConstant8

    :VulkanMemoryModel
      :vulkanMemoryModel

    :VulkanMemoryModelDeviceScope
      :vulkanMemoryModelDeviceScope

    :DenormPreserve
      [ :shaderDenormPreserveFloat16
        :shaderDenormPreserveFloat32
        :shaderDenormPreserveFloat64 ]

    :DenormFlushToZero
      [ :shaderDenormFlushToZeroFloat16
        :shaderDenormFlushToZeroFloat32
        :shaderDenormFlushToZeroFloat64 ]

    :SignedZeroInfNanPreserve
      [ :shaderSignedZeroInfNanPreserveFloat16
        :shaderSignedZeroInfNanPreserveFloat32
        :shaderSignedZeroInfNanPreserveFloat64 ]

    :RoundingModeRTE
      [ :shaderRoundingModeRTEFloat16
        :shaderRoundingModeRTEFloat32
        :shaderRoundingModeRTEFloat64 ]

    :RoundingModeRTZ
      [ :shaderRoundingModeRTZFloat16
        :shaderRoundingModeRTZFloat32
        :shaderRoundingModeRTZFloat64 ]

    :ComputeDerivativeGroupQuadsNV
      :computeDerivativeGroupQuads

    :ComputeDerivativeGroupLinearNV
      :computeDerivativeGroupLinear

    :FragmentBarycentricNV
      :fragmentShaderBarycentric

    :ImageFootprintNV
      :imageFootprint

    :ShadingRateNV
      :shadingRateImage

    :MeshShadingNV
      :VK_NV_mesh_shader

    :RayTracingKHR
      :rayTracingPipeline

    :RayQueryKHR
      :rayQuery

    :RayTraversalPrimitiveCullingKHR
      [ :rayTraversalPrimitiveCulling
        :rayQuery ]

    :RayCullMaskKHR
      :rayTracingMaintenance1

    :RayTracingNV
      :VK_NV_ray_tracing

    :RayTracingMotionBlurNV
      :rayTracingMotionBlur

    :TransformFeedback
      :transformFeedback

    :GeometryStreams
      :geometryStreams

    :FragmentDensityEXT
      :fragmentDensityMap

    :PhysicalStorageBufferAddresses
      :bufferDeviceAddress

    :CooperativeMatrixNV
      :cooperativeMatrix

    :IntegerFunctions2INTEL
      :shaderIntegerFunctions2

    :ShaderSMBuiltinsNV
      :shaderSMBuiltins

    :FragmentShaderSampleInterlockEXT
      :fragmentShaderSampleInterlock

    :FragmentShaderPixelInterlockEXT
      :fragmentShaderPixelInterlock

    :FragmentShaderShadingRateInterlockEXT
      [ :fragmentShaderShadingRateInterlock
        :shadingRateImage ]

    :DemoteToHelperInvocationEXT
      :shaderDemoteToHelperInvocation

    :FragmentShadingRateKHR
      [ :pipelineFragmentShadingRate
        :primitiveFragmentShadingRate
        :attachmentFragmentShadingRate ]

    :WorkgroupMemoryExplicitLayoutKHR
      :workgroupMemoryExplicitLayout

    :WorkgroupMemoryExplicitLayout8BitAccessKHR
      :workgroupMemoryExplicitLayout8BitAccess

    :WorkgroupMemoryExplicitLayout16BitAccessKHR
      :workgroupMemoryExplicitLayout16BitAccess

    :DotProductInputAllKHR
      :shaderIntegerDotProduct

    :DotProductInput4x8BitKHR
      :shaderIntegerDotProduct

    :DotProductInput4x8BitPackedKHR
      :shaderIntegerDotProduct

    :DotProductKHR
      :shaderIntegerDotProduct

    :FragmentBarycentricKHR
      :fragmentShaderBarycentric

    :TextureSampleWeightedQCOM
      :textureSampleWeighted

    :TextureBoxFilterQCOM
      :textureBoxFilter

    :TextureBlockMatchQCOM
      :textureBlockMatch

    :TextureBlockMatch2QCOM
      :textureBlockMatch2

    :MeshShadingEXT
      :VK_EXT_mesh_shader

    :RayTracingOpacityMicromapEXT
      :VK_EXT_opacity_micromap

    :CoreBuiltinsARM
      :shaderCoreBuiltins

    :ShaderInvocationReorderNV
      :VK_NV_ray_tracing_invocation_reorder

    :ClusterCullingShadingHUAWEI
      :clustercullingShader

    :RayTracingPositionFetchKHR
      :rayTracingPositionFetch

    :RayQueryPositionFetchKHR
      :rayTracingPositionFetch

    :TileImageColorReadAccessEXT
      :shaderTileImageColorReadAccess

    :TileImageDepthReadAccessEXT
      :shaderTileImageDepthReadAccess

    :TileImageStencilReadAccessEXT
      :shaderTileImageStencilReadAccess

    :CooperativeMatrixKHR
      :cooperativeMatrix

    :ShaderEnqueueAMDX
      :shaderEnqueue

    :GroupNonUniformRotateKHR
      :shaderSubgroupRotate

    :ExpectAssumeKHR
      :shaderExpectAssume

    :FloatControls2
      :shaderFloatControls2

    :QuadControlKHR
      :shaderQuadControl

    :RawAccessChainsNV
      :shaderRawAccessChains

    :ReplicatedCompositesEXT
      :shaderReplicatedComposites

    :SPV_KHR_variable_pointers
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_variable_pointers ] }

    :SPV_AMD_shader_explicit_vertex_parameter
      :VK_AMD_shader_explicit_vertex_parameter

    :SPV_AMD_gcn_shader
      :VK_AMD_gcn_shader

    :SPV_AMD_gpu_shader_half_float
      :VK_AMD_gpu_shader_half_float

    :SPV_AMD_gpu_shader_int16
      :VK_AMD_gpu_shader_int16

    :SPV_AMD_shader_ballot
      :VK_AMD_shader_ballot

    :SPV_AMD_shader_fragment_mask
      :VK_AMD_shader_fragment_mask

    :SPV_AMD_shader_image_load_store_lod
      :VK_AMD_shader_image_load_store_lod

    :SPV_AMD_shader_trinary_minmax
      :VK_AMD_shader_trinary_minmax

    :SPV_AMD_texture_gather_bias_lod
      :VK_AMD_texture_gather_bias_lod

    :SPV_AMD_shader_early_and_late_fragment_tests
      :VK_AMD_shader_early_and_late_fragment_tests

    :SPV_KHR_shader_draw_parameters
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_shader_draw_parameters ] }

    :SPV_KHR_8bit_storage
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_KHR_8bit_storage ] }

    :SPV_KHR_16bit_storage
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_16bit_storage ] }

    :SPV_KHR_shader_clock
      :VK_KHR_shader_clock

    :SPV_KHR_float_controls
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_KHR_shader_float_controls ] }

    :SPV_KHR_storage_buffer_storage_class
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_storage_buffer_storage_class ] }

    :SPV_KHR_post_depth_coverage
      :VK_EXT_post_depth_coverage

    :SPV_EXT_shader_stencil_export
      :VK_EXT_shader_stencil_export

    :SPV_KHR_shader_ballot
      :VK_EXT_shader_subgroup_ballot

    :SPV_KHR_subgroup_vote
      :VK_EXT_shader_subgroup_vote

    :SPV_NV_sample_mask_override_coverage
      :VK_NV_sample_mask_override_coverage

    :SPV_NV_geometry_shader_passthrough
      :VK_NV_geometry_shader_passthrough

    :SPV_NV_mesh_shader
      :VK_NV_mesh_shader

    :SPV_NV_viewport_array2
      :VK_NV_viewport_array2

    :SPV_NV_shader_subgroup_partitioned
      :VK_NV_shader_subgroup_partitioned

    :SPV_NV_shader_invocation_reorder
      :VK_NV_ray_tracing_invocation_reorder

    :SPV_EXT_shader_viewport_index_layer
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_EXT_shader_viewport_index_layer ] }

    :SPV_NVX_multiview_per_view_attributes
      :VK_NVX_multiview_per_view_attributes

    :SPV_EXT_descriptor_indexing
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_EXT_descriptor_indexing ] }

    :SPV_KHR_vulkan_memory_model
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_KHR_vulkan_memory_model ] }

    :SPV_NV_compute_shader_derivatives
      :VK_NV_compute_shader_derivatives

    :SPV_NV_fragment_shader_barycentric
      :VK_NV_fragment_shader_barycentric

    :SPV_NV_shader_image_footprint
      :VK_NV_shader_image_footprint

    :SPV_NV_shading_rate
      :VK_NV_shading_rate_image

    :SPV_NV_ray_tracing
      :VK_NV_ray_tracing

    :SPV_KHR_ray_tracing
      :VK_KHR_ray_tracing_pipeline

    :SPV_KHR_ray_query
      :VK_KHR_ray_query

    :SPV_KHR_ray_cull_mask
      :VK_KHR_ray_tracing_maintenance1

    :SPV_GOOGLE_hlsl_functionality1
      :VK_GOOGLE_hlsl_functionality1

    :SPV_GOOGLE_user_type
      :VK_GOOGLE_user_type

    :SPV_GOOGLE_decorate_string
      :VK_GOOGLE_decorate_string

    :SPV_EXT_fragment_invocation_density
      :VK_EXT_fragment_density_map

    :SPV_KHR_physical_storage_buffer
      { :ver { :major 1 :minor 2 }
        :vk [ :VK_KHR_buffer_device_address ] }

    :SPV_EXT_physical_storage_buffer
      :VK_EXT_buffer_device_address

    :SPV_NV_cooperative_matrix
      :VK_NV_cooperative_matrix

    :SPV_NV_shader_sm_builtins
      :VK_NV_shader_sm_builtins

    :SPV_EXT_fragment_shader_interlock
      :VK_EXT_fragment_shader_interlock

    :SPV_EXT_demote_to_helper_invocation
      { :ver { :major 1 :minor 3 }
        :vk [ :VK_EXT_shader_demote_to_helper_invocation ] }

    :SPV_KHR_fragment_shading_rate
      :VK_KHR_fragment_shading_rate

    :SPV_KHR_non_semantic_info
      { :ver { :major 1 :minor 3 }
        :vk [ :VK_KHR_shader_non_semantic_info ] }

    :SPV_EXT_shader_image_int64
      :VK_EXT_shader_image_atomic_int64

    :SPV_KHR_terminate_invocation
      { :ver { :major 1 :minor 3 }
        :vk [ :VK_KHR_shader_terminate_invocation ] }

    :SPV_KHR_multiview
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_multiview ] }

    :SPV_KHR_workgroup_memory_explicit_layout
      :VK_KHR_workgroup_memory_explicit_layout

    :SPV_EXT_shader_atomic_float_add
      :VK_EXT_shader_atomic_float

    :SPV_KHR_fragment_shader_barycentric
      :VK_KHR_fragment_shader_barycentric

    :SPV_KHR_subgroup_uniform_control_flow
      { :ver { :major 1 :minor 3 }
        :vk [ :VK_KHR_shader_subgroup_uniform_control_flow ] }

    :SPV_EXT_shader_atomic_float_min_max
      :VK_EXT_shader_atomic_float2

    :SPV_EXT_shader_atomic_float16_add
      :VK_EXT_shader_atomic_float2

    :SPV_NV_shader_atomic_fp16_vector
      :VK_NV_shader_atomic_float16_vector

    :SPV_EXT_fragment_fully_covered
      :VK_EXT_conservative_rasterization

    :SPV_KHR_integer_dot_product
      { :ver { :major 1 :minor 3 }
        :vk [ :VK_KHR_shader_integer_dot_product ] }

    :SPV_INTEL_shader_integer_functions2
      :VK_INTEL_shader_integer_functions2

    :SPV_KHR_device_group
      { :ver { :major 1 :minor 1 }
        :vk [ :VK_KHR_device_group ] }

    :SPV_QCOM_image_processing
      :VK_QCOM_image_processing

    :SPV_QCOM_image_processing2
      :VK_QCOM_image_processing2

    :SPV_EXT_mesh_shader
      :VK_EXT_mesh_shader

    :SPV_KHR_ray_tracing_position_fetch
      :VK_KHR_ray_tracing_position_fetch

    :SPV_EXT_shader_tile_image
      :VK_EXT_shader_tile_image

    :SPV_EXT_opacity_micromap
      :VK_EXT_opacity_micromap

    :SPV_KHR_cooperative_matrix
      :VK_KHR_cooperative_matrix

    :SPV_ARM_core_builtins
      :VK_ARM_shader_core_builtins

    :SPV_AMDX_shader_enqueue
      :VK_AMDX_shader_enqueue

    :SPV_HUAWEI_cluster_culling_shader
      :VK_HUAWEI_cluster_culling_shader

    :SPV_HUAWEI_subpass_shading
      :VK_HUAWEI_subpass_shading

    :SPV_NV_ray_tracing_motion_blur
      :VK_NV_ray_tracing_motion_blur

    :SPV_KHR_maximal_reconvergence
      :VK_KHR_shader_maximal_reconvergence

    :SPV_KHR_subgroup_rotate
      :VK_KHR_shader_subgroup_rotate

    :SPV_KHR_expect_assume
      :VK_KHR_shader_expect_assume

    :SPV_KHR_float_controls2
      :VK_KHR_shader_float_controls2

    :SPV_KHR_quad_control
      :VK_KHR_shader_quad_control

    :SPV_NV_raw_access_chains
      :VK_NV_raw_access_chains

    :SPV_EXT_replicated_composites
      :VK_EXT_shader_replicated_composites })


{ : ExecutionEnvironment
  : Requirement
  :index (mk-requirements-index pre-index)
}