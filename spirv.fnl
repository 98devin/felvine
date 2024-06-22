

(local {: mk-enum} (require :base))


(local magic-number 0x07230203)
(local major-version 1)
(local minor-version 6)
(local version { :major 1 :minor 6 })
(local revision 1)

(local ImageOperands (mk-enum :ImageOperands :bits {
    :Bias {
        :tag :Bias
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
    :Lod {
        :tag :Lod
        :value 2
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef}
        ]
    }
    :Grad {
        :tag :Grad
        :value 4
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef}
            {:kind :IdRef}
        ]
    }
    :ConstOffset {
        :tag :ConstOffset
        :value 8
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef}
        ]
    }
    :Offset {
        :tag :Offset
        :value 16
        :version { :major 1 :minor 0 }
        :capabilities [
            :ImageGatherExtended
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
    :ConstOffsets {
        :tag :ConstOffsets
        :value 32
        :version { :major 1 :minor 0 }
        :capabilities [
            :ImageGatherExtended
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
    :Sample {
        :tag :Sample
        :value 64
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef}
        ]
    }
    :MinLod {
        :tag :MinLod
        :value 128
        :version { :major 1 :minor 0 }
        :capabilities [
            :MinLod
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
    :MakeTexelAvailable {
        :tag :MakeTexelAvailable
        :value 256
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
        :operands [
            {:kind :IdScope}
        ]
    }
    :MakeTexelVisible {
        :tag :MakeTexelVisible
        :value 512
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
        :operands [
            {:kind :IdScope}
        ]
    }
    :NonPrivateTexel {
        :tag :NonPrivateTexel
        :value 1024
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :VolatileTexel {
        :tag :VolatileTexel
        :value 2048
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :SignExtend {
        :tag :SignExtend
        :value 4096
        :version { :major 1 :minor 4 }
    }
    :ZeroExtend {
        :tag :ZeroExtend
        :value 8192
        :version { :major 1 :minor 4 }
    }
    :Nontemporal {
        :tag :Nontemporal
        :value 16384
        :version { :major 1 :minor 6 }
    }
    :Offsets {
        :tag :Offsets
        :value 65536
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef}
        ]
    }
}))

(set ImageOperands.enumerants.MakeTexelAvailableKHR ImageOperands.enumerants.MakeTexelAvailable)
(set ImageOperands.enumerants.MakeTexelVisibleKHR ImageOperands.enumerants.MakeTexelVisible)
(set ImageOperands.enumerants.NonPrivateTexelKHR ImageOperands.enumerants.NonPrivateTexel)
(set ImageOperands.enumerants.VolatileTexelKHR ImageOperands.enumerants.VolatileTexel)


(local FPFastMathMode (mk-enum :FPFastMathMode :bits {
    :NotNaN {
        :tag :NotNaN
        :value 1
        :version { :major 1 :minor 0 }
    }
    :NotInf {
        :tag :NotInf
        :value 2
        :version { :major 1 :minor 0 }
    }
    :NSZ {
        :tag :NSZ
        :value 4
        :version { :major 1 :minor 0 }
    }
    :AllowRecip {
        :tag :AllowRecip
        :value 8
        :version { :major 1 :minor 0 }
    }
    :Fast {
        :tag :Fast
        :value 16
        :version { :major 1 :minor 0 }
    }
    :AllowContract {
        :tag :AllowContract
        :value 65536
        :capabilities [
            :FloatControls2
            :FPFastMathModeINTEL
        ]
    }
    :AllowReassoc {
        :tag :AllowReassoc
        :value 131072
        :capabilities [
            :FloatControls2
            :FPFastMathModeINTEL
        ]
    }
    :AllowTransform {
        :tag :AllowTransform
        :value 262144
        :capabilities [
            :FloatControls2
        ]
    }
}))

(set FPFastMathMode.enumerants.AllowContractFastINTEL FPFastMathMode.enumerants.AllowContract)
(set FPFastMathMode.enumerants.AllowReassocINTEL FPFastMathMode.enumerants.AllowReassoc)


(local SelectionControl (mk-enum :SelectionControl :bits {
    :Flatten {
        :tag :Flatten
        :value 1
        :version { :major 1 :minor 0 }
    }
    :DontFlatten {
        :tag :DontFlatten
        :value 2
        :version { :major 1 :minor 0 }
    }
}))


(local LoopControl (mk-enum :LoopControl :bits {
    :Unroll {
        :tag :Unroll
        :value 1
        :version { :major 1 :minor 0 }
    }
    :DontUnroll {
        :tag :DontUnroll
        :value 2
        :version { :major 1 :minor 0 }
    }
    :DependencyInfinite {
        :tag :DependencyInfinite
        :value 4
        :version { :major 1 :minor 1 }
    }
    :DependencyLength {
        :tag :DependencyLength
        :value 8
        :version { :major 1 :minor 1 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :MinIterations {
        :tag :MinIterations
        :value 16
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :MaxIterations {
        :tag :MaxIterations
        :value 32
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :IterationMultiple {
        :tag :IterationMultiple
        :value 64
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :PeelCount {
        :tag :PeelCount
        :value 128
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :PartialCount {
        :tag :PartialCount
        :value 256
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :InitiationIntervalINTEL {
        :tag :InitiationIntervalINTEL
        :value 65536
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :MaxConcurrencyINTEL {
        :tag :MaxConcurrencyINTEL
        :value 131072
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :DependencyArrayINTEL {
        :tag :DependencyArrayINTEL
        :value 262144
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :PipelineEnableINTEL {
        :tag :PipelineEnableINTEL
        :value 524288
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :LoopCoalesceINTEL {
        :tag :LoopCoalesceINTEL
        :value 1048576
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :MaxInterleavingINTEL {
        :tag :MaxInterleavingINTEL
        :value 2097152
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :SpeculatedIterationsINTEL {
        :tag :SpeculatedIterationsINTEL
        :value 4194304
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :NoFusionINTEL {
        :tag :NoFusionINTEL
        :value 8388608
        :capabilities [
            :FPGALoopControlsINTEL
        ]
    }
    :LoopCountINTEL {
        :tag :LoopCountINTEL
        :value 16777216
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :MaxReinvocationDelayINTEL {
        :tag :MaxReinvocationDelayINTEL
        :value 33554432
        :capabilities [
            :FPGALoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger}
        ]
    }
}))


(local FunctionControl (mk-enum :FunctionControl :bits {
    :Inline {
        :tag :Inline
        :value 1
        :version { :major 1 :minor 0 }
    }
    :DontInline {
        :tag :DontInline
        :value 2
        :version { :major 1 :minor 0 }
    }
    :Pure {
        :tag :Pure
        :value 4
        :version { :major 1 :minor 0 }
    }
    :Const {
        :tag :Const
        :value 8
        :version { :major 1 :minor 0 }
    }
    :OptNoneINTEL {
        :tag :OptNoneINTEL
        :value 65536
        :capabilities [
            :OptNoneINTEL
        ]
    }
}))


(local MemorySemantics (mk-enum :MemorySemantics :bits {
    :Acquire {
        :tag :Acquire
        :value 2
        :version { :major 1 :minor 0 }
    }
    :Release {
        :tag :Release
        :value 4
        :version { :major 1 :minor 0 }
    }
    :AcquireRelease {
        :tag :AcquireRelease
        :value 8
        :version { :major 1 :minor 0 }
    }
    :SequentiallyConsistent {
        :tag :SequentiallyConsistent
        :value 16
        :version { :major 1 :minor 0 }
    }
    :UniformMemory {
        :tag :UniformMemory
        :value 64
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SubgroupMemory {
        :tag :SubgroupMemory
        :value 128
        :version { :major 1 :minor 0 }
    }
    :WorkgroupMemory {
        :tag :WorkgroupMemory
        :value 256
        :version { :major 1 :minor 0 }
    }
    :CrossWorkgroupMemory {
        :tag :CrossWorkgroupMemory
        :value 512
        :version { :major 1 :minor 0 }
    }
    :AtomicCounterMemory {
        :tag :AtomicCounterMemory
        :value 1024
        :version { :major 1 :minor 0 }
        :capabilities [
            :AtomicStorage
        ]
    }
    :ImageMemory {
        :tag :ImageMemory
        :value 2048
        :version { :major 1 :minor 0 }
    }
    :OutputMemory {
        :tag :OutputMemory
        :value 4096
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :MakeAvailable {
        :tag :MakeAvailable
        :value 8192
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :MakeVisible {
        :tag :MakeVisible
        :value 16384
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :Volatile {
        :tag :Volatile
        :value 32768
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_KHR_vulkan_memory_model
        ]
        :capabilities [
            :VulkanMemoryModel
        ]
    }
}))

(set MemorySemantics.enumerants.OutputMemoryKHR MemorySemantics.enumerants.OutputMemory)
(set MemorySemantics.enumerants.MakeAvailableKHR MemorySemantics.enumerants.MakeAvailable)
(set MemorySemantics.enumerants.MakeVisibleKHR MemorySemantics.enumerants.MakeVisible)


(local MemoryAccess (mk-enum :MemoryAccess :bits {
    :Volatile {
        :tag :Volatile
        :value 1
        :version { :major 1 :minor 0 }
    }
    :Aligned {
        :tag :Aligned
        :value 2
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :LiteralInteger}
        ]
    }
    :Nontemporal {
        :tag :Nontemporal
        :value 4
        :version { :major 1 :minor 0 }
    }
    :MakePointerAvailable {
        :tag :MakePointerAvailable
        :value 8
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
        :operands [
            {:kind :IdScope}
        ]
    }
    :MakePointerVisible {
        :tag :MakePointerVisible
        :value 16
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
        :operands [
            {:kind :IdScope}
        ]
    }
    :NonPrivatePointer {
        :tag :NonPrivatePointer
        :value 32
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :AliasScopeINTELMask {
        :tag :AliasScopeINTELMask
        :value 65536
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
    :NoAliasINTELMask {
        :tag :NoAliasINTELMask
        :value 131072
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdRef}
        ]
    }
}))

(set MemoryAccess.enumerants.MakePointerAvailableKHR MemoryAccess.enumerants.MakePointerAvailable)
(set MemoryAccess.enumerants.MakePointerVisibleKHR MemoryAccess.enumerants.MakePointerVisible)
(set MemoryAccess.enumerants.NonPrivatePointerKHR MemoryAccess.enumerants.NonPrivatePointer)


(local KernelProfilingInfo (mk-enum :KernelProfilingInfo :bits {
    :CmdExecTime {
        :tag :CmdExecTime
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
}))


(local RayFlags (mk-enum :RayFlags :bits {
    :OpaqueKHR {
        :tag :OpaqueKHR
        :value 1
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :NoOpaqueKHR {
        :tag :NoOpaqueKHR
        :value 2
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :TerminateOnFirstHitKHR {
        :tag :TerminateOnFirstHitKHR
        :value 4
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :SkipClosestHitShaderKHR {
        :tag :SkipClosestHitShaderKHR
        :value 8
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :CullBackFacingTrianglesKHR {
        :tag :CullBackFacingTrianglesKHR
        :value 16
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :CullFrontFacingTrianglesKHR {
        :tag :CullFrontFacingTrianglesKHR
        :value 32
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :CullOpaqueKHR {
        :tag :CullOpaqueKHR
        :value 64
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :CullNoOpaqueKHR {
        :tag :CullNoOpaqueKHR
        :value 128
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :SkipTrianglesKHR {
        :tag :SkipTrianglesKHR
        :value 256
        :capabilities [
            :RayTraversalPrimitiveCullingKHR
        ]
    }
    :SkipAABBsKHR {
        :tag :SkipAABBsKHR
        :value 512
        :capabilities [
            :RayTraversalPrimitiveCullingKHR
        ]
    }
    :ForceOpacityMicromap2StateEXT {
        :tag :ForceOpacityMicromap2StateEXT
        :value 1024
        :capabilities [
            :RayTracingOpacityMicromapEXT
        ]
    }
}))


(local FragmentShadingRate (mk-enum :FragmentShadingRate :bits {
    :Vertical2Pixels {
        :tag :Vertical2Pixels
        :value 1
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
    :Vertical4Pixels {
        :tag :Vertical4Pixels
        :value 2
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
    :Horizontal2Pixels {
        :tag :Horizontal2Pixels
        :value 4
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
    :Horizontal4Pixels {
        :tag :Horizontal4Pixels
        :value 8
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
}))


(local RawAccessChainOperands (mk-enum :RawAccessChainOperands :bits {
    :RobustnessPerComponentNV {
        :tag :RobustnessPerComponentNV
        :value 1
        :capabilities [
            :RawAccessChainsNV
        ]
    }
    :RobustnessPerElementNV {
        :tag :RobustnessPerElementNV
        :value 2
        :capabilities [
            :RawAccessChainsNV
        ]
    }
}))


(local SourceLanguage (mk-enum :SourceLanguage :value {
    :Unknown {
        :tag :Unknown
        :value 0
        :version { :major 1 :minor 0 }
    }
    :ESSL {
        :tag :ESSL
        :value 1
        :version { :major 1 :minor 0 }
    }
    :GLSL {
        :tag :GLSL
        :value 2
        :version { :major 1 :minor 0 }
    }
    :OpenCL_C {
        :tag :OpenCL_C
        :value 3
        :version { :major 1 :minor 0 }
    }
    :OpenCL_CPP {
        :tag :OpenCL_CPP
        :value 4
        :version { :major 1 :minor 0 }
    }
    :HLSL {
        :tag :HLSL
        :value 5
        :version { :major 1 :minor 0 }
    }
    :CPP_for_OpenCL {
        :tag :CPP_for_OpenCL
        :value 6
        :version { :major 1 :minor 0 }
    }
    :SYCL {
        :tag :SYCL
        :value 7
        :version { :major 1 :minor 0 }
    }
    :HERO_C {
        :tag :HERO_C
        :value 8
        :version { :major 1 :minor 0 }
    }
    :NZSL {
        :tag :NZSL
        :value 9
        :version { :major 1 :minor 0 }
    }
    :WGSL {
        :tag :WGSL
        :value 10
        :version { :major 1 :minor 0 }
    }
    :Slang {
        :tag :Slang
        :value 11
        :version { :major 1 :minor 0 }
    }
    :Zig {
        :tag :Zig
        :value 12
        :version { :major 1 :minor 0 }
    }
}))


(local ExecutionModel (mk-enum :ExecutionModel :value {
    :Vertex {
        :tag :Vertex
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :TessellationControl {
        :tag :TessellationControl
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :TessellationEvaluation {
        :tag :TessellationEvaluation
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :Geometry {
        :tag :Geometry
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :Fragment {
        :tag :Fragment
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :GLCompute {
        :tag :GLCompute
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Kernel {
        :tag :Kernel
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :TaskNV {
        :tag :TaskNV
        :value 5267
        :capabilities [
            :MeshShadingNV
        ]
    }
    :MeshNV {
        :tag :MeshNV
        :value 5268
        :capabilities [
            :MeshShadingNV
        ]
    }
    :RayGenerationKHR {
        :tag :RayGenerationKHR
        :value 5313
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :IntersectionKHR {
        :tag :IntersectionKHR
        :value 5314
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :AnyHitKHR {
        :tag :AnyHitKHR
        :value 5315
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :ClosestHitKHR {
        :tag :ClosestHitKHR
        :value 5316
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :MissKHR {
        :tag :MissKHR
        :value 5317
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :CallableKHR {
        :tag :CallableKHR
        :value 5318
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :TaskEXT {
        :tag :TaskEXT
        :value 5364
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :MeshEXT {
        :tag :MeshEXT
        :value 5365
        :capabilities [
            :MeshShadingEXT
        ]
    }
}))

(set ExecutionModel.enumerants.RayGenerationNV ExecutionModel.enumerants.RayGenerationKHR)
(set ExecutionModel.enumerants.IntersectionNV ExecutionModel.enumerants.IntersectionKHR)
(set ExecutionModel.enumerants.AnyHitNV ExecutionModel.enumerants.AnyHitKHR)
(set ExecutionModel.enumerants.ClosestHitNV ExecutionModel.enumerants.ClosestHitKHR)
(set ExecutionModel.enumerants.MissNV ExecutionModel.enumerants.MissKHR)
(set ExecutionModel.enumerants.CallableNV ExecutionModel.enumerants.CallableKHR)


(local AddressingModel (mk-enum :AddressingModel :value {
    :Logical {
        :tag :Logical
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Physical32 {
        :tag :Physical32
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
        ]
    }
    :Physical64 {
        :tag :Physical64
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
        ]
    }
    :PhysicalStorageBuffer64 {
        :tag :PhysicalStorageBuffer64
        :value 5348
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_EXT_physical_storage_buffer
            :SPV_KHR_physical_storage_buffer
        ]
        :capabilities [
            :PhysicalStorageBufferAddresses
        ]
    }
}))

(set AddressingModel.enumerants.PhysicalStorageBuffer64EXT AddressingModel.enumerants.PhysicalStorageBuffer64)


(local MemoryModel (mk-enum :MemoryModel :value {
    :Simple {
        :tag :Simple
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :GLSL450 {
        :tag :GLSL450
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :OpenCL {
        :tag :OpenCL
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Vulkan {
        :tag :Vulkan
        :value 3
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
}))

(set MemoryModel.enumerants.VulkanKHR MemoryModel.enumerants.Vulkan)


(local ExecutionMode (mk-enum :ExecutionMode :value {
    :Invocations {
        :tag :Invocations
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
        :operands [
            {:kind :LiteralInteger :name "Number of <<Invocation, invocations>>"}
        ]
    }
    :SpacingEqual {
        :tag :SpacingEqual
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :SpacingFractionalEven {
        :tag :SpacingFractionalEven
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :SpacingFractionalOdd {
        :tag :SpacingFractionalOdd
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :VertexOrderCw {
        :tag :VertexOrderCw
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :VertexOrderCcw {
        :tag :VertexOrderCcw
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :PixelCenterInteger {
        :tag :PixelCenterInteger
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :OriginUpperLeft {
        :tag :OriginUpperLeft
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :OriginLowerLeft {
        :tag :OriginLowerLeft
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :EarlyFragmentTests {
        :tag :EarlyFragmentTests
        :value 9
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :PointMode {
        :tag :PointMode
        :value 10
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :Xfb {
        :tag :Xfb
        :value 11
        :version { :major 1 :minor 0 }
        :capabilities [
            :TransformFeedback
        ]
    }
    :DepthReplacing {
        :tag :DepthReplacing
        :value 12
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :DepthGreater {
        :tag :DepthGreater
        :value 14
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :DepthLess {
        :tag :DepthLess
        :value 15
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :DepthUnchanged {
        :tag :DepthUnchanged
        :value 16
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :LocalSize {
        :tag :LocalSize
        :value 17
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :LiteralInteger :name "x size"}
            {:kind :LiteralInteger :name "y size"}
            {:kind :LiteralInteger :name "z size"}
        ]
    }
    :LocalSizeHint {
        :tag :LocalSizeHint
        :value 18
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :LiteralInteger :name "x size"}
            {:kind :LiteralInteger :name "y size"}
            {:kind :LiteralInteger :name "z size"}
        ]
    }
    :InputPoints {
        :tag :InputPoints
        :value 19
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :InputLines {
        :tag :InputLines
        :value 20
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :InputLinesAdjacency {
        :tag :InputLinesAdjacency
        :value 21
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :Triangles {
        :tag :Triangles
        :value 22
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :Tessellation
        ]
    }
    :InputTrianglesAdjacency {
        :tag :InputTrianglesAdjacency
        :value 23
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :Quads {
        :tag :Quads
        :value 24
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :Isolines {
        :tag :Isolines
        :value 25
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :OutputVertices {
        :tag :OutputVertices
        :value 26
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :Tessellation
            :MeshShadingNV
            :MeshShadingEXT
        ]
        :operands [
            {:kind :LiteralInteger :name "Vertex count"}
        ]
    }
    :OutputPoints {
        :tag :OutputPoints
        :value 27
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :OutputLineStrip {
        :tag :OutputLineStrip
        :value 28
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :OutputTriangleStrip {
        :tag :OutputTriangleStrip
        :value 29
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :VecTypeHint {
        :tag :VecTypeHint
        :value 30
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :LiteralInteger :name "Vector type"}
        ]
    }
    :ContractionOff {
        :tag :ContractionOff
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Initializer {
        :tag :Initializer
        :value 33
        :version { :major 1 :minor 1 }
        :capabilities [
            :Kernel
        ]
    }
    :Finalizer {
        :tag :Finalizer
        :value 34
        :version { :major 1 :minor 1 }
        :capabilities [
            :Kernel
        ]
    }
    :SubgroupSize {
        :tag :SubgroupSize
        :value 35
        :version { :major 1 :minor 1 }
        :capabilities [
            :SubgroupDispatch
        ]
        :operands [
            {:kind :LiteralInteger :name "Subgroup Size"}
        ]
    }
    :SubgroupsPerWorkgroup {
        :tag :SubgroupsPerWorkgroup
        :value 36
        :version { :major 1 :minor 1 }
        :capabilities [
            :SubgroupDispatch
        ]
        :operands [
            {:kind :LiteralInteger :name "Subgroups Per Workgroup"}
        ]
    }
    :SubgroupsPerWorkgroupId {
        :tag :SubgroupsPerWorkgroupId
        :value 37
        :version { :major 1 :minor 2 }
        :capabilities [
            :SubgroupDispatch
        ]
        :operands [
            {:kind :IdRef :name "Subgroups Per Workgroup"}
        ]
    }
    :LocalSizeId {
        :tag :LocalSizeId
        :value 38
        :version { :major 1 :minor 2 }
        :operands [
            {:kind :IdRef :name "x size"}
            {:kind :IdRef :name "y size"}
            {:kind :IdRef :name "z size"}
        ]
    }
    :LocalSizeHintId {
        :tag :LocalSizeHintId
        :value 39
        :version { :major 1 :minor 2 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "x size hint"}
            {:kind :IdRef :name "y size hint"}
            {:kind :IdRef :name "z size hint"}
        ]
    }
    :NonCoherentColorAttachmentReadEXT {
        :tag :NonCoherentColorAttachmentReadEXT
        :value 4169
        :capabilities [
            :TileImageColorReadAccessEXT
        ]
    }
    :NonCoherentDepthAttachmentReadEXT {
        :tag :NonCoherentDepthAttachmentReadEXT
        :value 4170
        :capabilities [
            :TileImageDepthReadAccessEXT
        ]
    }
    :NonCoherentStencilAttachmentReadEXT {
        :tag :NonCoherentStencilAttachmentReadEXT
        :value 4171
        :capabilities [
            :TileImageStencilReadAccessEXT
        ]
    }
    :SubgroupUniformControlFlowKHR {
        :tag :SubgroupUniformControlFlowKHR
        :value 4421
        :extensions [
            :SPV_KHR_subgroup_uniform_control_flow
        ]
        :capabilities [
            :Shader
        ]
    }
    :PostDepthCoverage {
        :tag :PostDepthCoverage
        :value 4446
        :extensions [
            :SPV_KHR_post_depth_coverage
        ]
        :capabilities [
            :SampleMaskPostDepthCoverage
        ]
    }
    :DenormPreserve {
        :tag :DenormPreserve
        :value 4459
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
        :capabilities [
            :DenormPreserve
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :DenormFlushToZero {
        :tag :DenormFlushToZero
        :value 4460
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
        :capabilities [
            :DenormFlushToZero
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :SignedZeroInfNanPreserve {
        :tag :SignedZeroInfNanPreserve
        :value 4461
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
        :capabilities [
            :SignedZeroInfNanPreserve
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :RoundingModeRTE {
        :tag :RoundingModeRTE
        :value 4462
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
        :capabilities [
            :RoundingModeRTE
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :RoundingModeRTZ {
        :tag :RoundingModeRTZ
        :value 4463
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
        :capabilities [
            :RoundingModeRTZ
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :EarlyAndLateFragmentTestsAMD {
        :tag :EarlyAndLateFragmentTestsAMD
        :value 5017
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
        ]
        :capabilities [
            :Shader
        ]
    }
    :StencilRefReplacingEXT {
        :tag :StencilRefReplacingEXT
        :value 5027
        :extensions [
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :CoalescingAMDX {
        :tag :CoalescingAMDX
        :value 5069
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :MaxNodeRecursionAMDX {
        :tag :MaxNodeRecursionAMDX
        :value 5071
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Number of recursions"}
        ]
    }
    :StaticNumWorkgroupsAMDX {
        :tag :StaticNumWorkgroupsAMDX
        :value 5072
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "x size"}
            {:kind :IdRef :name "y size"}
            {:kind :IdRef :name "z size"}
        ]
    }
    :ShaderIndexAMDX {
        :tag :ShaderIndexAMDX
        :value 5073
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Shader Index"}
        ]
    }
    :MaxNumWorkgroupsAMDX {
        :tag :MaxNumWorkgroupsAMDX
        :value 5077
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "x size"}
            {:kind :IdRef :name "y size"}
            {:kind :IdRef :name "z size"}
        ]
    }
    :StencilRefUnchangedFrontAMD {
        :tag :StencilRefUnchangedFrontAMD
        :value 5079
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :StencilRefGreaterFrontAMD {
        :tag :StencilRefGreaterFrontAMD
        :value 5080
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :StencilRefLessFrontAMD {
        :tag :StencilRefLessFrontAMD
        :value 5081
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :StencilRefUnchangedBackAMD {
        :tag :StencilRefUnchangedBackAMD
        :value 5082
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :StencilRefGreaterBackAMD {
        :tag :StencilRefGreaterBackAMD
        :value 5083
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :StencilRefLessBackAMD {
        :tag :StencilRefLessBackAMD
        :value 5084
        :extensions [
            :SPV_AMD_shader_early_and_late_fragment_tests
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :QuadDerivativesKHR {
        :tag :QuadDerivativesKHR
        :value 5088
        :capabilities [
            :QuadControlKHR
        ]
    }
    :RequireFullQuadsKHR {
        :tag :RequireFullQuadsKHR
        :value 5089
        :capabilities [
            :QuadControlKHR
        ]
    }
    :OutputLinesEXT {
        :tag :OutputLinesEXT
        :value 5269
        :extensions [
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :OutputPrimitivesEXT {
        :tag :OutputPrimitivesEXT
        :value 5270
        :extensions [
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
            :MeshShadingEXT
        ]
        :operands [
            {:kind :LiteralInteger :name "Primitive count"}
        ]
    }
    :DerivativeGroupQuadsNV {
        :tag :DerivativeGroupQuadsNV
        :value 5289
        :extensions [
            :SPV_NV_compute_shader_derivatives
        ]
        :capabilities [
            :ComputeDerivativeGroupQuadsNV
        ]
    }
    :DerivativeGroupLinearNV {
        :tag :DerivativeGroupLinearNV
        :value 5290
        :extensions [
            :SPV_NV_compute_shader_derivatives
        ]
        :capabilities [
            :ComputeDerivativeGroupLinearNV
        ]
    }
    :OutputTrianglesEXT {
        :tag :OutputTrianglesEXT
        :value 5298
        :extensions [
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :PixelInterlockOrderedEXT {
        :tag :PixelInterlockOrderedEXT
        :value 5366
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderPixelInterlockEXT
        ]
    }
    :PixelInterlockUnorderedEXT {
        :tag :PixelInterlockUnorderedEXT
        :value 5367
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderPixelInterlockEXT
        ]
    }
    :SampleInterlockOrderedEXT {
        :tag :SampleInterlockOrderedEXT
        :value 5368
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderSampleInterlockEXT
        ]
    }
    :SampleInterlockUnorderedEXT {
        :tag :SampleInterlockUnorderedEXT
        :value 5369
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderSampleInterlockEXT
        ]
    }
    :ShadingRateInterlockOrderedEXT {
        :tag :ShadingRateInterlockOrderedEXT
        :value 5370
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderShadingRateInterlockEXT
        ]
    }
    :ShadingRateInterlockUnorderedEXT {
        :tag :ShadingRateInterlockUnorderedEXT
        :value 5371
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderShadingRateInterlockEXT
        ]
    }
    :SharedLocalMemorySizeINTEL {
        :tag :SharedLocalMemorySizeINTEL
        :value 5618
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Size"}
        ]
    }
    :RoundingModeRTPINTEL {
        :tag :RoundingModeRTPINTEL
        :value 5620
        :capabilities [
            :RoundToInfinityINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :RoundingModeRTNINTEL {
        :tag :RoundingModeRTNINTEL
        :value 5621
        :capabilities [
            :RoundToInfinityINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :FloatingPointModeALTINTEL {
        :tag :FloatingPointModeALTINTEL
        :value 5622
        :capabilities [
            :RoundToInfinityINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :FloatingPointModeIEEEINTEL {
        :tag :FloatingPointModeIEEEINTEL
        :value 5623
        :capabilities [
            :RoundToInfinityINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
        ]
    }
    :MaxWorkgroupSizeINTEL {
        :tag :MaxWorkgroupSizeINTEL
        :value 5893
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
        :capabilities [
            :KernelAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "max_x_size"}
            {:kind :LiteralInteger :name "max_y_size"}
            {:kind :LiteralInteger :name "max_z_size"}
        ]
    }
    :MaxWorkDimINTEL {
        :tag :MaxWorkDimINTEL
        :value 5894
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
        :capabilities [
            :KernelAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "max_dimensions"}
        ]
    }
    :NoGlobalOffsetINTEL {
        :tag :NoGlobalOffsetINTEL
        :value 5895
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
        :capabilities [
            :KernelAttributesINTEL
        ]
    }
    :NumSIMDWorkitemsINTEL {
        :tag :NumSIMDWorkitemsINTEL
        :value 5896
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
        :capabilities [
            :FPGAKernelAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "vector_width"}
        ]
    }
    :SchedulerTargetFmaxMhzINTEL {
        :tag :SchedulerTargetFmaxMhzINTEL
        :value 5903
        :capabilities [
            :FPGAKernelAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "target_fmax"}
        ]
    }
    :MaximallyReconvergesKHR {
        :tag :MaximallyReconvergesKHR
        :value 6023
        :extensions [
            :SPV_KHR_maximal_reconvergence
        ]
        :capabilities [
            :Shader
        ]
    }
    :FPFastMathDefault {
        :tag :FPFastMathDefault
        :value 6028
        :capabilities [
            :FloatControls2
        ]
        :operands [
            {:kind :IdRef :name "Target Type"}
            {:kind :IdRef :name "Fast-Math Mode"}
        ]
    }
    :StreamingInterfaceINTEL {
        :tag :StreamingInterfaceINTEL
        :value 6154
        :capabilities [
            :FPGAKernelAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "StallFreeReturn"}
        ]
    }
    :RegisterMapInterfaceINTEL {
        :tag :RegisterMapInterfaceINTEL
        :value 6160
        :capabilities [
            :FPGAKernelAttributesv2INTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "WaitForDoneWrite"}
        ]
    }
    :NamedBarrierCountINTEL {
        :tag :NamedBarrierCountINTEL
        :value 6417
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Barrier Count"}
        ]
    }
    :MaximumRegistersINTEL {
        :tag :MaximumRegistersINTEL
        :value 6461
        :capabilities [
            :RegisterLimitsINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Number of Registers"}
        ]
    }
    :MaximumRegistersIdINTEL {
        :tag :MaximumRegistersIdINTEL
        :value 6462
        :capabilities [
            :RegisterLimitsINTEL
        ]
        :operands [
            {:kind :IdRef :name "Number of Registers"}
        ]
    }
    :NamedMaximumRegistersINTEL {
        :tag :NamedMaximumRegistersINTEL
        :value 6463
        :capabilities [
            :RegisterLimitsINTEL
        ]
        :operands [
            {:kind :NamedMaximumNumberOfRegisters :name "Named Maximum Number of Registers"}
        ]
    }
}))

(set ExecutionMode.enumerants.OutputLinesNV ExecutionMode.enumerants.OutputLinesEXT)
(set ExecutionMode.enumerants.OutputPrimitivesNV ExecutionMode.enumerants.OutputPrimitivesEXT)
(set ExecutionMode.enumerants.OutputTrianglesNV ExecutionMode.enumerants.OutputTrianglesEXT)


(local StorageClass (mk-enum :StorageClass :value {
    :UniformConstant {
        :tag :UniformConstant
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Input {
        :tag :Input
        :value 1
        :version { :major 1 :minor 0 }
    }
    :Uniform {
        :tag :Uniform
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Output {
        :tag :Output
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Workgroup {
        :tag :Workgroup
        :value 4
        :version { :major 1 :minor 0 }
    }
    :CrossWorkgroup {
        :tag :CrossWorkgroup
        :value 5
        :version { :major 1 :minor 0 }
    }
    :Private {
        :tag :Private
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :VectorComputeINTEL
        ]
    }
    :Function {
        :tag :Function
        :value 7
        :version { :major 1 :minor 0 }
    }
    :Generic {
        :tag :Generic
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :GenericPointer
        ]
    }
    :PushConstant {
        :tag :PushConstant
        :value 9
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :AtomicCounter {
        :tag :AtomicCounter
        :value 10
        :version { :major 1 :minor 0 }
        :capabilities [
            :AtomicStorage
        ]
    }
    :Image {
        :tag :Image
        :value 11
        :version { :major 1 :minor 0 }
    }
    :StorageBuffer {
        :tag :StorageBuffer
        :value 12
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_storage_buffer_storage_class
            :SPV_KHR_variable_pointers
        ]
        :capabilities [
            :Shader
        ]
    }
    :TileImageEXT {
        :tag :TileImageEXT
        :value 4172
        :capabilities [
            :TileImageColorReadAccessEXT
        ]
    }
    :NodePayloadAMDX {
        :tag :NodePayloadAMDX
        :value 5068
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :NodeOutputPayloadAMDX {
        :tag :NodeOutputPayloadAMDX
        :value 5076
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :CallableDataKHR {
        :tag :CallableDataKHR
        :value 5328
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :IncomingCallableDataKHR {
        :tag :IncomingCallableDataKHR
        :value 5329
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :RayPayloadKHR {
        :tag :RayPayloadKHR
        :value 5338
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :HitAttributeKHR {
        :tag :HitAttributeKHR
        :value 5339
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :IncomingRayPayloadKHR {
        :tag :IncomingRayPayloadKHR
        :value 5342
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :ShaderRecordBufferKHR {
        :tag :ShaderRecordBufferKHR
        :value 5343
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :PhysicalStorageBuffer {
        :tag :PhysicalStorageBuffer
        :value 5349
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_EXT_physical_storage_buffer
            :SPV_KHR_physical_storage_buffer
        ]
        :capabilities [
            :PhysicalStorageBufferAddresses
        ]
    }
    :HitObjectAttributeNV {
        :tag :HitObjectAttributeNV
        :value 5385
        :capabilities [
            :ShaderInvocationReorderNV
        ]
    }
    :TaskPayloadWorkgroupEXT {
        :tag :TaskPayloadWorkgroupEXT
        :value 5402
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :CodeSectionINTEL {
        :tag :CodeSectionINTEL
        :value 5605
        :extensions [
            :SPV_INTEL_function_pointers
        ]
        :capabilities [
            :FunctionPointersINTEL
        ]
    }
    :DeviceOnlyINTEL {
        :tag :DeviceOnlyINTEL
        :value 5936
        :extensions [
            :SPV_INTEL_usm_storage_classes
        ]
        :capabilities [
            :USMStorageClassesINTEL
        ]
    }
    :HostOnlyINTEL {
        :tag :HostOnlyINTEL
        :value 5937
        :extensions [
            :SPV_INTEL_usm_storage_classes
        ]
        :capabilities [
            :USMStorageClassesINTEL
        ]
    }
}))

(set StorageClass.enumerants.CallableDataNV StorageClass.enumerants.CallableDataKHR)
(set StorageClass.enumerants.IncomingCallableDataNV StorageClass.enumerants.IncomingCallableDataKHR)
(set StorageClass.enumerants.RayPayloadNV StorageClass.enumerants.RayPayloadKHR)
(set StorageClass.enumerants.HitAttributeNV StorageClass.enumerants.HitAttributeKHR)
(set StorageClass.enumerants.IncomingRayPayloadNV StorageClass.enumerants.IncomingRayPayloadKHR)
(set StorageClass.enumerants.ShaderRecordBufferNV StorageClass.enumerants.ShaderRecordBufferKHR)
(set StorageClass.enumerants.PhysicalStorageBufferEXT StorageClass.enumerants.PhysicalStorageBuffer)


(local Dim (mk-enum :Dim :value {
    :1D {
        :tag :1D
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Sampled1D
        ]
    }
    :2D {
        :tag :2D
        :value 1
        :version { :major 1 :minor 0 }
    }
    :3D {
        :tag :3D
        :value 2
        :version { :major 1 :minor 0 }
    }
    :Cube {
        :tag :Cube
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rect {
        :tag :Rect
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampledRect
        ]
    }
    :Buffer {
        :tag :Buffer
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampledBuffer
        ]
    }
    :SubpassData {
        :tag :SubpassData
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :InputAttachment
        ]
    }
    :TileImageDataEXT {
        :tag :TileImageDataEXT
        :value 4173
        :capabilities [
            :TileImageColorReadAccessEXT
        ]
    }
}))


(local SamplerAddressingMode (mk-enum :SamplerAddressingMode :value {
    :None {
        :tag :None
        :value 0
        :version { :major 1 :minor 0 }
    }
    :ClampToEdge {
        :tag :ClampToEdge
        :value 1
        :version { :major 1 :minor 0 }
    }
    :Clamp {
        :tag :Clamp
        :value 2
        :version { :major 1 :minor 0 }
    }
    :Repeat {
        :tag :Repeat
        :value 3
        :version { :major 1 :minor 0 }
    }
    :RepeatMirrored {
        :tag :RepeatMirrored
        :value 4
        :version { :major 1 :minor 0 }
    }
}))


(local SamplerFilterMode (mk-enum :SamplerFilterMode :value {
    :Nearest {
        :tag :Nearest
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Linear {
        :tag :Linear
        :value 1
        :version { :major 1 :minor 0 }
    }
}))


(local ImageFormat (mk-enum :ImageFormat :value {
    :Unknown {
        :tag :Unknown
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Rgba32f {
        :tag :Rgba32f
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba16f {
        :tag :Rgba16f
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :R32f {
        :tag :R32f
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba8 {
        :tag :Rgba8
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba8Snorm {
        :tag :Rgba8Snorm
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rg32f {
        :tag :Rg32f
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg16f {
        :tag :Rg16f
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R11fG11fB10f {
        :tag :R11fG11fB10f
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R16f {
        :tag :R16f
        :value 9
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rgba16 {
        :tag :Rgba16
        :value 10
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rgb10A2 {
        :tag :Rgb10A2
        :value 11
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg16 {
        :tag :Rg16
        :value 12
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg8 {
        :tag :Rg8
        :value 13
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R16 {
        :tag :R16
        :value 14
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R8 {
        :tag :R8
        :value 15
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rgba16Snorm {
        :tag :Rgba16Snorm
        :value 16
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg16Snorm {
        :tag :Rg16Snorm
        :value 17
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg8Snorm {
        :tag :Rg8Snorm
        :value 18
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R16Snorm {
        :tag :R16Snorm
        :value 19
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R8Snorm {
        :tag :R8Snorm
        :value 20
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rgba32i {
        :tag :Rgba32i
        :value 21
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba16i {
        :tag :Rgba16i
        :value 22
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba8i {
        :tag :Rgba8i
        :value 23
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :R32i {
        :tag :R32i
        :value 24
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rg32i {
        :tag :Rg32i
        :value 25
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg16i {
        :tag :Rg16i
        :value 26
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg8i {
        :tag :Rg8i
        :value 27
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R16i {
        :tag :R16i
        :value 28
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R8i {
        :tag :R8i
        :value 29
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rgba32ui {
        :tag :Rgba32ui
        :value 30
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba16ui {
        :tag :Rgba16ui
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgba8ui {
        :tag :Rgba8ui
        :value 32
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :R32ui {
        :tag :R32ui
        :value 33
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Rgb10a2ui {
        :tag :Rgb10a2ui
        :value 34
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg32ui {
        :tag :Rg32ui
        :value 35
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg16ui {
        :tag :Rg16ui
        :value 36
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :Rg8ui {
        :tag :Rg8ui
        :value 37
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R16ui {
        :tag :R16ui
        :value 38
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R8ui {
        :tag :R8ui
        :value 39
        :version { :major 1 :minor 0 }
        :capabilities [
            :StorageImageExtendedFormats
        ]
    }
    :R64ui {
        :tag :R64ui
        :value 40
        :version { :major 1 :minor 0 }
        :capabilities [
            :Int64ImageEXT
        ]
    }
    :R64i {
        :tag :R64i
        :value 41
        :version { :major 1 :minor 0 }
        :capabilities [
            :Int64ImageEXT
        ]
    }
}))


(local ImageChannelOrder (mk-enum :ImageChannelOrder :value {
    :R {
        :tag :R
        :value 0
        :version { :major 1 :minor 0 }
    }
    :A {
        :tag :A
        :value 1
        :version { :major 1 :minor 0 }
    }
    :RG {
        :tag :RG
        :value 2
        :version { :major 1 :minor 0 }
    }
    :RA {
        :tag :RA
        :value 3
        :version { :major 1 :minor 0 }
    }
    :RGB {
        :tag :RGB
        :value 4
        :version { :major 1 :minor 0 }
    }
    :RGBA {
        :tag :RGBA
        :value 5
        :version { :major 1 :minor 0 }
    }
    :BGRA {
        :tag :BGRA
        :value 6
        :version { :major 1 :minor 0 }
    }
    :ARGB {
        :tag :ARGB
        :value 7
        :version { :major 1 :minor 0 }
    }
    :Intensity {
        :tag :Intensity
        :value 8
        :version { :major 1 :minor 0 }
    }
    :Luminance {
        :tag :Luminance
        :value 9
        :version { :major 1 :minor 0 }
    }
    :Rx {
        :tag :Rx
        :value 10
        :version { :major 1 :minor 0 }
    }
    :RGx {
        :tag :RGx
        :value 11
        :version { :major 1 :minor 0 }
    }
    :RGBx {
        :tag :RGBx
        :value 12
        :version { :major 1 :minor 0 }
    }
    :Depth {
        :tag :Depth
        :value 13
        :version { :major 1 :minor 0 }
    }
    :DepthStencil {
        :tag :DepthStencil
        :value 14
        :version { :major 1 :minor 0 }
    }
    :sRGB {
        :tag :sRGB
        :value 15
        :version { :major 1 :minor 0 }
    }
    :sRGBx {
        :tag :sRGBx
        :value 16
        :version { :major 1 :minor 0 }
    }
    :sRGBA {
        :tag :sRGBA
        :value 17
        :version { :major 1 :minor 0 }
    }
    :sBGRA {
        :tag :sBGRA
        :value 18
        :version { :major 1 :minor 0 }
    }
    :ABGR {
        :tag :ABGR
        :value 19
        :version { :major 1 :minor 0 }
    }
}))


(local ImageChannelDataType (mk-enum :ImageChannelDataType :value {
    :SnormInt8 {
        :tag :SnormInt8
        :value 0
        :version { :major 1 :minor 0 }
    }
    :SnormInt16 {
        :tag :SnormInt16
        :value 1
        :version { :major 1 :minor 0 }
    }
    :UnormInt8 {
        :tag :UnormInt8
        :value 2
        :version { :major 1 :minor 0 }
    }
    :UnormInt16 {
        :tag :UnormInt16
        :value 3
        :version { :major 1 :minor 0 }
    }
    :UnormShort565 {
        :tag :UnormShort565
        :value 4
        :version { :major 1 :minor 0 }
    }
    :UnormShort555 {
        :tag :UnormShort555
        :value 5
        :version { :major 1 :minor 0 }
    }
    :UnormInt101010 {
        :tag :UnormInt101010
        :value 6
        :version { :major 1 :minor 0 }
    }
    :SignedInt8 {
        :tag :SignedInt8
        :value 7
        :version { :major 1 :minor 0 }
    }
    :SignedInt16 {
        :tag :SignedInt16
        :value 8
        :version { :major 1 :minor 0 }
    }
    :SignedInt32 {
        :tag :SignedInt32
        :value 9
        :version { :major 1 :minor 0 }
    }
    :UnsignedInt8 {
        :tag :UnsignedInt8
        :value 10
        :version { :major 1 :minor 0 }
    }
    :UnsignedInt16 {
        :tag :UnsignedInt16
        :value 11
        :version { :major 1 :minor 0 }
    }
    :UnsignedInt32 {
        :tag :UnsignedInt32
        :value 12
        :version { :major 1 :minor 0 }
    }
    :HalfFloat {
        :tag :HalfFloat
        :value 13
        :version { :major 1 :minor 0 }
    }
    :Float {
        :tag :Float
        :value 14
        :version { :major 1 :minor 0 }
    }
    :UnormInt24 {
        :tag :UnormInt24
        :value 15
        :version { :major 1 :minor 0 }
    }
    :UnormInt101010_2 {
        :tag :UnormInt101010_2
        :value 16
        :version { :major 1 :minor 0 }
    }
    :UnsignedIntRaw10EXT {
        :tag :UnsignedIntRaw10EXT
        :value 19
        :version { :major 1 :minor 0 }
    }
    :UnsignedIntRaw12EXT {
        :tag :UnsignedIntRaw12EXT
        :value 20
        :version { :major 1 :minor 0 }
    }
}))


(local FPRoundingMode (mk-enum :FPRoundingMode :value {
    :RTE {
        :tag :RTE
        :value 0
        :version { :major 1 :minor 0 }
    }
    :RTZ {
        :tag :RTZ
        :value 1
        :version { :major 1 :minor 0 }
    }
    :RTP {
        :tag :RTP
        :value 2
        :version { :major 1 :minor 0 }
    }
    :RTN {
        :tag :RTN
        :value 3
        :version { :major 1 :minor 0 }
    }
}))


(local FPDenormMode (mk-enum :FPDenormMode :value {
    :Preserve {
        :tag :Preserve
        :value 0
        :capabilities [
            :FunctionFloatControlINTEL
        ]
    }
    :FlushToZero {
        :tag :FlushToZero
        :value 1
        :capabilities [
            :FunctionFloatControlINTEL
        ]
    }
}))


(local QuantizationModes (mk-enum :QuantizationModes :value {
    :TRN {
        :tag :TRN
        :value 0
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :TRN_ZERO {
        :tag :TRN_ZERO
        :value 1
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND {
        :tag :RND
        :value 2
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND_ZERO {
        :tag :RND_ZERO
        :value 3
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND_INF {
        :tag :RND_INF
        :value 4
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND_MIN_INF {
        :tag :RND_MIN_INF
        :value 5
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND_CONV {
        :tag :RND_CONV
        :value 6
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :RND_CONV_ODD {
        :tag :RND_CONV_ODD
        :value 7
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
}))


(local FPOperationMode (mk-enum :FPOperationMode :value {
    :IEEE {
        :tag :IEEE
        :value 0
        :capabilities [
            :FunctionFloatControlINTEL
        ]
    }
    :ALT {
        :tag :ALT
        :value 1
        :capabilities [
            :FunctionFloatControlINTEL
        ]
    }
}))


(local OverflowModes (mk-enum :OverflowModes :value {
    :WRAP {
        :tag :WRAP
        :value 0
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :SAT {
        :tag :SAT
        :value 1
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :SAT_ZERO {
        :tag :SAT_ZERO
        :value 2
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
    :SAT_SYM {
        :tag :SAT_SYM
        :value 3
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
    }
}))


(local LinkageType (mk-enum :LinkageType :value {
    :Export {
        :tag :Export
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Linkage
        ]
    }
    :Import {
        :tag :Import
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Linkage
        ]
    }
    :LinkOnceODR {
        :tag :LinkOnceODR
        :value 2
        :extensions [
            :SPV_KHR_linkonce_odr
        ]
        :capabilities [
            :Linkage
        ]
    }
}))


(local AccessQualifier (mk-enum :AccessQualifier :value {
    :ReadOnly {
        :tag :ReadOnly
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :WriteOnly {
        :tag :WriteOnly
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :ReadWrite {
        :tag :ReadWrite
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
}))


(local HostAccessQualifier (mk-enum :HostAccessQualifier :value {
    :NoneINTEL {
        :tag :NoneINTEL
        :value 0
        :capabilities [
            :GlobalVariableHostAccessINTEL
        ]
    }
    :ReadINTEL {
        :tag :ReadINTEL
        :value 1
        :capabilities [
            :GlobalVariableHostAccessINTEL
        ]
    }
    :WriteINTEL {
        :tag :WriteINTEL
        :value 2
        :capabilities [
            :GlobalVariableHostAccessINTEL
        ]
    }
    :ReadWriteINTEL {
        :tag :ReadWriteINTEL
        :value 3
        :capabilities [
            :GlobalVariableHostAccessINTEL
        ]
    }
}))


(local FunctionParameterAttribute (mk-enum :FunctionParameterAttribute :value {
    :Zext {
        :tag :Zext
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Sext {
        :tag :Sext
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :ByVal {
        :tag :ByVal
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Sret {
        :tag :Sret
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :NoAlias {
        :tag :NoAlias
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :NoCapture {
        :tag :NoCapture
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :NoWrite {
        :tag :NoWrite
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :NoReadWrite {
        :tag :NoReadWrite
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :RuntimeAlignedINTEL {
        :tag :RuntimeAlignedINTEL
        :value 5940
        :version { :major 1 :minor 0 }
        :capabilities [
            :RuntimeAlignedAttributeINTEL
        ]
    }
}))


(local Decoration (mk-enum :Decoration :value {
    :RelaxedPrecision {
        :tag :RelaxedPrecision
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SpecId {
        :tag :SpecId
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :Kernel
        ]
        :operands [
            {:kind :LiteralInteger :name "Specialization Constant ID"}
        ]
    }
    :Block {
        :tag :Block
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :BufferBlock {
        :tag :BufferBlock
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :RowMajor {
        :tag :RowMajor
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
    }
    :ColMajor {
        :tag :ColMajor
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
    }
    :ArrayStride {
        :tag :ArrayStride
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Array Stride"}
        ]
    }
    :MatrixStride {
        :tag :MatrixStride
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :LiteralInteger :name "Matrix Stride"}
        ]
    }
    :GLSLShared {
        :tag :GLSLShared
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :GLSLPacked {
        :tag :GLSLPacked
        :value 9
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :CPacked {
        :tag :CPacked
        :value 10
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :BuiltIn {
        :tag :BuiltIn
        :value 11
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :BuiltIn}
        ]
    }
    :NoPerspective {
        :tag :NoPerspective
        :value 13
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Flat {
        :tag :Flat
        :value 14
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Patch {
        :tag :Patch
        :value 15
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :Centroid {
        :tag :Centroid
        :value 16
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Sample {
        :tag :Sample
        :value 17
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampleRateShading
        ]
    }
    :Invariant {
        :tag :Invariant
        :value 18
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Restrict {
        :tag :Restrict
        :value 19
        :version { :major 1 :minor 0 }
    }
    :Aliased {
        :tag :Aliased
        :value 20
        :version { :major 1 :minor 0 }
    }
    :Volatile {
        :tag :Volatile
        :value 21
        :version { :major 1 :minor 0 }
    }
    :Constant {
        :tag :Constant
        :value 22
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Coherent {
        :tag :Coherent
        :value 23
        :version { :major 1 :minor 0 }
    }
    :NonWritable {
        :tag :NonWritable
        :value 24
        :version { :major 1 :minor 0 }
    }
    :NonReadable {
        :tag :NonReadable
        :value 25
        :version { :major 1 :minor 0 }
    }
    :Uniform {
        :tag :Uniform
        :value 26
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :UniformDecoration
        ]
    }
    :UniformId {
        :tag :UniformId
        :value 27
        :version { :major 1 :minor 4 }
        :capabilities [
            :Shader
            :UniformDecoration
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
        ]
    }
    :SaturatedConversion {
        :tag :SaturatedConversion
        :value 28
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Stream {
        :tag :Stream
        :value 29
        :version { :major 1 :minor 0 }
        :capabilities [
            :GeometryStreams
        ]
        :operands [
            {:kind :LiteralInteger :name "Stream Number"}
        ]
    }
    :Location {
        :tag :Location
        :value 30
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Location"}
        ]
    }
    :Component {
        :tag :Component
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Component"}
        ]
    }
    :Index {
        :tag :Index
        :value 32
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Index"}
        ]
    }
    :Binding {
        :tag :Binding
        :value 33
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Binding Point"}
        ]
    }
    :DescriptorSet {
        :tag :DescriptorSet
        :value 34
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Descriptor Set"}
        ]
    }
    :Offset {
        :tag :Offset
        :value 35
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :LiteralInteger :name "Byte Offset"}
        ]
    }
    :XfbBuffer {
        :tag :XfbBuffer
        :value 36
        :version { :major 1 :minor 0 }
        :capabilities [
            :TransformFeedback
        ]
        :operands [
            {:kind :LiteralInteger :name "XFB Buffer Number"}
        ]
    }
    :XfbStride {
        :tag :XfbStride
        :value 37
        :version { :major 1 :minor 0 }
        :capabilities [
            :TransformFeedback
        ]
        :operands [
            {:kind :LiteralInteger :name "XFB Stride"}
        ]
    }
    :FuncParamAttr {
        :tag :FuncParamAttr
        :value 38
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :FunctionParameterAttribute :name "Function Parameter Attribute"}
        ]
    }
    :FPRoundingMode {
        :tag :FPRoundingMode
        :value 39
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :FPRoundingMode :name "Floating-Point Rounding Mode"}
        ]
    }
    :FPFastMathMode {
        :tag :FPFastMathMode
        :value 40
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :FloatControls2
        ]
        :operands [
            {:kind :FPFastMathMode :name "Fast-Math Mode"}
        ]
    }
    :LinkageAttributes {
        :tag :LinkageAttributes
        :value 41
        :version { :major 1 :minor 0 }
        :capabilities [
            :Linkage
        ]
        :operands [
            {:kind :LiteralString :name "Name"}
            {:kind :LinkageType :name "Linkage Type"}
        ]
    }
    :NoContraction {
        :tag :NoContraction
        :value 42
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :InputAttachmentIndex {
        :tag :InputAttachmentIndex
        :value 43
        :version { :major 1 :minor 0 }
        :capabilities [
            :InputAttachment
        ]
        :operands [
            {:kind :LiteralInteger :name "Attachment Index"}
        ]
    }
    :Alignment {
        :tag :Alignment
        :value 44
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :LiteralInteger :name "Alignment"}
        ]
    }
    :MaxByteOffset {
        :tag :MaxByteOffset
        :value 45
        :version { :major 1 :minor 1 }
        :capabilities [
            :Addresses
        ]
        :operands [
            {:kind :LiteralInteger :name "Max Byte Offset"}
        ]
    }
    :AlignmentId {
        :tag :AlignmentId
        :value 46
        :version { :major 1 :minor 2 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Alignment"}
        ]
    }
    :MaxByteOffsetId {
        :tag :MaxByteOffsetId
        :value 47
        :version { :major 1 :minor 2 }
        :capabilities [
            :Addresses
        ]
        :operands [
            {:kind :IdRef :name "Max Byte Offset"}
        ]
    }
    :NoSignedWrap {
        :tag :NoSignedWrap
        :value 4469
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_no_integer_wrap_decoration
        ]
    }
    :NoUnsignedWrap {
        :tag :NoUnsignedWrap
        :value 4470
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_no_integer_wrap_decoration
        ]
    }
    :WeightTextureQCOM {
        :tag :WeightTextureQCOM
        :value 4487
        :extensions [
            :SPV_QCOM_image_processing
        ]
    }
    :BlockMatchTextureQCOM {
        :tag :BlockMatchTextureQCOM
        :value 4488
        :extensions [
            :SPV_QCOM_image_processing
        ]
    }
    :BlockMatchSamplerQCOM {
        :tag :BlockMatchSamplerQCOM
        :value 4499
        :extensions [
            :SPV_QCOM_image_processing2
        ]
    }
    :ExplicitInterpAMD {
        :tag :ExplicitInterpAMD
        :value 4999
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :NodeSharesPayloadLimitsWithAMDX {
        :tag :NodeSharesPayloadLimitsWithAMDX
        :value 5019
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Payload Array"}
        ]
    }
    :NodeMaxPayloadsAMDX {
        :tag :NodeMaxPayloadsAMDX
        :value 5020
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Max number of payloads"}
        ]
    }
    :TrackFinishWritingAMDX {
        :tag :TrackFinishWritingAMDX
        :value 5078
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :PayloadNodeNameAMDX {
        :tag :PayloadNodeNameAMDX
        :value 5091
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :LiteralString :name "Node Name"}
        ]
    }
    :OverrideCoverageNV {
        :tag :OverrideCoverageNV
        :value 5248
        :extensions [
            :SPV_NV_sample_mask_override_coverage
        ]
        :capabilities [
            :SampleMaskOverrideCoverageNV
        ]
    }
    :PassthroughNV {
        :tag :PassthroughNV
        :value 5250
        :extensions [
            :SPV_NV_geometry_shader_passthrough
        ]
        :capabilities [
            :GeometryShaderPassthroughNV
        ]
    }
    :ViewportRelativeNV {
        :tag :ViewportRelativeNV
        :value 5252
        :capabilities [
            :ShaderViewportMaskNV
        ]
    }
    :SecondaryViewportRelativeNV {
        :tag :SecondaryViewportRelativeNV
        :value 5256
        :extensions [
            :SPV_NV_stereo_view_rendering
        ]
        :capabilities [
            :ShaderStereoViewNV
        ]
        :operands [
            {:kind :LiteralInteger :name "Offset"}
        ]
    }
    :PerPrimitiveEXT {
        :tag :PerPrimitiveEXT
        :value 5271
        :extensions [
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :PerViewNV {
        :tag :PerViewNV
        :value 5272
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :PerTaskNV {
        :tag :PerTaskNV
        :value 5273
        :extensions [
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :PerVertexKHR {
        :tag :PerVertexKHR
        :value 5285
        :extensions [
            :SPV_NV_fragment_shader_barycentric
            :SPV_KHR_fragment_shader_barycentric
        ]
        :capabilities [
            :FragmentBarycentricNV
            :FragmentBarycentricKHR
        ]
    }
    :NonUniform {
        :tag :NonUniform
        :value 5300
        :version { :major 1 :minor 5 }
        :capabilities [
            :ShaderNonUniform
        ]
    }
    :RestrictPointer {
        :tag :RestrictPointer
        :value 5355
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_EXT_physical_storage_buffer
            :SPV_KHR_physical_storage_buffer
        ]
        :capabilities [
            :PhysicalStorageBufferAddresses
        ]
    }
    :AliasedPointer {
        :tag :AliasedPointer
        :value 5356
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_EXT_physical_storage_buffer
            :SPV_KHR_physical_storage_buffer
        ]
        :capabilities [
            :PhysicalStorageBufferAddresses
        ]
    }
    :HitObjectShaderRecordBufferNV {
        :tag :HitObjectShaderRecordBufferNV
        :value 5386
        :capabilities [
            :ShaderInvocationReorderNV
        ]
    }
    :BindlessSamplerNV {
        :tag :BindlessSamplerNV
        :value 5398
        :capabilities [
            :BindlessTextureNV
        ]
    }
    :BindlessImageNV {
        :tag :BindlessImageNV
        :value 5399
        :capabilities [
            :BindlessTextureNV
        ]
    }
    :BoundSamplerNV {
        :tag :BoundSamplerNV
        :value 5400
        :capabilities [
            :BindlessTextureNV
        ]
    }
    :BoundImageNV {
        :tag :BoundImageNV
        :value 5401
        :capabilities [
            :BindlessTextureNV
        ]
    }
    :SIMTCallINTEL {
        :tag :SIMTCallINTEL
        :value 5599
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "N"}
        ]
    }
    :ReferencedIndirectlyINTEL {
        :tag :ReferencedIndirectlyINTEL
        :value 5602
        :extensions [
            :SPV_INTEL_function_pointers
        ]
        :capabilities [
            :IndirectReferencesINTEL
        ]
    }
    :ClobberINTEL {
        :tag :ClobberINTEL
        :value 5607
        :capabilities [
            :AsmINTEL
        ]
        :operands [
            {:kind :LiteralString :name "Register"}
        ]
    }
    :SideEffectsINTEL {
        :tag :SideEffectsINTEL
        :value 5608
        :capabilities [
            :AsmINTEL
        ]
    }
    :VectorComputeVariableINTEL {
        :tag :VectorComputeVariableINTEL
        :value 5624
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :FuncParamIOKindINTEL {
        :tag :FuncParamIOKindINTEL
        :value 5625
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Kind"}
        ]
    }
    :VectorComputeFunctionINTEL {
        :tag :VectorComputeFunctionINTEL
        :value 5626
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :StackCallINTEL {
        :tag :StackCallINTEL
        :value 5627
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :GlobalVariableOffsetINTEL {
        :tag :GlobalVariableOffsetINTEL
        :value 5628
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Offset"}
        ]
    }
    :CounterBuffer {
        :tag :CounterBuffer
        :value 5634
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :IdRef :name "Counter Buffer"}
        ]
    }
    :UserSemantic {
        :tag :UserSemantic
        :value 5635
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :LiteralString :name "Semantic"}
        ]
    }
    :UserTypeGOOGLE {
        :tag :UserTypeGOOGLE
        :value 5636
        :extensions [
            :SPV_GOOGLE_user_type
        ]
        :operands [
            {:kind :LiteralString :name "User Type"}
        ]
    }
    :FunctionRoundingModeINTEL {
        :tag :FunctionRoundingModeINTEL
        :value 5822
        :capabilities [
            :FunctionFloatControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
            {:kind :FPRoundingMode :name "FP Rounding Mode"}
        ]
    }
    :FunctionDenormModeINTEL {
        :tag :FunctionDenormModeINTEL
        :value 5823
        :capabilities [
            :FunctionFloatControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
            {:kind :FPDenormMode :name "FP Denorm Mode"}
        ]
    }
    :RegisterINTEL {
        :tag :RegisterINTEL
        :value 5825
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
    }
    :MemoryINTEL {
        :tag :MemoryINTEL
        :value 5826
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralString :name "Memory Type"}
        ]
    }
    :NumbanksINTEL {
        :tag :NumbanksINTEL
        :value 5827
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Banks"}
        ]
    }
    :BankwidthINTEL {
        :tag :BankwidthINTEL
        :value 5828
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Bank Width"}
        ]
    }
    :MaxPrivateCopiesINTEL {
        :tag :MaxPrivateCopiesINTEL
        :value 5829
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Maximum Copies"}
        ]
    }
    :SinglepumpINTEL {
        :tag :SinglepumpINTEL
        :value 5830
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
    }
    :DoublepumpINTEL {
        :tag :DoublepumpINTEL
        :value 5831
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
    }
    :MaxReplicatesINTEL {
        :tag :MaxReplicatesINTEL
        :value 5832
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Maximum Replicates"}
        ]
    }
    :SimpleDualPortINTEL {
        :tag :SimpleDualPortINTEL
        :value 5833
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
    }
    :MergeINTEL {
        :tag :MergeINTEL
        :value 5834
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralString :name "Merge Key"}
            {:kind :LiteralString :name "Merge Type"}
        ]
    }
    :BankBitsINTEL {
        :tag :BankBitsINTEL
        :value 5835
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :quantifier :* :name "Bank Bits"}
        ]
    }
    :ForcePow2DepthINTEL {
        :tag :ForcePow2DepthINTEL
        :value 5836
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Force Key"}
        ]
    }
    :StridesizeINTEL {
        :tag :StridesizeINTEL
        :value 5883
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Stride Size"}
        ]
    }
    :WordsizeINTEL {
        :tag :WordsizeINTEL
        :value 5884
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Word Size"}
        ]
    }
    :TrueDualPortINTEL {
        :tag :TrueDualPortINTEL
        :value 5885
        :capabilities [
            :FPGAMemoryAttributesINTEL
        ]
    }
    :BurstCoalesceINTEL {
        :tag :BurstCoalesceINTEL
        :value 5899
        :capabilities [
            :FPGAMemoryAccessesINTEL
        ]
    }
    :CacheSizeINTEL {
        :tag :CacheSizeINTEL
        :value 5900
        :capabilities [
            :FPGAMemoryAccessesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Cache Size in bytes"}
        ]
    }
    :DontStaticallyCoalesceINTEL {
        :tag :DontStaticallyCoalesceINTEL
        :value 5901
        :capabilities [
            :FPGAMemoryAccessesINTEL
        ]
    }
    :PrefetchINTEL {
        :tag :PrefetchINTEL
        :value 5902
        :capabilities [
            :FPGAMemoryAccessesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Prefetcher Size in bytes"}
        ]
    }
    :StallEnableINTEL {
        :tag :StallEnableINTEL
        :value 5905
        :capabilities [
            :FPGAClusterAttributesINTEL
        ]
    }
    :FuseLoopsInFunctionINTEL {
        :tag :FuseLoopsInFunctionINTEL
        :value 5907
        :capabilities [
            :LoopFuseINTEL
        ]
    }
    :MathOpDSPModeINTEL {
        :tag :MathOpDSPModeINTEL
        :value 5909
        :capabilities [
            :FPGADSPControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Mode"}
            {:kind :LiteralInteger :name "Propagate"}
        ]
    }
    :AliasScopeINTEL {
        :tag :AliasScopeINTEL
        :value 5914
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdRef :name "Aliasing Scopes List"}
        ]
    }
    :NoAliasINTEL {
        :tag :NoAliasINTEL
        :value 5915
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdRef :name "Aliasing Scopes List"}
        ]
    }
    :InitiationIntervalINTEL {
        :tag :InitiationIntervalINTEL
        :value 5917
        :capabilities [
            :FPGAInvocationPipeliningAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Cycles"}
        ]
    }
    :MaxConcurrencyINTEL {
        :tag :MaxConcurrencyINTEL
        :value 5918
        :capabilities [
            :FPGAInvocationPipeliningAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Invocations"}
        ]
    }
    :PipelineEnableINTEL {
        :tag :PipelineEnableINTEL
        :value 5919
        :capabilities [
            :FPGAInvocationPipeliningAttributesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Enable"}
        ]
    }
    :BufferLocationINTEL {
        :tag :BufferLocationINTEL
        :value 5921
        :capabilities [
            :FPGABufferLocationINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Buffer Location ID"}
        ]
    }
    :IOPipeStorageINTEL {
        :tag :IOPipeStorageINTEL
        :value 5944
        :capabilities [
            :IOPipesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "IO Pipe ID"}
        ]
    }
    :FunctionFloatingPointModeINTEL {
        :tag :FunctionFloatingPointModeINTEL
        :value 6080
        :capabilities [
            :FunctionFloatControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Target Width"}
            {:kind :FPOperationMode :name "FP Operation Mode"}
        ]
    }
    :SingleElementVectorINTEL {
        :tag :SingleElementVectorINTEL
        :value 6085
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :VectorComputeCallableFunctionINTEL {
        :tag :VectorComputeCallableFunctionINTEL
        :value 6087
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :MediaBlockIOINTEL {
        :tag :MediaBlockIOINTEL
        :value 6140
        :capabilities [
            :VectorComputeINTEL
        ]
    }
    :StallFreeINTEL {
        :tag :StallFreeINTEL
        :value 6151
        :capabilities [
            :FPGAClusterAttributesV2INTEL
        ]
    }
    :FPMaxErrorDecorationINTEL {
        :tag :FPMaxErrorDecorationINTEL
        :value 6170
        :capabilities [
            :FPMaxErrorINTEL
        ]
        :operands [
            {:kind :LiteralFloat :name "Max Error"}
        ]
    }
    :LatencyControlLabelINTEL {
        :tag :LatencyControlLabelINTEL
        :value 6172
        :capabilities [
            :FPGALatencyControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Latency Label"}
        ]
    }
    :LatencyControlConstraintINTEL {
        :tag :LatencyControlConstraintINTEL
        :value 6173
        :capabilities [
            :FPGALatencyControlINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Relative To"}
            {:kind :LiteralInteger :name "Control Type"}
            {:kind :LiteralInteger :name "Relative Cycle"}
        ]
    }
    :ConduitKernelArgumentINTEL {
        :tag :ConduitKernelArgumentINTEL
        :value 6175
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
    }
    :RegisterMapKernelArgumentINTEL {
        :tag :RegisterMapKernelArgumentINTEL
        :value 6176
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
    }
    :MMHostInterfaceAddressWidthINTEL {
        :tag :MMHostInterfaceAddressWidthINTEL
        :value 6177
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "AddressWidth"}
        ]
    }
    :MMHostInterfaceDataWidthINTEL {
        :tag :MMHostInterfaceDataWidthINTEL
        :value 6178
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "DataWidth"}
        ]
    }
    :MMHostInterfaceLatencyINTEL {
        :tag :MMHostInterfaceLatencyINTEL
        :value 6179
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Latency"}
        ]
    }
    :MMHostInterfaceReadWriteModeINTEL {
        :tag :MMHostInterfaceReadWriteModeINTEL
        :value 6180
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :AccessQualifier :name "ReadWriteMode"}
        ]
    }
    :MMHostInterfaceMaxBurstINTEL {
        :tag :MMHostInterfaceMaxBurstINTEL
        :value 6181
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "MaxBurstCount"}
        ]
    }
    :MMHostInterfaceWaitRequestINTEL {
        :tag :MMHostInterfaceWaitRequestINTEL
        :value 6182
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Waitrequest"}
        ]
    }
    :StableKernelArgumentINTEL {
        :tag :StableKernelArgumentINTEL
        :value 6183
        :capabilities [
            :FPGAArgumentInterfacesINTEL
        ]
    }
    :HostAccessINTEL {
        :tag :HostAccessINTEL
        :value 6188
        :capabilities [
            :GlobalVariableHostAccessINTEL
        ]
        :operands [
            {:kind :HostAccessQualifier :name "Access"}
            {:kind :LiteralString :name "Name"}
        ]
    }
    :InitModeINTEL {
        :tag :InitModeINTEL
        :value 6190
        :capabilities [
            :GlobalVariableFPGADecorationsINTEL
        ]
        :operands [
            {:kind :InitializationModeQualifier :name "Trigger"}
        ]
    }
    :ImplementInRegisterMapINTEL {
        :tag :ImplementInRegisterMapINTEL
        :value 6191
        :capabilities [
            :GlobalVariableFPGADecorationsINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Value"}
        ]
    }
    :CacheControlLoadINTEL {
        :tag :CacheControlLoadINTEL
        :value 6442
        :capabilities [
            :CacheControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Cache Level"}
            {:kind :LoadCacheControl :name "Cache Control"}
        ]
    }
    :CacheControlStoreINTEL {
        :tag :CacheControlStoreINTEL
        :value 6443
        :capabilities [
            :CacheControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger :name "Cache Level"}
            {:kind :StoreCacheControl :name "Cache Control"}
        ]
    }
}))

(set Decoration.enumerants.PerPrimitiveNV Decoration.enumerants.PerPrimitiveEXT)
(set Decoration.enumerants.PerVertexNV Decoration.enumerants.PerVertexKHR)
(set Decoration.enumerants.NonUniformEXT Decoration.enumerants.NonUniform)
(set Decoration.enumerants.RestrictPointerEXT Decoration.enumerants.RestrictPointer)
(set Decoration.enumerants.AliasedPointerEXT Decoration.enumerants.AliasedPointer)
(set Decoration.enumerants.HlslCounterBufferGOOGLE Decoration.enumerants.CounterBuffer)
(set Decoration.enumerants.HlslSemanticGOOGLE Decoration.enumerants.UserSemantic)


(local BuiltIn (mk-enum :BuiltIn :value {
    :Position {
        :tag :Position
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :PointSize {
        :tag :PointSize
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :ClipDistance {
        :tag :ClipDistance
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :ClipDistance
        ]
    }
    :CullDistance {
        :tag :CullDistance
        :value 4
        :version { :major 1 :minor 0 }
        :capabilities [
            :CullDistance
        ]
    }
    :VertexId {
        :tag :VertexId
        :value 5
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :InstanceId {
        :tag :InstanceId
        :value 6
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :PrimitiveId {
        :tag :PrimitiveId
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :Tessellation
            :RayTracingNV
            :RayTracingKHR
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :InvocationId {
        :tag :InvocationId
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :Tessellation
        ]
    }
    :Layer {
        :tag :Layer
        :value 9
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
            :ShaderLayer
            :ShaderViewportIndexLayerEXT
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :ViewportIndex {
        :tag :ViewportIndex
        :value 10
        :version { :major 1 :minor 0 }
        :capabilities [
            :MultiViewport
            :ShaderViewportIndex
            :ShaderViewportIndexLayerEXT
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :TessLevelOuter {
        :tag :TessLevelOuter
        :value 11
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :TessLevelInner {
        :tag :TessLevelInner
        :value 12
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :TessCoord {
        :tag :TessCoord
        :value 13
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :PatchVertices {
        :tag :PatchVertices
        :value 14
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :FragCoord {
        :tag :FragCoord
        :value 15
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :PointCoord {
        :tag :PointCoord
        :value 16
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :FrontFacing {
        :tag :FrontFacing
        :value 17
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SampleId {
        :tag :SampleId
        :value 18
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampleRateShading
        ]
    }
    :SamplePosition {
        :tag :SamplePosition
        :value 19
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampleRateShading
        ]
    }
    :SampleMask {
        :tag :SampleMask
        :value 20
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :FragDepth {
        :tag :FragDepth
        :value 22
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :HelperInvocation {
        :tag :HelperInvocation
        :value 23
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :NumWorkgroups {
        :tag :NumWorkgroups
        :value 24
        :version { :major 1 :minor 0 }
    }
    :WorkgroupSize {
        :tag :WorkgroupSize
        :value 25
        :version { :major 1 :minor 0 }
    }
    :WorkgroupId {
        :tag :WorkgroupId
        :value 26
        :version { :major 1 :minor 0 }
    }
    :LocalInvocationId {
        :tag :LocalInvocationId
        :value 27
        :version { :major 1 :minor 0 }
    }
    :GlobalInvocationId {
        :tag :GlobalInvocationId
        :value 28
        :version { :major 1 :minor 0 }
    }
    :LocalInvocationIndex {
        :tag :LocalInvocationIndex
        :value 29
        :version { :major 1 :minor 0 }
    }
    :WorkDim {
        :tag :WorkDim
        :value 30
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :GlobalSize {
        :tag :GlobalSize
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :EnqueuedWorkgroupSize {
        :tag :EnqueuedWorkgroupSize
        :value 32
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :GlobalOffset {
        :tag :GlobalOffset
        :value 33
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :GlobalLinearId {
        :tag :GlobalLinearId
        :value 34
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :SubgroupSize {
        :tag :SubgroupSize
        :value 36
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniform
            :SubgroupBallotKHR
        ]
    }
    :SubgroupMaxSize {
        :tag :SubgroupMaxSize
        :value 37
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :NumSubgroups {
        :tag :NumSubgroups
        :value 38
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniform
        ]
    }
    :NumEnqueuedSubgroups {
        :tag :NumEnqueuedSubgroups
        :value 39
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :SubgroupId {
        :tag :SubgroupId
        :value 40
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniform
        ]
    }
    :SubgroupLocalInvocationId {
        :tag :SubgroupLocalInvocationId
        :value 41
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniform
            :SubgroupBallotKHR
        ]
    }
    :VertexIndex {
        :tag :VertexIndex
        :value 42
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :InstanceIndex {
        :tag :InstanceIndex
        :value 43
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :CoreIDARM {
        :tag :CoreIDARM
        :value 4160
        :version { :major 1 :minor 0 }
        :capabilities [
            :CoreBuiltinsARM
        ]
    }
    :CoreCountARM {
        :tag :CoreCountARM
        :value 4161
        :version { :major 1 :minor 0 }
        :capabilities [
            :CoreBuiltinsARM
        ]
    }
    :CoreMaxIDARM {
        :tag :CoreMaxIDARM
        :value 4162
        :version { :major 1 :minor 0 }
        :capabilities [
            :CoreBuiltinsARM
        ]
    }
    :WarpIDARM {
        :tag :WarpIDARM
        :value 4163
        :version { :major 1 :minor 0 }
        :capabilities [
            :CoreBuiltinsARM
        ]
    }
    :WarpMaxIDARM {
        :tag :WarpMaxIDARM
        :value 4164
        :version { :major 1 :minor 0 }
        :capabilities [
            :CoreBuiltinsARM
        ]
    }
    :SubgroupEqMask {
        :tag :SubgroupEqMask
        :value 4416
        :version { :major 1 :minor 3 }
        :capabilities [
            :SubgroupBallotKHR
            :GroupNonUniformBallot
        ]
    }
    :SubgroupGeMask {
        :tag :SubgroupGeMask
        :value 4417
        :version { :major 1 :minor 3 }
        :capabilities [
            :SubgroupBallotKHR
            :GroupNonUniformBallot
        ]
    }
    :SubgroupGtMask {
        :tag :SubgroupGtMask
        :value 4418
        :version { :major 1 :minor 3 }
        :capabilities [
            :SubgroupBallotKHR
            :GroupNonUniformBallot
        ]
    }
    :SubgroupLeMask {
        :tag :SubgroupLeMask
        :value 4419
        :version { :major 1 :minor 3 }
        :capabilities [
            :SubgroupBallotKHR
            :GroupNonUniformBallot
        ]
    }
    :SubgroupLtMask {
        :tag :SubgroupLtMask
        :value 4420
        :version { :major 1 :minor 3 }
        :capabilities [
            :SubgroupBallotKHR
            :GroupNonUniformBallot
        ]
    }
    :BaseVertex {
        :tag :BaseVertex
        :value 4424
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_shader_draw_parameters
        ]
        :capabilities [
            :DrawParameters
        ]
    }
    :BaseInstance {
        :tag :BaseInstance
        :value 4425
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_shader_draw_parameters
        ]
        :capabilities [
            :DrawParameters
        ]
    }
    :DrawIndex {
        :tag :DrawIndex
        :value 4426
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_shader_draw_parameters
            :SPV_NV_mesh_shader
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :DrawParameters
            :MeshShadingNV
            :MeshShadingEXT
        ]
    }
    :PrimitiveShadingRateKHR {
        :tag :PrimitiveShadingRateKHR
        :value 4432
        :extensions [
            :SPV_KHR_fragment_shading_rate
        ]
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
    :DeviceIndex {
        :tag :DeviceIndex
        :value 4438
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_device_group
        ]
        :capabilities [
            :DeviceGroup
        ]
    }
    :ViewIndex {
        :tag :ViewIndex
        :value 4440
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_multiview
        ]
        :capabilities [
            :MultiView
        ]
    }
    :ShadingRateKHR {
        :tag :ShadingRateKHR
        :value 4444
        :extensions [
            :SPV_KHR_fragment_shading_rate
        ]
        :capabilities [
            :FragmentShadingRateKHR
        ]
    }
    :BaryCoordNoPerspAMD {
        :tag :BaryCoordNoPerspAMD
        :value 4992
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordNoPerspCentroidAMD {
        :tag :BaryCoordNoPerspCentroidAMD
        :value 4993
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordNoPerspSampleAMD {
        :tag :BaryCoordNoPerspSampleAMD
        :value 4994
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordSmoothAMD {
        :tag :BaryCoordSmoothAMD
        :value 4995
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordSmoothCentroidAMD {
        :tag :BaryCoordSmoothCentroidAMD
        :value 4996
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordSmoothSampleAMD {
        :tag :BaryCoordSmoothSampleAMD
        :value 4997
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :BaryCoordPullModelAMD {
        :tag :BaryCoordPullModelAMD
        :value 4998
        :extensions [
            :SPV_AMD_shader_explicit_vertex_parameter
        ]
    }
    :FragStencilRefEXT {
        :tag :FragStencilRefEXT
        :value 5014
        :extensions [
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :StencilExportEXT
        ]
    }
    :CoalescedInputCountAMDX {
        :tag :CoalescedInputCountAMDX
        :value 5021
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :ShaderIndexAMDX {
        :tag :ShaderIndexAMDX
        :value 5073
        :capabilities [
            :ShaderEnqueueAMDX
        ]
    }
    :ViewportMaskNV {
        :tag :ViewportMaskNV
        :value 5253
        :extensions [
            :SPV_NV_viewport_array2
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :ShaderViewportMaskNV
            :MeshShadingNV
        ]
    }
    :SecondaryPositionNV {
        :tag :SecondaryPositionNV
        :value 5257
        :extensions [
            :SPV_NV_stereo_view_rendering
        ]
        :capabilities [
            :ShaderStereoViewNV
        ]
    }
    :SecondaryViewportMaskNV {
        :tag :SecondaryViewportMaskNV
        :value 5258
        :extensions [
            :SPV_NV_stereo_view_rendering
        ]
        :capabilities [
            :ShaderStereoViewNV
        ]
    }
    :PositionPerViewNV {
        :tag :PositionPerViewNV
        :value 5261
        :extensions [
            :SPV_NVX_multiview_per_view_attributes
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :PerViewAttributesNV
            :MeshShadingNV
        ]
    }
    :ViewportMaskPerViewNV {
        :tag :ViewportMaskPerViewNV
        :value 5262
        :extensions [
            :SPV_NVX_multiview_per_view_attributes
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :PerViewAttributesNV
            :MeshShadingNV
        ]
    }
    :FullyCoveredEXT {
        :tag :FullyCoveredEXT
        :value 5264
        :extensions [
            :SPV_EXT_fragment_fully_covered
        ]
        :capabilities [
            :FragmentFullyCoveredEXT
        ]
    }
    :TaskCountNV {
        :tag :TaskCountNV
        :value 5274
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :PrimitiveCountNV {
        :tag :PrimitiveCountNV
        :value 5275
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :PrimitiveIndicesNV {
        :tag :PrimitiveIndicesNV
        :value 5276
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :ClipDistancePerViewNV {
        :tag :ClipDistancePerViewNV
        :value 5277
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :CullDistancePerViewNV {
        :tag :CullDistancePerViewNV
        :value 5278
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :LayerPerViewNV {
        :tag :LayerPerViewNV
        :value 5279
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :MeshViewCountNV {
        :tag :MeshViewCountNV
        :value 5280
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :MeshViewIndicesNV {
        :tag :MeshViewIndicesNV
        :value 5281
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
    }
    :BaryCoordKHR {
        :tag :BaryCoordKHR
        :value 5286
        :extensions [
            :SPV_NV_fragment_shader_barycentric
            :SPV_KHR_fragment_shader_barycentric
        ]
        :capabilities [
            :FragmentBarycentricNV
            :FragmentBarycentricKHR
        ]
    }
    :BaryCoordNoPerspKHR {
        :tag :BaryCoordNoPerspKHR
        :value 5287
        :extensions [
            :SPV_NV_fragment_shader_barycentric
            :SPV_KHR_fragment_shader_barycentric
        ]
        :capabilities [
            :FragmentBarycentricNV
            :FragmentBarycentricKHR
        ]
    }
    :FragSizeEXT {
        :tag :FragSizeEXT
        :value 5292
        :extensions [
            :SPV_EXT_fragment_invocation_density
            :SPV_NV_shading_rate
        ]
        :capabilities [
            :FragmentDensityEXT
            :ShadingRateNV
        ]
    }
    :FragInvocationCountEXT {
        :tag :FragInvocationCountEXT
        :value 5293
        :extensions [
            :SPV_EXT_fragment_invocation_density
            :SPV_NV_shading_rate
        ]
        :capabilities [
            :FragmentDensityEXT
            :ShadingRateNV
        ]
    }
    :PrimitivePointIndicesEXT {
        :tag :PrimitivePointIndicesEXT
        :value 5294
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :PrimitiveLineIndicesEXT {
        :tag :PrimitiveLineIndicesEXT
        :value 5295
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :PrimitiveTriangleIndicesEXT {
        :tag :PrimitiveTriangleIndicesEXT
        :value 5296
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :CullPrimitiveEXT {
        :tag :CullPrimitiveEXT
        :value 5299
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :MeshShadingEXT
        ]
    }
    :LaunchIdKHR {
        :tag :LaunchIdKHR
        :value 5319
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :LaunchSizeKHR {
        :tag :LaunchSizeKHR
        :value 5320
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :WorldRayOriginKHR {
        :tag :WorldRayOriginKHR
        :value 5321
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :WorldRayDirectionKHR {
        :tag :WorldRayDirectionKHR
        :value 5322
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :ObjectRayOriginKHR {
        :tag :ObjectRayOriginKHR
        :value 5323
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :ObjectRayDirectionKHR {
        :tag :ObjectRayDirectionKHR
        :value 5324
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :RayTminKHR {
        :tag :RayTminKHR
        :value 5325
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :RayTmaxKHR {
        :tag :RayTmaxKHR
        :value 5326
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :InstanceCustomIndexKHR {
        :tag :InstanceCustomIndexKHR
        :value 5327
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :ObjectToWorldKHR {
        :tag :ObjectToWorldKHR
        :value 5330
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :WorldToObjectKHR {
        :tag :WorldToObjectKHR
        :value 5331
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :HitTNV {
        :tag :HitTNV
        :value 5332
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
        ]
    }
    :HitKindKHR {
        :tag :HitKindKHR
        :value 5333
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :CurrentRayTimeNV {
        :tag :CurrentRayTimeNV
        :value 5334
        :extensions [
            :SPV_NV_ray_tracing_motion_blur
        ]
        :capabilities [
            :RayTracingMotionBlurNV
        ]
    }
    :HitTriangleVertexPositionsKHR {
        :tag :HitTriangleVertexPositionsKHR
        :value 5335
        :capabilities [
            :RayTracingPositionFetchKHR
        ]
    }
    :HitMicroTriangleVertexPositionsNV {
        :tag :HitMicroTriangleVertexPositionsNV
        :value 5337
        :capabilities [
            :RayTracingDisplacementMicromapNV
        ]
    }
    :HitMicroTriangleVertexBarycentricsNV {
        :tag :HitMicroTriangleVertexBarycentricsNV
        :value 5344
        :capabilities [
            :RayTracingDisplacementMicromapNV
        ]
    }
    :IncomingRayFlagsKHR {
        :tag :IncomingRayFlagsKHR
        :value 5351
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
    }
    :RayGeometryIndexKHR {
        :tag :RayGeometryIndexKHR
        :value 5352
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingKHR
        ]
    }
    :WarpsPerSMNV {
        :tag :WarpsPerSMNV
        :value 5374
        :extensions [
            :SPV_NV_shader_sm_builtins
        ]
        :capabilities [
            :ShaderSMBuiltinsNV
        ]
    }
    :SMCountNV {
        :tag :SMCountNV
        :value 5375
        :extensions [
            :SPV_NV_shader_sm_builtins
        ]
        :capabilities [
            :ShaderSMBuiltinsNV
        ]
    }
    :WarpIDNV {
        :tag :WarpIDNV
        :value 5376
        :extensions [
            :SPV_NV_shader_sm_builtins
        ]
        :capabilities [
            :ShaderSMBuiltinsNV
        ]
    }
    :SMIDNV {
        :tag :SMIDNV
        :value 5377
        :extensions [
            :SPV_NV_shader_sm_builtins
        ]
        :capabilities [
            :ShaderSMBuiltinsNV
        ]
    }
    :HitKindFrontFacingMicroTriangleNV {
        :tag :HitKindFrontFacingMicroTriangleNV
        :value 5405
        :capabilities [
            :RayTracingDisplacementMicromapNV
        ]
    }
    :HitKindBackFacingMicroTriangleNV {
        :tag :HitKindBackFacingMicroTriangleNV
        :value 5406
        :capabilities [
            :RayTracingDisplacementMicromapNV
        ]
    }
    :CullMaskKHR {
        :tag :CullMaskKHR
        :value 6021
        :extensions [
            :SPV_KHR_ray_cull_mask
        ]
        :capabilities [
            :RayCullMaskKHR
        ]
    }
}))

(set BuiltIn.enumerants.SubgroupEqMaskKHR BuiltIn.enumerants.SubgroupEqMask)
(set BuiltIn.enumerants.SubgroupGeMaskKHR BuiltIn.enumerants.SubgroupGeMask)
(set BuiltIn.enumerants.SubgroupGtMaskKHR BuiltIn.enumerants.SubgroupGtMask)
(set BuiltIn.enumerants.SubgroupLeMaskKHR BuiltIn.enumerants.SubgroupLeMask)
(set BuiltIn.enumerants.SubgroupLtMaskKHR BuiltIn.enumerants.SubgroupLtMask)
(set BuiltIn.enumerants.BaryCoordNV BuiltIn.enumerants.BaryCoordKHR)
(set BuiltIn.enumerants.BaryCoordNoPerspNV BuiltIn.enumerants.BaryCoordNoPerspKHR)
(set BuiltIn.enumerants.FragmentSizeNV BuiltIn.enumerants.FragSizeEXT)
(set BuiltIn.enumerants.InvocationsPerPixelNV BuiltIn.enumerants.FragInvocationCountEXT)
(set BuiltIn.enumerants.LaunchIdNV BuiltIn.enumerants.LaunchIdKHR)
(set BuiltIn.enumerants.LaunchSizeNV BuiltIn.enumerants.LaunchSizeKHR)
(set BuiltIn.enumerants.WorldRayOriginNV BuiltIn.enumerants.WorldRayOriginKHR)
(set BuiltIn.enumerants.WorldRayDirectionNV BuiltIn.enumerants.WorldRayDirectionKHR)
(set BuiltIn.enumerants.ObjectRayOriginNV BuiltIn.enumerants.ObjectRayOriginKHR)
(set BuiltIn.enumerants.ObjectRayDirectionNV BuiltIn.enumerants.ObjectRayDirectionKHR)
(set BuiltIn.enumerants.RayTminNV BuiltIn.enumerants.RayTminKHR)
(set BuiltIn.enumerants.RayTmaxNV BuiltIn.enumerants.RayTmaxKHR)
(set BuiltIn.enumerants.InstanceCustomIndexNV BuiltIn.enumerants.InstanceCustomIndexKHR)
(set BuiltIn.enumerants.ObjectToWorldNV BuiltIn.enumerants.ObjectToWorldKHR)
(set BuiltIn.enumerants.WorldToObjectNV BuiltIn.enumerants.WorldToObjectKHR)
(set BuiltIn.enumerants.HitKindNV BuiltIn.enumerants.HitKindKHR)
(set BuiltIn.enumerants.IncomingRayFlagsNV BuiltIn.enumerants.IncomingRayFlagsKHR)


(local Scope (mk-enum :Scope :value {
    :CrossDevice {
        :tag :CrossDevice
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Device {
        :tag :Device
        :value 1
        :version { :major 1 :minor 0 }
    }
    :Workgroup {
        :tag :Workgroup
        :value 2
        :version { :major 1 :minor 0 }
    }
    :Subgroup {
        :tag :Subgroup
        :value 3
        :version { :major 1 :minor 0 }
    }
    :Invocation {
        :tag :Invocation
        :value 4
        :version { :major 1 :minor 0 }
    }
    :QueueFamily {
        :tag :QueueFamily
        :value 5
        :version { :major 1 :minor 5 }
        :capabilities [
            :VulkanMemoryModel
        ]
    }
    :ShaderCallKHR {
        :tag :ShaderCallKHR
        :value 6
        :capabilities [
            :RayTracingKHR
        ]
    }
}))

(set Scope.enumerants.QueueFamilyKHR Scope.enumerants.QueueFamily)


(local GroupOperation (mk-enum :GroupOperation :value {
    :Reduce {
        :tag :Reduce
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniformArithmetic
            :GroupNonUniformBallot
        ]
    }
    :InclusiveScan {
        :tag :InclusiveScan
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniformArithmetic
            :GroupNonUniformBallot
        ]
    }
    :ExclusiveScan {
        :tag :ExclusiveScan
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :GroupNonUniformArithmetic
            :GroupNonUniformBallot
        ]
    }
    :ClusteredReduce {
        :tag :ClusteredReduce
        :value 3
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformClustered
        ]
    }
    :PartitionedReduceNV {
        :tag :PartitionedReduceNV
        :value 6
        :extensions [
            :SPV_NV_shader_subgroup_partitioned
        ]
        :capabilities [
            :GroupNonUniformPartitionedNV
        ]
    }
    :PartitionedInclusiveScanNV {
        :tag :PartitionedInclusiveScanNV
        :value 7
        :extensions [
            :SPV_NV_shader_subgroup_partitioned
        ]
        :capabilities [
            :GroupNonUniformPartitionedNV
        ]
    }
    :PartitionedExclusiveScanNV {
        :tag :PartitionedExclusiveScanNV
        :value 8
        :extensions [
            :SPV_NV_shader_subgroup_partitioned
        ]
        :capabilities [
            :GroupNonUniformPartitionedNV
        ]
    }
}))


(local KernelEnqueueFlags (mk-enum :KernelEnqueueFlags :value {
    :NoWait {
        :tag :NoWait
        :value 0
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :WaitKernel {
        :tag :WaitKernel
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :WaitWorkGroup {
        :tag :WaitWorkGroup
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
}))


(local Capability (mk-enum :Capability :value {
    :Matrix {
        :tag :Matrix
        :value 0
        :version { :major 1 :minor 0 }
    }
    :Shader {
        :tag :Shader
        :value 1
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
    }
    :Geometry {
        :tag :Geometry
        :value 2
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Tessellation {
        :tag :Tessellation
        :value 3
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Addresses {
        :tag :Addresses
        :value 4
        :version { :major 1 :minor 0 }
    }
    :Linkage {
        :tag :Linkage
        :value 5
        :version { :major 1 :minor 0 }
    }
    :Kernel {
        :tag :Kernel
        :value 6
        :version { :major 1 :minor 0 }
    }
    :Vector16 {
        :tag :Vector16
        :value 7
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Float16Buffer {
        :tag :Float16Buffer
        :value 8
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Float16 {
        :tag :Float16
        :value 9
        :version { :major 1 :minor 0 }
    }
    :Float64 {
        :tag :Float64
        :value 10
        :version { :major 1 :minor 0 }
    }
    :Int64 {
        :tag :Int64
        :value 11
        :version { :major 1 :minor 0 }
    }
    :Int64Atomics {
        :tag :Int64Atomics
        :value 12
        :version { :major 1 :minor 0 }
        :capabilities [
            :Int64
        ]
    }
    :ImageBasic {
        :tag :ImageBasic
        :value 13
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :ImageReadWrite {
        :tag :ImageReadWrite
        :value 14
        :version { :major 1 :minor 0 }
        :capabilities [
            :ImageBasic
        ]
    }
    :ImageMipmap {
        :tag :ImageMipmap
        :value 15
        :version { :major 1 :minor 0 }
        :capabilities [
            :ImageBasic
        ]
    }
    :Pipes {
        :tag :Pipes
        :value 17
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :Groups {
        :tag :Groups
        :value 18
        :version { :major 1 :minor 0 }
        :extensions [
            :SPV_AMD_shader_ballot
        ]
    }
    :DeviceEnqueue {
        :tag :DeviceEnqueue
        :value 19
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :LiteralSampler {
        :tag :LiteralSampler
        :value 20
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
    }
    :AtomicStorage {
        :tag :AtomicStorage
        :value 21
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Int16 {
        :tag :Int16
        :value 22
        :version { :major 1 :minor 0 }
    }
    :TessellationPointSize {
        :tag :TessellationPointSize
        :value 23
        :version { :major 1 :minor 0 }
        :capabilities [
            :Tessellation
        ]
    }
    :GeometryPointSize {
        :tag :GeometryPointSize
        :value 24
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :ImageGatherExtended {
        :tag :ImageGatherExtended
        :value 25
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :StorageImageMultisample {
        :tag :StorageImageMultisample
        :value 27
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :UniformBufferArrayDynamicIndexing {
        :tag :UniformBufferArrayDynamicIndexing
        :value 28
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SampledImageArrayDynamicIndexing {
        :tag :SampledImageArrayDynamicIndexing
        :value 29
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :StorageBufferArrayDynamicIndexing {
        :tag :StorageBufferArrayDynamicIndexing
        :value 30
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :StorageImageArrayDynamicIndexing {
        :tag :StorageImageArrayDynamicIndexing
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :ClipDistance {
        :tag :ClipDistance
        :value 32
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :CullDistance {
        :tag :CullDistance
        :value 33
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :ImageCubeArray {
        :tag :ImageCubeArray
        :value 34
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampledCubeArray
        ]
    }
    :SampleRateShading {
        :tag :SampleRateShading
        :value 35
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :ImageRect {
        :tag :ImageRect
        :value 36
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampledRect
        ]
    }
    :SampledRect {
        :tag :SampledRect
        :value 37
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :GenericPointer {
        :tag :GenericPointer
        :value 38
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
        ]
    }
    :Int8 {
        :tag :Int8
        :value 39
        :version { :major 1 :minor 0 }
    }
    :InputAttachment {
        :tag :InputAttachment
        :value 40
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SparseResidency {
        :tag :SparseResidency
        :value 41
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :MinLod {
        :tag :MinLod
        :value 42
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :Sampled1D {
        :tag :Sampled1D
        :value 43
        :version { :major 1 :minor 0 }
    }
    :Image1D {
        :tag :Image1D
        :value 44
        :version { :major 1 :minor 0 }
        :capabilities [
            :Sampled1D
        ]
    }
    :SampledCubeArray {
        :tag :SampledCubeArray
        :value 45
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :SampledBuffer {
        :tag :SampledBuffer
        :value 46
        :version { :major 1 :minor 0 }
    }
    :ImageBuffer {
        :tag :ImageBuffer
        :value 47
        :version { :major 1 :minor 0 }
        :capabilities [
            :SampledBuffer
        ]
    }
    :ImageMSArray {
        :tag :ImageMSArray
        :value 48
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :StorageImageExtendedFormats {
        :tag :StorageImageExtendedFormats
        :value 49
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :ImageQuery {
        :tag :ImageQuery
        :value 50
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :DerivativeControl {
        :tag :DerivativeControl
        :value 51
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :InterpolationFunction {
        :tag :InterpolationFunction
        :value 52
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :TransformFeedback {
        :tag :TransformFeedback
        :value 53
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :GeometryStreams {
        :tag :GeometryStreams
        :value 54
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :StorageImageReadWithoutFormat {
        :tag :StorageImageReadWithoutFormat
        :value 55
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :StorageImageWriteWithoutFormat {
        :tag :StorageImageWriteWithoutFormat
        :value 56
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :MultiViewport {
        :tag :MultiViewport
        :value 57
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :SubgroupDispatch {
        :tag :SubgroupDispatch
        :value 58
        :version { :major 1 :minor 1 }
        :capabilities [
            :DeviceEnqueue
        ]
    }
    :NamedBarrier {
        :tag :NamedBarrier
        :value 59
        :version { :major 1 :minor 1 }
        :capabilities [
            :Kernel
        ]
    }
    :PipeStorage {
        :tag :PipeStorage
        :value 60
        :version { :major 1 :minor 1 }
        :capabilities [
            :Pipes
        ]
    }
    :GroupNonUniform {
        :tag :GroupNonUniform
        :value 61
        :version { :major 1 :minor 3 }
    }
    :GroupNonUniformVote {
        :tag :GroupNonUniformVote
        :value 62
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformArithmetic {
        :tag :GroupNonUniformArithmetic
        :value 63
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformBallot {
        :tag :GroupNonUniformBallot
        :value 64
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformShuffle {
        :tag :GroupNonUniformShuffle
        :value 65
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformShuffleRelative {
        :tag :GroupNonUniformShuffleRelative
        :value 66
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformClustered {
        :tag :GroupNonUniformClustered
        :value 67
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :GroupNonUniformQuad {
        :tag :GroupNonUniformQuad
        :value 68
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
    }
    :ShaderLayer {
        :tag :ShaderLayer
        :value 69
        :version { :major 1 :minor 5 }
    }
    :ShaderViewportIndex {
        :tag :ShaderViewportIndex
        :value 70
        :version { :major 1 :minor 5 }
    }
    :UniformDecoration {
        :tag :UniformDecoration
        :value 71
        :version { :major 1 :minor 6 }
    }
    :CoreBuiltinsARM {
        :tag :CoreBuiltinsARM
        :value 4165
        :extensions [
            :SPV_ARM_core_builtins
        ]
    }
    :TileImageColorReadAccessEXT {
        :tag :TileImageColorReadAccessEXT
        :value 4166
        :extensions [
            :SPV_EXT_shader_tile_image
        ]
    }
    :TileImageDepthReadAccessEXT {
        :tag :TileImageDepthReadAccessEXT
        :value 4167
        :extensions [
            :SPV_EXT_shader_tile_image
        ]
    }
    :TileImageStencilReadAccessEXT {
        :tag :TileImageStencilReadAccessEXT
        :value 4168
        :extensions [
            :SPV_EXT_shader_tile_image
        ]
    }
    :FragmentShadingRateKHR {
        :tag :FragmentShadingRateKHR
        :value 4422
        :extensions [
            :SPV_KHR_fragment_shading_rate
        ]
        :capabilities [
            :Shader
        ]
    }
    :SubgroupBallotKHR {
        :tag :SubgroupBallotKHR
        :value 4423
        :extensions [
            :SPV_KHR_shader_ballot
        ]
    }
    :DrawParameters {
        :tag :DrawParameters
        :value 4427
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_shader_draw_parameters
        ]
        :capabilities [
            :Shader
        ]
    }
    :WorkgroupMemoryExplicitLayoutKHR {
        :tag :WorkgroupMemoryExplicitLayoutKHR
        :value 4428
        :extensions [
            :SPV_KHR_workgroup_memory_explicit_layout
        ]
        :capabilities [
            :Shader
        ]
    }
    :WorkgroupMemoryExplicitLayout8BitAccessKHR {
        :tag :WorkgroupMemoryExplicitLayout8BitAccessKHR
        :value 4429
        :extensions [
            :SPV_KHR_workgroup_memory_explicit_layout
        ]
        :capabilities [
            :WorkgroupMemoryExplicitLayoutKHR
        ]
    }
    :WorkgroupMemoryExplicitLayout16BitAccessKHR {
        :tag :WorkgroupMemoryExplicitLayout16BitAccessKHR
        :value 4430
        :extensions [
            :SPV_KHR_workgroup_memory_explicit_layout
        ]
        :capabilities [
            :WorkgroupMemoryExplicitLayoutKHR
        ]
    }
    :SubgroupVoteKHR {
        :tag :SubgroupVoteKHR
        :value 4431
        :extensions [
            :SPV_KHR_subgroup_vote
        ]
    }
    :StorageBuffer16BitAccess {
        :tag :StorageBuffer16BitAccess
        :value 4433
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_16bit_storage
        ]
    }
    :UniformAndStorageBuffer16BitAccess {
        :tag :UniformAndStorageBuffer16BitAccess
        :value 4434
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_16bit_storage
        ]
        :capabilities [
            :StorageBuffer16BitAccess
            :StorageUniformBufferBlock16
        ]
    }
    :StoragePushConstant16 {
        :tag :StoragePushConstant16
        :value 4435
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_16bit_storage
        ]
    }
    :StorageInputOutput16 {
        :tag :StorageInputOutput16
        :value 4436
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_16bit_storage
        ]
    }
    :DeviceGroup {
        :tag :DeviceGroup
        :value 4437
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_device_group
        ]
    }
    :MultiView {
        :tag :MultiView
        :value 4439
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_multiview
        ]
        :capabilities [
            :Shader
        ]
    }
    :VariablePointersStorageBuffer {
        :tag :VariablePointersStorageBuffer
        :value 4441
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_variable_pointers
        ]
        :capabilities [
            :Shader
        ]
    }
    :VariablePointers {
        :tag :VariablePointers
        :value 4442
        :version { :major 1 :minor 3 }
        :extensions [
            :SPV_KHR_variable_pointers
        ]
        :capabilities [
            :VariablePointersStorageBuffer
        ]
    }
    :AtomicStorageOps {
        :tag :AtomicStorageOps
        :value 4445
        :extensions [
            :SPV_KHR_shader_atomic_counter_ops
        ]
    }
    :SampleMaskPostDepthCoverage {
        :tag :SampleMaskPostDepthCoverage
        :value 4447
        :extensions [
            :SPV_KHR_post_depth_coverage
        ]
    }
    :StorageBuffer8BitAccess {
        :tag :StorageBuffer8BitAccess
        :value 4448
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_KHR_8bit_storage
        ]
    }
    :UniformAndStorageBuffer8BitAccess {
        :tag :UniformAndStorageBuffer8BitAccess
        :value 4449
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_KHR_8bit_storage
        ]
        :capabilities [
            :StorageBuffer8BitAccess
        ]
    }
    :StoragePushConstant8 {
        :tag :StoragePushConstant8
        :value 4450
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_KHR_8bit_storage
        ]
    }
    :DenormPreserve {
        :tag :DenormPreserve
        :value 4464
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
    }
    :DenormFlushToZero {
        :tag :DenormFlushToZero
        :value 4465
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
    }
    :SignedZeroInfNanPreserve {
        :tag :SignedZeroInfNanPreserve
        :value 4466
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
    }
    :RoundingModeRTE {
        :tag :RoundingModeRTE
        :value 4467
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
    }
    :RoundingModeRTZ {
        :tag :RoundingModeRTZ
        :value 4468
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_KHR_float_controls
        ]
    }
    :RayQueryProvisionalKHR {
        :tag :RayQueryProvisionalKHR
        :value 4471
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :Shader
        ]
    }
    :RayQueryKHR {
        :tag :RayQueryKHR
        :value 4472
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :Shader
        ]
    }
    :RayTraversalPrimitiveCullingKHR {
        :tag :RayTraversalPrimitiveCullingKHR
        :value 4478
        :extensions [
            :SPV_KHR_ray_query
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :RayTracingKHR {
        :tag :RayTracingKHR
        :value 4479
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :Shader
        ]
    }
    :TextureSampleWeightedQCOM {
        :tag :TextureSampleWeightedQCOM
        :value 4484
        :extensions [
            :SPV_QCOM_image_processing
        ]
    }
    :TextureBoxFilterQCOM {
        :tag :TextureBoxFilterQCOM
        :value 4485
        :extensions [
            :SPV_QCOM_image_processing
        ]
    }
    :TextureBlockMatchQCOM {
        :tag :TextureBlockMatchQCOM
        :value 4486
        :extensions [
            :SPV_QCOM_image_processing
        ]
    }
    :TextureBlockMatch2QCOM {
        :tag :TextureBlockMatch2QCOM
        :value 4498
        :extensions [
            :SPV_QCOM_image_processing2
        ]
    }
    :Float16ImageAMD {
        :tag :Float16ImageAMD
        :value 5008
        :extensions [
            :SPV_AMD_gpu_shader_half_float_fetch
        ]
        :capabilities [
            :Shader
        ]
    }
    :ImageGatherBiasLodAMD {
        :tag :ImageGatherBiasLodAMD
        :value 5009
        :extensions [
            :SPV_AMD_texture_gather_bias_lod
        ]
        :capabilities [
            :Shader
        ]
    }
    :FragmentMaskAMD {
        :tag :FragmentMaskAMD
        :value 5010
        :extensions [
            :SPV_AMD_shader_fragment_mask
        ]
        :capabilities [
            :Shader
        ]
    }
    :StencilExportEXT {
        :tag :StencilExportEXT
        :value 5013
        :extensions [
            :SPV_EXT_shader_stencil_export
        ]
        :capabilities [
            :Shader
        ]
    }
    :ImageReadWriteLodAMD {
        :tag :ImageReadWriteLodAMD
        :value 5015
        :extensions [
            :SPV_AMD_shader_image_load_store_lod
        ]
        :capabilities [
            :Shader
        ]
    }
    :Int64ImageEXT {
        :tag :Int64ImageEXT
        :value 5016
        :extensions [
            :SPV_EXT_shader_image_int64
        ]
        :capabilities [
            :Shader
        ]
    }
    :ShaderClockKHR {
        :tag :ShaderClockKHR
        :value 5055
        :extensions [
            :SPV_KHR_shader_clock
        ]
    }
    :ShaderEnqueueAMDX {
        :tag :ShaderEnqueueAMDX
        :value 5067
        :extensions [
            :SPV_AMDX_shader_enqueue
        ]
        :capabilities [
            :Shader
        ]
    }
    :QuadControlKHR {
        :tag :QuadControlKHR
        :value 5087
        :extensions [
            :SPV_KHR_quad_control
        ]
    }
    :SampleMaskOverrideCoverageNV {
        :tag :SampleMaskOverrideCoverageNV
        :value 5249
        :extensions [
            :SPV_NV_sample_mask_override_coverage
        ]
        :capabilities [
            :SampleRateShading
        ]
    }
    :GeometryShaderPassthroughNV {
        :tag :GeometryShaderPassthroughNV
        :value 5251
        :extensions [
            :SPV_NV_geometry_shader_passthrough
        ]
        :capabilities [
            :Geometry
        ]
    }
    :ShaderViewportIndexLayerEXT {
        :tag :ShaderViewportIndexLayerEXT
        :value 5254
        :extensions [
            :SPV_EXT_shader_viewport_index_layer
        ]
        :capabilities [
            :MultiViewport
        ]
    }
    :ShaderViewportMaskNV {
        :tag :ShaderViewportMaskNV
        :value 5255
        :extensions [
            :SPV_NV_viewport_array2
        ]
        :capabilities [
            :ShaderViewportIndexLayerNV
        ]
    }
    :ShaderStereoViewNV {
        :tag :ShaderStereoViewNV
        :value 5259
        :extensions [
            :SPV_NV_stereo_view_rendering
        ]
        :capabilities [
            :ShaderViewportMaskNV
        ]
    }
    :PerViewAttributesNV {
        :tag :PerViewAttributesNV
        :value 5260
        :extensions [
            :SPV_NVX_multiview_per_view_attributes
        ]
        :capabilities [
            :MultiView
        ]
    }
    :FragmentFullyCoveredEXT {
        :tag :FragmentFullyCoveredEXT
        :value 5265
        :extensions [
            :SPV_EXT_fragment_fully_covered
        ]
        :capabilities [
            :Shader
        ]
    }
    :MeshShadingNV {
        :tag :MeshShadingNV
        :value 5266
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :Shader
        ]
    }
    :ImageFootprintNV {
        :tag :ImageFootprintNV
        :value 5282
        :extensions [
            :SPV_NV_shader_image_footprint
        ]
    }
    :MeshShadingEXT {
        :tag :MeshShadingEXT
        :value 5283
        :extensions [
            :SPV_EXT_mesh_shader
        ]
        :capabilities [
            :Shader
        ]
    }
    :FragmentBarycentricKHR {
        :tag :FragmentBarycentricKHR
        :value 5284
        :extensions [
            :SPV_NV_fragment_shader_barycentric
            :SPV_KHR_fragment_shader_barycentric
        ]
    }
    :ComputeDerivativeGroupQuadsNV {
        :tag :ComputeDerivativeGroupQuadsNV
        :value 5288
        :extensions [
            :SPV_NV_compute_shader_derivatives
        ]
    }
    :FragmentDensityEXT {
        :tag :FragmentDensityEXT
        :value 5291
        :extensions [
            :SPV_EXT_fragment_invocation_density
            :SPV_NV_shading_rate
        ]
        :capabilities [
            :Shader
        ]
    }
    :GroupNonUniformPartitionedNV {
        :tag :GroupNonUniformPartitionedNV
        :value 5297
        :extensions [
            :SPV_NV_shader_subgroup_partitioned
        ]
    }
    :ShaderNonUniform {
        :tag :ShaderNonUniform
        :value 5301
        :version { :major 1 :minor 5 }
        :capabilities [
            :Shader
        ]
    }
    :RuntimeDescriptorArray {
        :tag :RuntimeDescriptorArray
        :value 5302
        :version { :major 1 :minor 5 }
        :capabilities [
            :Shader
        ]
    }
    :InputAttachmentArrayDynamicIndexing {
        :tag :InputAttachmentArrayDynamicIndexing
        :value 5303
        :version { :major 1 :minor 5 }
        :capabilities [
            :InputAttachment
        ]
    }
    :UniformTexelBufferArrayDynamicIndexing {
        :tag :UniformTexelBufferArrayDynamicIndexing
        :value 5304
        :version { :major 1 :minor 5 }
        :capabilities [
            :SampledBuffer
        ]
    }
    :StorageTexelBufferArrayDynamicIndexing {
        :tag :StorageTexelBufferArrayDynamicIndexing
        :value 5305
        :version { :major 1 :minor 5 }
        :capabilities [
            :ImageBuffer
        ]
    }
    :UniformBufferArrayNonUniformIndexing {
        :tag :UniformBufferArrayNonUniformIndexing
        :value 5306
        :version { :major 1 :minor 5 }
        :capabilities [
            :ShaderNonUniform
        ]
    }
    :SampledImageArrayNonUniformIndexing {
        :tag :SampledImageArrayNonUniformIndexing
        :value 5307
        :version { :major 1 :minor 5 }
        :capabilities [
            :ShaderNonUniform
        ]
    }
    :StorageBufferArrayNonUniformIndexing {
        :tag :StorageBufferArrayNonUniformIndexing
        :value 5308
        :version { :major 1 :minor 5 }
        :capabilities [
            :ShaderNonUniform
        ]
    }
    :StorageImageArrayNonUniformIndexing {
        :tag :StorageImageArrayNonUniformIndexing
        :value 5309
        :version { :major 1 :minor 5 }
        :capabilities [
            :ShaderNonUniform
        ]
    }
    :InputAttachmentArrayNonUniformIndexing {
        :tag :InputAttachmentArrayNonUniformIndexing
        :value 5310
        :version { :major 1 :minor 5 }
        :capabilities [
            :InputAttachment
            :ShaderNonUniform
        ]
    }
    :UniformTexelBufferArrayNonUniformIndexing {
        :tag :UniformTexelBufferArrayNonUniformIndexing
        :value 5311
        :version { :major 1 :minor 5 }
        :capabilities [
            :SampledBuffer
            :ShaderNonUniform
        ]
    }
    :StorageTexelBufferArrayNonUniformIndexing {
        :tag :StorageTexelBufferArrayNonUniformIndexing
        :value 5312
        :version { :major 1 :minor 5 }
        :capabilities [
            :ImageBuffer
            :ShaderNonUniform
        ]
    }
    :RayTracingPositionFetchKHR {
        :tag :RayTracingPositionFetchKHR
        :value 5336
        :extensions [
            :SPV_KHR_ray_tracing_position_fetch
        ]
        :capabilities [
            :Shader
        ]
    }
    :RayTracingNV {
        :tag :RayTracingNV
        :value 5340
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :Shader
        ]
    }
    :RayTracingMotionBlurNV {
        :tag :RayTracingMotionBlurNV
        :value 5341
        :extensions [
            :SPV_NV_ray_tracing_motion_blur
        ]
        :capabilities [
            :Shader
        ]
    }
    :VulkanMemoryModel {
        :tag :VulkanMemoryModel
        :value 5345
        :version { :major 1 :minor 5 }
    }
    :VulkanMemoryModelDeviceScope {
        :tag :VulkanMemoryModelDeviceScope
        :value 5346
        :version { :major 1 :minor 5 }
    }
    :PhysicalStorageBufferAddresses {
        :tag :PhysicalStorageBufferAddresses
        :value 5347
        :version { :major 1 :minor 5 }
        :extensions [
            :SPV_EXT_physical_storage_buffer
            :SPV_KHR_physical_storage_buffer
        ]
        :capabilities [
            :Shader
        ]
    }
    :ComputeDerivativeGroupLinearNV {
        :tag :ComputeDerivativeGroupLinearNV
        :value 5350
        :extensions [
            :SPV_NV_compute_shader_derivatives
        ]
    }
    :RayTracingProvisionalKHR {
        :tag :RayTracingProvisionalKHR
        :value 5353
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :Shader
        ]
    }
    :CooperativeMatrixNV {
        :tag :CooperativeMatrixNV
        :value 5357
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :Shader
        ]
    }
    :FragmentShaderSampleInterlockEXT {
        :tag :FragmentShaderSampleInterlockEXT
        :value 5363
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :Shader
        ]
    }
    :FragmentShaderShadingRateInterlockEXT {
        :tag :FragmentShaderShadingRateInterlockEXT
        :value 5372
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :Shader
        ]
    }
    :ShaderSMBuiltinsNV {
        :tag :ShaderSMBuiltinsNV
        :value 5373
        :extensions [
            :SPV_NV_shader_sm_builtins
        ]
        :capabilities [
            :Shader
        ]
    }
    :FragmentShaderPixelInterlockEXT {
        :tag :FragmentShaderPixelInterlockEXT
        :value 5378
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :Shader
        ]
    }
    :DemoteToHelperInvocation {
        :tag :DemoteToHelperInvocation
        :value 5379
        :version { :major 1 :minor 6 }
        :capabilities [
            :Shader
        ]
    }
    :DisplacementMicromapNV {
        :tag :DisplacementMicromapNV
        :value 5380
        :extensions [
            :SPV_NV_displacement_micromap
        ]
        :capabilities [
            :Shader
        ]
    }
    :RayTracingOpacityMicromapEXT {
        :tag :RayTracingOpacityMicromapEXT
        :value 5381
        :extensions [
            :SPV_EXT_opacity_micromap
        ]
        :capabilities [
            :RayQueryKHR
            :RayTracingKHR
        ]
    }
    :ShaderInvocationReorderNV {
        :tag :ShaderInvocationReorderNV
        :value 5383
        :extensions [
            :SPV_NV_shader_invocation_reorder
        ]
        :capabilities [
            :RayTracingKHR
        ]
    }
    :BindlessTextureNV {
        :tag :BindlessTextureNV
        :value 5390
        :extensions [
            :SPV_NV_bindless_texture
        ]
    }
    :RayQueryPositionFetchKHR {
        :tag :RayQueryPositionFetchKHR
        :value 5391
        :extensions [
            :SPV_KHR_ray_tracing_position_fetch
        ]
        :capabilities [
            :Shader
        ]
    }
    :AtomicFloat16VectorNV {
        :tag :AtomicFloat16VectorNV
        :value 5404
        :extensions [
            :SPV_NV_shader_atomic_fp16_vector
        ]
    }
    :RayTracingDisplacementMicromapNV {
        :tag :RayTracingDisplacementMicromapNV
        :value 5409
        :extensions [
            :SPV_NV_displacement_micromap
        ]
        :capabilities [
            :RayTracingKHR
        ]
    }
    :RawAccessChainsNV {
        :tag :RawAccessChainsNV
        :value 5414
        :extensions [
            :SPV_NV_raw_access_chains
        ]
    }
    :SubgroupShuffleINTEL {
        :tag :SubgroupShuffleINTEL
        :value 5568
        :extensions [
            :SPV_INTEL_subgroups
        ]
    }
    :SubgroupBufferBlockIOINTEL {
        :tag :SubgroupBufferBlockIOINTEL
        :value 5569
        :extensions [
            :SPV_INTEL_subgroups
        ]
    }
    :SubgroupImageBlockIOINTEL {
        :tag :SubgroupImageBlockIOINTEL
        :value 5570
        :extensions [
            :SPV_INTEL_subgroups
        ]
    }
    :SubgroupImageMediaBlockIOINTEL {
        :tag :SubgroupImageMediaBlockIOINTEL
        :value 5579
        :extensions [
            :SPV_INTEL_media_block_io
        ]
    }
    :RoundToInfinityINTEL {
        :tag :RoundToInfinityINTEL
        :value 5582
        :extensions [
            :SPV_INTEL_float_controls2
        ]
    }
    :FloatingPointModeINTEL {
        :tag :FloatingPointModeINTEL
        :value 5583
        :extensions [
            :SPV_INTEL_float_controls2
        ]
    }
    :IntegerFunctions2INTEL {
        :tag :IntegerFunctions2INTEL
        :value 5584
        :extensions [
            :SPV_INTEL_shader_integer_functions2
        ]
        :capabilities [
            :Shader
        ]
    }
    :FunctionPointersINTEL {
        :tag :FunctionPointersINTEL
        :value 5603
        :extensions [
            :SPV_INTEL_function_pointers
        ]
    }
    :IndirectReferencesINTEL {
        :tag :IndirectReferencesINTEL
        :value 5604
        :extensions [
            :SPV_INTEL_function_pointers
        ]
    }
    :AsmINTEL {
        :tag :AsmINTEL
        :value 5606
        :extensions [
            :SPV_INTEL_inline_assembly
        ]
    }
    :AtomicFloat32MinMaxEXT {
        :tag :AtomicFloat32MinMaxEXT
        :value 5612
        :extensions [
            :SPV_EXT_shader_atomic_float_min_max
        ]
    }
    :AtomicFloat64MinMaxEXT {
        :tag :AtomicFloat64MinMaxEXT
        :value 5613
        :extensions [
            :SPV_EXT_shader_atomic_float_min_max
        ]
    }
    :AtomicFloat16MinMaxEXT {
        :tag :AtomicFloat16MinMaxEXT
        :value 5616
        :extensions [
            :SPV_EXT_shader_atomic_float_min_max
        ]
    }
    :VectorComputeINTEL {
        :tag :VectorComputeINTEL
        :value 5617
        :extensions [
            :SPV_INTEL_vector_compute
        ]
        :capabilities [
            :VectorAnyINTEL
        ]
    }
    :VectorAnyINTEL {
        :tag :VectorAnyINTEL
        :value 5619
        :extensions [
            :SPV_INTEL_vector_compute
        ]
    }
    :ExpectAssumeKHR {
        :tag :ExpectAssumeKHR
        :value 5629
        :extensions [
            :SPV_KHR_expect_assume
        ]
    }
    :SubgroupAvcMotionEstimationINTEL {
        :tag :SubgroupAvcMotionEstimationINTEL
        :value 5696
        :extensions [
            :SPV_INTEL_device_side_avc_motion_estimation
        ]
    }
    :SubgroupAvcMotionEstimationIntraINTEL {
        :tag :SubgroupAvcMotionEstimationIntraINTEL
        :value 5697
        :extensions [
            :SPV_INTEL_device_side_avc_motion_estimation
        ]
    }
    :SubgroupAvcMotionEstimationChromaINTEL {
        :tag :SubgroupAvcMotionEstimationChromaINTEL
        :value 5698
        :extensions [
            :SPV_INTEL_device_side_avc_motion_estimation
        ]
    }
    :VariableLengthArrayINTEL {
        :tag :VariableLengthArrayINTEL
        :value 5817
        :extensions [
            :SPV_INTEL_variable_length_array
        ]
    }
    :FunctionFloatControlINTEL {
        :tag :FunctionFloatControlINTEL
        :value 5821
        :extensions [
            :SPV_INTEL_float_controls2
        ]
    }
    :FPGAMemoryAttributesINTEL {
        :tag :FPGAMemoryAttributesINTEL
        :value 5824
        :extensions [
            :SPV_INTEL_fpga_memory_attributes
        ]
    }
    :FPFastMathModeINTEL {
        :tag :FPFastMathModeINTEL
        :value 5837
        :extensions [
            :SPV_INTEL_fp_fast_math_mode
        ]
        :capabilities [
            :Kernel
        ]
    }
    :ArbitraryPrecisionIntegersINTEL {
        :tag :ArbitraryPrecisionIntegersINTEL
        :value 5844
        :extensions [
            :SPV_INTEL_arbitrary_precision_integers
        ]
    }
    :ArbitraryPrecisionFloatingPointINTEL {
        :tag :ArbitraryPrecisionFloatingPointINTEL
        :value 5845
        :extensions [
            :SPV_INTEL_arbitrary_precision_floating_point
        ]
    }
    :UnstructuredLoopControlsINTEL {
        :tag :UnstructuredLoopControlsINTEL
        :value 5886
        :extensions [
            :SPV_INTEL_unstructured_loop_controls
        ]
    }
    :FPGALoopControlsINTEL {
        :tag :FPGALoopControlsINTEL
        :value 5888
        :extensions [
            :SPV_INTEL_fpga_loop_controls
        ]
    }
    :KernelAttributesINTEL {
        :tag :KernelAttributesINTEL
        :value 5892
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
    }
    :FPGAKernelAttributesINTEL {
        :tag :FPGAKernelAttributesINTEL
        :value 5897
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
    }
    :FPGAMemoryAccessesINTEL {
        :tag :FPGAMemoryAccessesINTEL
        :value 5898
        :extensions [
            :SPV_INTEL_fpga_memory_accesses
        ]
    }
    :FPGAClusterAttributesINTEL {
        :tag :FPGAClusterAttributesINTEL
        :value 5904
        :extensions [
            :SPV_INTEL_fpga_cluster_attributes
        ]
    }
    :LoopFuseINTEL {
        :tag :LoopFuseINTEL
        :value 5906
        :extensions [
            :SPV_INTEL_loop_fuse
        ]
    }
    :FPGADSPControlINTEL {
        :tag :FPGADSPControlINTEL
        :value 5908
        :extensions [
            :SPV_INTEL_fpga_dsp_control
        ]
    }
    :MemoryAccessAliasingINTEL {
        :tag :MemoryAccessAliasingINTEL
        :value 5910
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
    }
    :FPGAInvocationPipeliningAttributesINTEL {
        :tag :FPGAInvocationPipeliningAttributesINTEL
        :value 5916
        :extensions [
            :SPV_INTEL_fpga_invocation_pipelining_attributes
        ]
    }
    :FPGABufferLocationINTEL {
        :tag :FPGABufferLocationINTEL
        :value 5920
        :extensions [
            :SPV_INTEL_fpga_buffer_location
        ]
    }
    :ArbitraryPrecisionFixedPointINTEL {
        :tag :ArbitraryPrecisionFixedPointINTEL
        :value 5922
        :extensions [
            :SPV_INTEL_arbitrary_precision_fixed_point
        ]
    }
    :USMStorageClassesINTEL {
        :tag :USMStorageClassesINTEL
        :value 5935
        :extensions [
            :SPV_INTEL_usm_storage_classes
        ]
    }
    :RuntimeAlignedAttributeINTEL {
        :tag :RuntimeAlignedAttributeINTEL
        :value 5939
        :extensions [
            :SPV_INTEL_runtime_aligned
        ]
    }
    :IOPipesINTEL {
        :tag :IOPipesINTEL
        :value 5943
        :extensions [
            :SPV_INTEL_io_pipes
        ]
    }
    :BlockingPipesINTEL {
        :tag :BlockingPipesINTEL
        :value 5945
        :extensions [
            :SPV_INTEL_blocking_pipes
        ]
    }
    :FPGARegINTEL {
        :tag :FPGARegINTEL
        :value 5948
        :extensions [
            :SPV_INTEL_fpga_reg
        ]
    }
    :DotProductInputAll {
        :tag :DotProductInputAll
        :value 6016
        :version { :major 1 :minor 6 }
    }
    :DotProductInput4x8Bit {
        :tag :DotProductInput4x8Bit
        :value 6017
        :version { :major 1 :minor 6 }
        :capabilities [
            :Int8
        ]
    }
    :DotProductInput4x8BitPacked {
        :tag :DotProductInput4x8BitPacked
        :value 6018
        :version { :major 1 :minor 6 }
    }
    :DotProduct {
        :tag :DotProduct
        :value 6019
        :version { :major 1 :minor 6 }
    }
    :RayCullMaskKHR {
        :tag :RayCullMaskKHR
        :value 6020
        :extensions [
            :SPV_KHR_ray_cull_mask
        ]
    }
    :CooperativeMatrixKHR {
        :tag :CooperativeMatrixKHR
        :value 6022
        :extensions [
            :SPV_KHR_cooperative_matrix
        ]
    }
    :BitInstructions {
        :tag :BitInstructions
        :value 6025
        :extensions [
            :SPV_KHR_bit_instructions
        ]
    }
    :GroupNonUniformRotateKHR {
        :tag :GroupNonUniformRotateKHR
        :value 6026
        :extensions [
            :SPV_KHR_subgroup_rotate
        ]
        :capabilities [
            :GroupNonUniform
        ]
    }
    :FloatControls2 {
        :tag :FloatControls2
        :value 6029
        :extensions [
            :SPV_KHR_float_controls2
        ]
    }
    :AtomicFloat32AddEXT {
        :tag :AtomicFloat32AddEXT
        :value 6033
        :extensions [
            :SPV_EXT_shader_atomic_float_add
        ]
    }
    :AtomicFloat64AddEXT {
        :tag :AtomicFloat64AddEXT
        :value 6034
        :extensions [
            :SPV_EXT_shader_atomic_float_add
        ]
    }
    :LongCompositesINTEL {
        :tag :LongCompositesINTEL
        :value 6089
        :extensions [
            :SPV_INTEL_long_composites
        ]
    }
    :OptNoneINTEL {
        :tag :OptNoneINTEL
        :value 6094
        :extensions [
            :SPV_INTEL_optnone
        ]
    }
    :AtomicFloat16AddEXT {
        :tag :AtomicFloat16AddEXT
        :value 6095
        :extensions [
            :SPV_EXT_shader_atomic_float16_add
        ]
    }
    :DebugInfoModuleINTEL {
        :tag :DebugInfoModuleINTEL
        :value 6114
        :extensions [
            :SPV_INTEL_debug_module
        ]
    }
    :BFloat16ConversionINTEL {
        :tag :BFloat16ConversionINTEL
        :value 6115
        :extensions [
            :SPV_INTEL_bfloat16_conversion
        ]
    }
    :SplitBarrierINTEL {
        :tag :SplitBarrierINTEL
        :value 6141
        :extensions [
            :SPV_INTEL_split_barrier
        ]
    }
    :FPGAClusterAttributesV2INTEL {
        :tag :FPGAClusterAttributesV2INTEL
        :value 6150
        :extensions [
            :SPV_INTEL_fpga_cluster_attributes
        ]
        :capabilities [
            :FPGAClusterAttributesINTEL
        ]
    }
    :FPGAKernelAttributesv2INTEL {
        :tag :FPGAKernelAttributesv2INTEL
        :value 6161
        :extensions [
            :SPV_INTEL_kernel_attributes
        ]
        :capabilities [
            :FPGAKernelAttributesINTEL
        ]
    }
    :FPMaxErrorINTEL {
        :tag :FPMaxErrorINTEL
        :value 6169
        :extensions [
            :SPV_INTEL_fp_max_error
        ]
    }
    :FPGALatencyControlINTEL {
        :tag :FPGALatencyControlINTEL
        :value 6171
        :extensions [
            :SPV_INTEL_fpga_latency_control
        ]
    }
    :FPGAArgumentInterfacesINTEL {
        :tag :FPGAArgumentInterfacesINTEL
        :value 6174
        :extensions [
            :SPV_INTEL_fpga_argument_interfaces
        ]
    }
    :GlobalVariableHostAccessINTEL {
        :tag :GlobalVariableHostAccessINTEL
        :value 6187
        :extensions [
            :SPV_INTEL_global_variable_host_access
        ]
    }
    :GlobalVariableFPGADecorationsINTEL {
        :tag :GlobalVariableFPGADecorationsINTEL
        :value 6189
        :extensions [
            :SPV_INTEL_global_variable_fpga_decorations
        ]
    }
    :GroupUniformArithmeticKHR {
        :tag :GroupUniformArithmeticKHR
        :value 6400
        :extensions [
            :SPV_KHR_uniform_group_instructions
        ]
    }
    :MaskedGatherScatterINTEL {
        :tag :MaskedGatherScatterINTEL
        :value 6427
        :extensions [
            :SPV_INTEL_masked_gather_scatter
        ]
    }
    :CacheControlsINTEL {
        :tag :CacheControlsINTEL
        :value 6441
        :extensions [
            :SPV_INTEL_cache_controls
        ]
    }
    :RegisterLimitsINTEL {
        :tag :RegisterLimitsINTEL
        :value 6460
        :extensions [
            :SPV_INTEL_maximum_registers
        ]
    }
}))

(set Capability.enumerants.StorageUniformBufferBlock16 Capability.enumerants.StorageBuffer16BitAccess)
(set Capability.enumerants.StorageUniform16 Capability.enumerants.UniformAndStorageBuffer16BitAccess)
(set Capability.enumerants.ShaderViewportIndexLayerNV Capability.enumerants.ShaderViewportIndexLayerEXT)
(set Capability.enumerants.FragmentBarycentricNV Capability.enumerants.FragmentBarycentricKHR)
(set Capability.enumerants.ShadingRateNV Capability.enumerants.FragmentDensityEXT)
(set Capability.enumerants.ShaderNonUniformEXT Capability.enumerants.ShaderNonUniform)
(set Capability.enumerants.RuntimeDescriptorArrayEXT Capability.enumerants.RuntimeDescriptorArray)
(set Capability.enumerants.InputAttachmentArrayDynamicIndexingEXT Capability.enumerants.InputAttachmentArrayDynamicIndexing)
(set Capability.enumerants.UniformTexelBufferArrayDynamicIndexingEXT Capability.enumerants.UniformTexelBufferArrayDynamicIndexing)
(set Capability.enumerants.StorageTexelBufferArrayDynamicIndexingEXT Capability.enumerants.StorageTexelBufferArrayDynamicIndexing)
(set Capability.enumerants.UniformBufferArrayNonUniformIndexingEXT Capability.enumerants.UniformBufferArrayNonUniformIndexing)
(set Capability.enumerants.SampledImageArrayNonUniformIndexingEXT Capability.enumerants.SampledImageArrayNonUniformIndexing)
(set Capability.enumerants.StorageBufferArrayNonUniformIndexingEXT Capability.enumerants.StorageBufferArrayNonUniformIndexing)
(set Capability.enumerants.StorageImageArrayNonUniformIndexingEXT Capability.enumerants.StorageImageArrayNonUniformIndexing)
(set Capability.enumerants.InputAttachmentArrayNonUniformIndexingEXT Capability.enumerants.InputAttachmentArrayNonUniformIndexing)
(set Capability.enumerants.UniformTexelBufferArrayNonUniformIndexingEXT Capability.enumerants.UniformTexelBufferArrayNonUniformIndexing)
(set Capability.enumerants.StorageTexelBufferArrayNonUniformIndexingEXT Capability.enumerants.StorageTexelBufferArrayNonUniformIndexing)
(set Capability.enumerants.VulkanMemoryModelKHR Capability.enumerants.VulkanMemoryModel)
(set Capability.enumerants.VulkanMemoryModelDeviceScopeKHR Capability.enumerants.VulkanMemoryModelDeviceScope)
(set Capability.enumerants.PhysicalStorageBufferAddressesEXT Capability.enumerants.PhysicalStorageBufferAddresses)
(set Capability.enumerants.DemoteToHelperInvocationEXT Capability.enumerants.DemoteToHelperInvocation)
(set Capability.enumerants.DotProductInputAllKHR Capability.enumerants.DotProductInputAll)
(set Capability.enumerants.DotProductInput4x8BitKHR Capability.enumerants.DotProductInput4x8Bit)
(set Capability.enumerants.DotProductInput4x8BitPackedKHR Capability.enumerants.DotProductInput4x8BitPacked)
(set Capability.enumerants.DotProductKHR Capability.enumerants.DotProduct)


(local RayQueryIntersection (mk-enum :RayQueryIntersection :value {
    :RayQueryCandidateIntersectionKHR {
        :tag :RayQueryCandidateIntersectionKHR
        :value 0
        :capabilities [
            :RayQueryKHR
        ]
    }
    :RayQueryCommittedIntersectionKHR {
        :tag :RayQueryCommittedIntersectionKHR
        :value 1
        :capabilities [
            :RayQueryKHR
        ]
    }
}))


(local RayQueryCommittedIntersectionType (mk-enum :RayQueryCommittedIntersectionType :value {
    :RayQueryCommittedIntersectionNoneKHR {
        :tag :RayQueryCommittedIntersectionNoneKHR
        :value 0
        :capabilities [
            :RayQueryKHR
        ]
    }
    :RayQueryCommittedIntersectionTriangleKHR {
        :tag :RayQueryCommittedIntersectionTriangleKHR
        :value 1
        :capabilities [
            :RayQueryKHR
        ]
    }
    :RayQueryCommittedIntersectionGeneratedKHR {
        :tag :RayQueryCommittedIntersectionGeneratedKHR
        :value 2
        :capabilities [
            :RayQueryKHR
        ]
    }
}))


(local RayQueryCandidateIntersectionType (mk-enum :RayQueryCandidateIntersectionType :value {
    :RayQueryCandidateIntersectionTriangleKHR {
        :tag :RayQueryCandidateIntersectionTriangleKHR
        :value 0
        :capabilities [
            :RayQueryKHR
        ]
    }
    :RayQueryCandidateIntersectionAABBKHR {
        :tag :RayQueryCandidateIntersectionAABBKHR
        :value 1
        :capabilities [
            :RayQueryKHR
        ]
    }
}))


(local PackedVectorFormat (mk-enum :PackedVectorFormat :value {
    :PackedVectorFormat4x8Bit {
        :tag :PackedVectorFormat4x8Bit
        :value 0
        :version { :major 1 :minor 6 }
    }
}))

(set PackedVectorFormat.enumerants.PackedVectorFormat4x8BitKHR PackedVectorFormat.enumerants.PackedVectorFormat4x8Bit)


(local CooperativeMatrixOperands (mk-enum :CooperativeMatrixOperands :bits {
    :MatrixASignedComponentsKHR {
        :tag :MatrixASignedComponentsKHR
        :value 1
    }
    :MatrixBSignedComponentsKHR {
        :tag :MatrixBSignedComponentsKHR
        :value 2
    }
    :MatrixCSignedComponentsKHR {
        :tag :MatrixCSignedComponentsKHR
        :value 4
    }
    :MatrixResultSignedComponentsKHR {
        :tag :MatrixResultSignedComponentsKHR
        :value 8
    }
    :SaturatingAccumulationKHR {
        :tag :SaturatingAccumulationKHR
        :value 16
    }
}))


(local CooperativeMatrixLayout (mk-enum :CooperativeMatrixLayout :value {
    :RowMajorKHR {
        :tag :RowMajorKHR
        :value 0
    }
    :ColumnMajorKHR {
        :tag :ColumnMajorKHR
        :value 1
    }
}))


(local CooperativeMatrixUse (mk-enum :CooperativeMatrixUse :value {
    :MatrixAKHR {
        :tag :MatrixAKHR
        :value 0
    }
    :MatrixBKHR {
        :tag :MatrixBKHR
        :value 1
    }
    :MatrixAccumulatorKHR {
        :tag :MatrixAccumulatorKHR
        :value 2
    }
}))


(local InitializationModeQualifier (mk-enum :InitializationModeQualifier :value {
    :InitOnDeviceReprogramINTEL {
        :tag :InitOnDeviceReprogramINTEL
        :value 0
        :capabilities [
            :GlobalVariableFPGADecorationsINTEL
        ]
    }
    :InitOnDeviceResetINTEL {
        :tag :InitOnDeviceResetINTEL
        :value 1
        :capabilities [
            :GlobalVariableFPGADecorationsINTEL
        ]
    }
}))


(local LoadCacheControl (mk-enum :LoadCacheControl :value {
    :UncachedINTEL {
        :tag :UncachedINTEL
        :value 0
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :CachedINTEL {
        :tag :CachedINTEL
        :value 1
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :StreamingINTEL {
        :tag :StreamingINTEL
        :value 2
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :InvalidateAfterReadINTEL {
        :tag :InvalidateAfterReadINTEL
        :value 3
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :ConstCachedINTEL {
        :tag :ConstCachedINTEL
        :value 4
        :capabilities [
            :CacheControlsINTEL
        ]
    }
}))


(local StoreCacheControl (mk-enum :StoreCacheControl :value {
    :UncachedINTEL {
        :tag :UncachedINTEL
        :value 0
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :WriteThroughINTEL {
        :tag :WriteThroughINTEL
        :value 1
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :WriteBackINTEL {
        :tag :WriteBackINTEL
        :value 2
        :capabilities [
            :CacheControlsINTEL
        ]
    }
    :StreamingINTEL {
        :tag :StreamingINTEL
        :value 3
        :capabilities [
            :CacheControlsINTEL
        ]
    }
}))


(local NamedMaximumNumberOfRegisters (mk-enum :NamedMaximumNumberOfRegisters :value {
    :AutoINTEL {
        :tag :AutoINTEL
        :value 0
        :capabilities [
            :RegisterLimitsINTEL
        ]
    }
}))


(local SpecConstantOp (mk-enum :SpecConstantOp :value {
    :OpAccessChain {
        :tag :OpAccessChain
        :value 65
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpInBoundsAccessChain {
        :tag :OpInBoundsAccessChain
        :value 66
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpPtrAccessChain {
        :tag :OpPtrAccessChain
        :value 67
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Element"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpInBoundsPtrAccessChain {
        :tag :OpInBoundsPtrAccessChain
        :value 70
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Element"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpVectorShuffle {
        :tag :OpVectorShuffle
        :value 79
        :operands [
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :LiteralInteger :quantifier :* :name "Components"}
        ]
    }
    :OpCompositeExtract {
        :tag :OpCompositeExtract
        :value 81
        :operands [
            {:kind :IdRef :name "Composite"}
            {:kind :LiteralInteger :quantifier :* :name "Indexes"}
        ]
    }
    :OpCompositeInsert {
        :tag :OpCompositeInsert
        :value 82
        :operands [
            {:kind :IdRef :name "Object"}
            {:kind :IdRef :name "Composite"}
            {:kind :LiteralInteger :quantifier :* :name "Indexes"}
        ]
    }
    :OpConvertFToU {
        :tag :OpConvertFToU
        :value 109
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpConvertFToS {
        :tag :OpConvertFToS
        :value 110
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpConvertSToF {
        :tag :OpConvertSToF
        :value 111
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Signed Value"}
        ]
    }
    :OpConvertUToF {
        :tag :OpConvertUToF
        :value 112
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Unsigned Value"}
        ]
    }
    :OpUConvert {
        :tag :OpUConvert
        :value 113
        :version { :major 1 :minor 4 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Unsigned Value"}
        ]
    }
    :OpSConvert {
        :tag :OpSConvert
        :value 114
        :operands [
            {:kind :IdRef :name "Signed Value"}
        ]
    }
    :OpFConvert {
        :tag :OpFConvert
        :value 115
        :operands [
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpQuantizeToF16 {
        :tag :OpQuantizeToF16
        :value 116
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpConvertPtrToU {
        :tag :OpConvertPtrToU
        :value 117
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpConvertUToPtr {
        :tag :OpConvertUToPtr
        :value 120
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Integer Value"}
        ]
    }
    :OpPtrCastToGeneric {
        :tag :OpPtrCastToGeneric
        :value 121
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpGenericCastToPtr {
        :tag :OpGenericCastToPtr
        :value 122
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpBitcast {
        :tag :OpBitcast
        :value 124
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpSNegate {
        :tag :OpSNegate
        :value 126
        :operands [
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpFNegate {
        :tag :OpFNegate
        :value 127
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpIAdd {
        :tag :OpIAdd
        :value 128
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFAdd {
        :tag :OpFAdd
        :value 129
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpISub {
        :tag :OpISub
        :value 130
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFSub {
        :tag :OpFSub
        :value 131
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIMul {
        :tag :OpIMul
        :value 132
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFMul {
        :tag :OpFMul
        :value 133
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUDiv {
        :tag :OpUDiv
        :value 134
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSDiv {
        :tag :OpSDiv
        :value 135
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFDiv {
        :tag :OpFDiv
        :value 136
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUMod {
        :tag :OpUMod
        :value 137
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSRem {
        :tag :OpSRem
        :value 138
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSMod {
        :tag :OpSMod
        :value 139
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFRem {
        :tag :OpFRem
        :value 140
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFMod {
        :tag :OpFMod
        :value 141
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalEqual {
        :tag :OpLogicalEqual
        :value 164
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalNotEqual {
        :tag :OpLogicalNotEqual
        :value 165
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalOr {
        :tag :OpLogicalOr
        :value 166
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalAnd {
        :tag :OpLogicalAnd
        :value 167
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalNot {
        :tag :OpLogicalNot
        :value 168
        :operands [
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpSelect {
        :tag :OpSelect
        :value 169
        :operands [
            {:kind :IdRef :name "Condition"}
            {:kind :IdRef :name "Object 1"}
            {:kind :IdRef :name "Object 2"}
        ]
    }
    :OpIEqual {
        :tag :OpIEqual
        :value 170
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpINotEqual {
        :tag :OpINotEqual
        :value 171
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUGreaterThan {
        :tag :OpUGreaterThan
        :value 172
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSGreaterThan {
        :tag :OpSGreaterThan
        :value 173
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUGreaterThanEqual {
        :tag :OpUGreaterThanEqual
        :value 174
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSGreaterThanEqual {
        :tag :OpSGreaterThanEqual
        :value 175
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpULessThan {
        :tag :OpULessThan
        :value 176
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSLessThan {
        :tag :OpSLessThan
        :value 177
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpULessThanEqual {
        :tag :OpULessThanEqual
        :value 178
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSLessThanEqual {
        :tag :OpSLessThanEqual
        :value 179
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpShiftRightLogical {
        :tag :OpShiftRightLogical
        :value 194
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpShiftRightArithmetic {
        :tag :OpShiftRightArithmetic
        :value 195
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpShiftLeftLogical {
        :tag :OpShiftLeftLogical
        :value 196
        :operands [
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpBitwiseOr {
        :tag :OpBitwiseOr
        :value 197
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpBitwiseXor {
        :tag :OpBitwiseXor
        :value 198
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpBitwiseAnd {
        :tag :OpBitwiseAnd
        :value 199
        :operands [
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpNot {
        :tag :OpNot
        :value 200
        :operands [
            {:kind :IdRef :name "Operand"}
        ]
    }
}))


(local Op (mk-enum :Op :op {
    :OpNop {
        :tag :OpNop
        :value 0
        :version { :major 1 :minor 0 }
    }
    :OpUndef {
        :tag :OpUndef
        :value 1
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSourceContinued {
        :tag :OpSourceContinued
        :value 2
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :LiteralString :name "Continued Source"}
        ]
    }
    :OpSource {
        :tag :OpSource
        :value 3
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :SourceLanguage}
            {:kind :LiteralInteger :name "Version"}
            {:kind :IdRef :quantifier :? :name "File"}
            {:kind :LiteralString :quantifier :? :name "Source"}
        ]
    }
    :OpSourceExtension {
        :tag :OpSourceExtension
        :value 4
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :LiteralString :name "Extension"}
        ]
    }
    :OpName {
        :tag :OpName
        :value 5
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :LiteralString :name "Name"}
        ]
    }
    :OpMemberName {
        :tag :OpMemberName
        :value 6
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Type"}
            {:kind :LiteralInteger :name "Member"}
            {:kind :LiteralString :name "Name"}
        ]
    }
    :OpString {
        :tag :OpString
        :value 7
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :LiteralString :name "String"}
        ]
    }
    :OpLine {
        :tag :OpLine
        :value 8
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "File"}
            {:kind :LiteralInteger :name "Line"}
            {:kind :LiteralInteger :name "Column"}
        ]
    }
    :OpExtension {
        :tag :OpExtension
        :value 10
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :LiteralString :name "Name"}
        ]
    }
    :OpExtInstImport {
        :tag :OpExtInstImport
        :value 11
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :LiteralString :name "Name"}
        ]
    }
    :OpExtInst {
        :tag :OpExtInst
        :value 12
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Set"}
            {:kind :LiteralExtInstInteger :name "Instruction"}
            {:kind :IdRef :quantifier :* :name "Operand 1, + Operand 2, + ..."}
        ]
    }
    :OpMemoryModel {
        :tag :OpMemoryModel
        :value 14
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :AddressingModel}
            {:kind :MemoryModel}
        ]
    }
    :OpEntryPoint {
        :tag :OpEntryPoint
        :value 15
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :ExecutionModel}
            {:kind :IdRef :name "Entry Point"}
            {:kind :LiteralString :name "Name"}
            {:kind :IdRef :quantifier :* :name "Interface"}
        ]
    }
    :OpExecutionMode {
        :tag :OpExecutionMode
        :value 16
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Entry Point"}
            {:kind :ExecutionMode :name "Mode"}
        ]
    }
    :OpCapability {
        :tag :OpCapability
        :value 17
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :Capability :name "Capability"}
        ]
    }
    :OpTypeVoid {
        :tag :OpTypeVoid
        :value 19
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeBool {
        :tag :OpTypeBool
        :value 20
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeInt {
        :tag :OpTypeInt
        :value 21
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :LiteralInteger :name "Width"}
            {:kind :LiteralInteger :name "Signedness"}
        ]
    }
    :OpTypeFloat {
        :tag :OpTypeFloat
        :value 22
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :LiteralInteger :name "Width"}
        ]
    }
    :OpTypeVector {
        :tag :OpTypeVector
        :value 23
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Component Type"}
            {:kind :LiteralInteger :name "Component Count"}
        ]
    }
    :OpTypeMatrix {
        :tag :OpTypeMatrix
        :value 24
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Column Type"}
            {:kind :LiteralInteger :name "Column Count"}
        ]
    }
    :OpTypeImage {
        :tag :OpTypeImage
        :value 25
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Type"}
            {:kind :Dim}
            {:kind :LiteralInteger :name "Depth"}
            {:kind :LiteralInteger :name "Arrayed"}
            {:kind :LiteralInteger :name "MS"}
            {:kind :LiteralInteger :name "Sampled"}
            {:kind :ImageFormat}
            {:kind :AccessQualifier :quantifier :?}
        ]
    }
    :OpTypeSampler {
        :tag :OpTypeSampler
        :value 26
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeSampledImage {
        :tag :OpTypeSampledImage
        :value 27
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Image Type"}
        ]
    }
    :OpTypeArray {
        :tag :OpTypeArray
        :value 28
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Element Type"}
            {:kind :IdRef :name "Length"}
        ]
    }
    :OpTypeRuntimeArray {
        :tag :OpTypeRuntimeArray
        :value 29
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Element Type"}
        ]
    }
    :OpTypeStruct {
        :tag :OpTypeStruct
        :value 30
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Member 0 type, + member 1 type, + ..."}
        ]
    }
    :OpTypeOpaque {
        :tag :OpTypeOpaque
        :value 31
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResult}
            {:kind :LiteralString :name "The name of the opaque type."}
        ]
    }
    :OpTypePointer {
        :tag :OpTypePointer
        :value 32
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :StorageClass}
            {:kind :IdRef :name "Type"}
        ]
    }
    :OpTypeFunction {
        :tag :OpTypeFunction
        :value 33
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Return Type"}
            {:kind :IdRef :quantifier :* :name "Parameter 0 Type, + Parameter 1 Type, + ..."}
        ]
    }
    :OpTypeEvent {
        :tag :OpTypeEvent
        :value 34
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeDeviceEvent {
        :tag :OpTypeDeviceEvent
        :value 35
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeReserveId {
        :tag :OpTypeReserveId
        :value 36
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeQueue {
        :tag :OpTypeQueue
        :value 37
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypePipe {
        :tag :OpTypePipe
        :value 38
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResult}
            {:kind :AccessQualifier :name "Qualifier"}
        ]
    }
    :OpTypeForwardPointer {
        :tag :OpTypeForwardPointer
        :value 39
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
            :PhysicalStorageBufferAddresses
        ]
        :operands [
            {:kind :IdRef :name "Pointer Type"}
            {:kind :StorageClass}
        ]
    }
    :OpConstantTrue {
        :tag :OpConstantTrue
        :value 41
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpConstantFalse {
        :tag :OpConstantFalse
        :value 42
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpConstant {
        :tag :OpConstant
        :value 43
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :LiteralContextDependentNumber :name "Value"}
        ]
    }
    :OpConstantComposite {
        :tag :OpConstantComposite
        :value 44
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpConstantSampler {
        :tag :OpConstantSampler
        :value 45
        :version { :major 1 :minor 0 }
        :capabilities [
            :LiteralSampler
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :SamplerAddressingMode}
            {:kind :LiteralInteger :name "Param"}
            {:kind :SamplerFilterMode}
        ]
    }
    :OpConstantNull {
        :tag :OpConstantNull
        :value 46
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSpecConstantTrue {
        :tag :OpSpecConstantTrue
        :value 48
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSpecConstantFalse {
        :tag :OpSpecConstantFalse
        :value 49
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSpecConstant {
        :tag :OpSpecConstant
        :value 50
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :LiteralContextDependentNumber :name "Value"}
        ]
    }
    :OpSpecConstantComposite {
        :tag :OpSpecConstantComposite
        :value 51
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpSpecConstantOp {
        :tag :OpSpecConstantOp
        :value 52
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :LiteralSpecConstantOpInteger :name "Opcode"}
        ]
    }
    :OpFunction {
        :tag :OpFunction
        :value 54
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :FunctionControl}
            {:kind :IdRef :name "Function Type"}
        ]
    }
    :OpFunctionParameter {
        :tag :OpFunctionParameter
        :value 55
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpFunctionEnd {
        :tag :OpFunctionEnd
        :value 56
        :version { :major 1 :minor 0 }
    }
    :OpFunctionCall {
        :tag :OpFunctionCall
        :value 57
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Function"}
            {:kind :IdRef :quantifier :* :name "Argument 0, + Argument 1, + ..."}
        ]
    }
    :OpVariable {
        :tag :OpVariable
        :value 59
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :StorageClass}
            {:kind :IdRef :quantifier :? :name "Initializer"}
        ]
    }
    :OpImageTexelPointer {
        :tag :OpImageTexelPointer
        :value 60
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Sample"}
        ]
    }
    :OpLoad {
        :tag :OpLoad
        :value 61
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpStore {
        :tag :OpStore
        :value 62
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Object"}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpCopyMemory {
        :tag :OpCopyMemory
        :value 63
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :IdRef :name "Source"}
            {:kind :MemoryAccess :quantifier :?}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpCopyMemorySized {
        :tag :OpCopyMemorySized
        :value 64
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
        ]
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :IdRef :name "Source"}
            {:kind :IdRef :name "Size"}
            {:kind :MemoryAccess :quantifier :?}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpAccessChain {
        :tag :OpAccessChain
        :value 65
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpInBoundsAccessChain {
        :tag :OpInBoundsAccessChain
        :value 66
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpPtrAccessChain {
        :tag :OpPtrAccessChain
        :value 67
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
            :VariablePointers
            :VariablePointersStorageBuffer
            :PhysicalStorageBufferAddresses
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Element"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpArrayLength {
        :tag :OpArrayLength
        :value 68
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Structure"}
            {:kind :LiteralInteger :name "Array member"}
        ]
    }
    :OpGenericPtrMemSemantics {
        :tag :OpGenericPtrMemSemantics
        :value 69
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpInBoundsPtrAccessChain {
        :tag :OpInBoundsPtrAccessChain
        :value 70
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Element"}
            {:kind :IdRef :quantifier :* :name "Indexes"}
        ]
    }
    :OpDecorate {
        :tag :OpDecorate
        :value 71
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :Decoration}
        ]
    }
    :OpMemberDecorate {
        :tag :OpMemberDecorate
        :value 72
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Structure Type"}
            {:kind :LiteralInteger :name "Member"}
            {:kind :Decoration}
        ]
    }
    :OpDecorationGroup {
        :tag :OpDecorationGroup
        :value 73
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpGroupDecorate {
        :tag :OpGroupDecorate
        :value 74
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Decoration Group"}
            {:kind :IdRef :quantifier :* :name "Targets"}
        ]
    }
    :OpGroupMemberDecorate {
        :tag :OpGroupMemberDecorate
        :value 75
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Decoration Group"}
            {:kind :PairIdRefLiteralInteger :quantifier :* :name "Targets"}
        ]
    }
    :OpVectorExtractDynamic {
        :tag :OpVectorExtractDynamic
        :value 77
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
            {:kind :IdRef :name "Index"}
        ]
    }
    :OpVectorInsertDynamic {
        :tag :OpVectorInsertDynamic
        :value 78
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
            {:kind :IdRef :name "Component"}
            {:kind :IdRef :name "Index"}
        ]
    }
    :OpVectorShuffle {
        :tag :OpVectorShuffle
        :value 79
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :LiteralInteger :quantifier :* :name "Components"}
        ]
    }
    :OpCompositeConstruct {
        :tag :OpCompositeConstruct
        :value 80
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpCompositeExtract {
        :tag :OpCompositeExtract
        :value 81
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Composite"}
            {:kind :LiteralInteger :quantifier :* :name "Indexes"}
        ]
    }
    :OpCompositeInsert {
        :tag :OpCompositeInsert
        :value 82
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Object"}
            {:kind :IdRef :name "Composite"}
            {:kind :LiteralInteger :quantifier :* :name "Indexes"}
        ]
    }
    :OpCopyObject {
        :tag :OpCopyObject
        :value 83
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpTranspose {
        :tag :OpTranspose
        :value 84
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Matrix"}
        ]
    }
    :OpSampledImage {
        :tag :OpSampledImage
        :value 86
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Sampler"}
        ]
    }
    :OpImageSampleImplicitLod {
        :tag :OpImageSampleImplicitLod
        :value 87
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSampleExplicitLod {
        :tag :OpImageSampleExplicitLod
        :value 88
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSampleDrefImplicitLod {
        :tag :OpImageSampleDrefImplicitLod
        :value 89
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSampleDrefExplicitLod {
        :tag :OpImageSampleDrefExplicitLod
        :value 90
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSampleProjImplicitLod {
        :tag :OpImageSampleProjImplicitLod
        :value 91
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSampleProjExplicitLod {
        :tag :OpImageSampleProjExplicitLod
        :value 92
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSampleProjDrefImplicitLod {
        :tag :OpImageSampleProjDrefImplicitLod
        :value 93
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSampleProjDrefExplicitLod {
        :tag :OpImageSampleProjDrefExplicitLod
        :value 94
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageFetch {
        :tag :OpImageFetch
        :value 95
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageGather {
        :tag :OpImageGather
        :value 96
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Component"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageDrefGather {
        :tag :OpImageDrefGather
        :value 97
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageRead {
        :tag :OpImageRead
        :value 98
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageWrite {
        :tag :OpImageWrite
        :value 99
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Texel"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImage {
        :tag :OpImage
        :value 100
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
        ]
    }
    :OpImageQueryFormat {
        :tag :OpImageQueryFormat
        :value 101
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
        ]
    }
    :OpImageQueryOrder {
        :tag :OpImageQueryOrder
        :value 102
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
        ]
    }
    :OpImageQuerySizeLod {
        :tag :OpImageQuerySizeLod
        :value 103
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :ImageQuery
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Level of Detail"}
        ]
    }
    :OpImageQuerySize {
        :tag :OpImageQuerySize
        :value 104
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :ImageQuery
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
        ]
    }
    :OpImageQueryLod {
        :tag :OpImageQueryLod
        :value 105
        :version { :major 1 :minor 0 }
        :capabilities [
            :ImageQuery
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
        ]
    }
    :OpImageQueryLevels {
        :tag :OpImageQueryLevels
        :value 106
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :ImageQuery
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
        ]
    }
    :OpImageQuerySamples {
        :tag :OpImageQuerySamples
        :value 107
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
            :ImageQuery
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
        ]
    }
    :OpConvertFToU {
        :tag :OpConvertFToU
        :value 109
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpConvertFToS {
        :tag :OpConvertFToS
        :value 110
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpConvertSToF {
        :tag :OpConvertSToF
        :value 111
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Signed Value"}
        ]
    }
    :OpConvertUToF {
        :tag :OpConvertUToF
        :value 112
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Unsigned Value"}
        ]
    }
    :OpUConvert {
        :tag :OpUConvert
        :value 113
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Unsigned Value"}
        ]
    }
    :OpSConvert {
        :tag :OpSConvert
        :value 114
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Signed Value"}
        ]
    }
    :OpFConvert {
        :tag :OpFConvert
        :value 115
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpQuantizeToF16 {
        :tag :OpQuantizeToF16
        :value 116
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpConvertPtrToU {
        :tag :OpConvertPtrToU
        :value 117
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
            :PhysicalStorageBufferAddresses
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpSatConvertSToU {
        :tag :OpSatConvertSToU
        :value 118
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Signed Value"}
        ]
    }
    :OpSatConvertUToS {
        :tag :OpSatConvertUToS
        :value 119
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Unsigned Value"}
        ]
    }
    :OpConvertUToPtr {
        :tag :OpConvertUToPtr
        :value 120
        :version { :major 1 :minor 0 }
        :capabilities [
            :Addresses
            :PhysicalStorageBufferAddresses
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Integer Value"}
        ]
    }
    :OpPtrCastToGeneric {
        :tag :OpPtrCastToGeneric
        :value 121
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpGenericCastToPtr {
        :tag :OpGenericCastToPtr
        :value 122
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpGenericCastToPtrExplicit {
        :tag :OpGenericCastToPtrExplicit
        :value 123
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :StorageClass :name "Storage"}
        ]
    }
    :OpBitcast {
        :tag :OpBitcast
        :value 124
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpSNegate {
        :tag :OpSNegate
        :value 126
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpFNegate {
        :tag :OpFNegate
        :value 127
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpIAdd {
        :tag :OpIAdd
        :value 128
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFAdd {
        :tag :OpFAdd
        :value 129
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpISub {
        :tag :OpISub
        :value 130
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFSub {
        :tag :OpFSub
        :value 131
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIMul {
        :tag :OpIMul
        :value 132
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFMul {
        :tag :OpFMul
        :value 133
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUDiv {
        :tag :OpUDiv
        :value 134
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSDiv {
        :tag :OpSDiv
        :value 135
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFDiv {
        :tag :OpFDiv
        :value 136
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUMod {
        :tag :OpUMod
        :value 137
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSRem {
        :tag :OpSRem
        :value 138
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSMod {
        :tag :OpSMod
        :value 139
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFRem {
        :tag :OpFRem
        :value 140
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFMod {
        :tag :OpFMod
        :value 141
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpVectorTimesScalar {
        :tag :OpVectorTimesScalar
        :value 142
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
            {:kind :IdRef :name "Scalar"}
        ]
    }
    :OpMatrixTimesScalar {
        :tag :OpMatrixTimesScalar
        :value 143
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Matrix"}
            {:kind :IdRef :name "Scalar"}
        ]
    }
    :OpVectorTimesMatrix {
        :tag :OpVectorTimesMatrix
        :value 144
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
            {:kind :IdRef :name "Matrix"}
        ]
    }
    :OpMatrixTimesVector {
        :tag :OpMatrixTimesVector
        :value 145
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Matrix"}
            {:kind :IdRef :name "Vector"}
        ]
    }
    :OpMatrixTimesMatrix {
        :tag :OpMatrixTimesMatrix
        :value 146
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "LeftMatrix"}
            {:kind :IdRef :name "RightMatrix"}
        ]
    }
    :OpOuterProduct {
        :tag :OpOuterProduct
        :value 147
        :version { :major 1 :minor 0 }
        :capabilities [
            :Matrix
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
        ]
    }
    :OpDot {
        :tag :OpDot
        :value 148
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
        ]
    }
    :OpIAddCarry {
        :tag :OpIAddCarry
        :value 149
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpISubBorrow {
        :tag :OpISubBorrow
        :value 150
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUMulExtended {
        :tag :OpUMulExtended
        :value 151
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSMulExtended {
        :tag :OpSMulExtended
        :value 152
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpAny {
        :tag :OpAny
        :value 154
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
        ]
    }
    :OpAll {
        :tag :OpAll
        :value 155
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector"}
        ]
    }
    :OpIsNan {
        :tag :OpIsNan
        :value 156
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
        ]
    }
    :OpIsInf {
        :tag :OpIsInf
        :value 157
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
        ]
    }
    :OpIsFinite {
        :tag :OpIsFinite
        :value 158
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
        ]
    }
    :OpIsNormal {
        :tag :OpIsNormal
        :value 159
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
        ]
    }
    :OpSignBitSet {
        :tag :OpSignBitSet
        :value 160
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
        ]
    }
    :OpLessOrGreater {
        :tag :OpLessOrGreater
        :value 161
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :OpOrdered {
        :tag :OpOrdered
        :value 162
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :OpUnordered {
        :tag :OpUnordered
        :value 163
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :OpLogicalEqual {
        :tag :OpLogicalEqual
        :value 164
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalNotEqual {
        :tag :OpLogicalNotEqual
        :value 165
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalOr {
        :tag :OpLogicalOr
        :value 166
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalAnd {
        :tag :OpLogicalAnd
        :value 167
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpLogicalNot {
        :tag :OpLogicalNot
        :value 168
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpSelect {
        :tag :OpSelect
        :value 169
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Condition"}
            {:kind :IdRef :name "Object 1"}
            {:kind :IdRef :name "Object 2"}
        ]
    }
    :OpIEqual {
        :tag :OpIEqual
        :value 170
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpINotEqual {
        :tag :OpINotEqual
        :value 171
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUGreaterThan {
        :tag :OpUGreaterThan
        :value 172
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSGreaterThan {
        :tag :OpSGreaterThan
        :value 173
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUGreaterThanEqual {
        :tag :OpUGreaterThanEqual
        :value 174
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSGreaterThanEqual {
        :tag :OpSGreaterThanEqual
        :value 175
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpULessThan {
        :tag :OpULessThan
        :value 176
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSLessThan {
        :tag :OpSLessThan
        :value 177
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpULessThanEqual {
        :tag :OpULessThanEqual
        :value 178
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpSLessThanEqual {
        :tag :OpSLessThanEqual
        :value 179
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdEqual {
        :tag :OpFOrdEqual
        :value 180
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordEqual {
        :tag :OpFUnordEqual
        :value 181
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdNotEqual {
        :tag :OpFOrdNotEqual
        :value 182
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordNotEqual {
        :tag :OpFUnordNotEqual
        :value 183
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdLessThan {
        :tag :OpFOrdLessThan
        :value 184
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordLessThan {
        :tag :OpFUnordLessThan
        :value 185
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdGreaterThan {
        :tag :OpFOrdGreaterThan
        :value 186
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordGreaterThan {
        :tag :OpFUnordGreaterThan
        :value 187
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdLessThanEqual {
        :tag :OpFOrdLessThanEqual
        :value 188
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordLessThanEqual {
        :tag :OpFUnordLessThanEqual
        :value 189
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFOrdGreaterThanEqual {
        :tag :OpFOrdGreaterThanEqual
        :value 190
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpFUnordGreaterThanEqual {
        :tag :OpFUnordGreaterThanEqual
        :value 191
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpShiftRightLogical {
        :tag :OpShiftRightLogical
        :value 194
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpShiftRightArithmetic {
        :tag :OpShiftRightArithmetic
        :value 195
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpShiftLeftLogical {
        :tag :OpShiftLeftLogical
        :value 196
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Shift"}
        ]
    }
    :OpBitwiseOr {
        :tag :OpBitwiseOr
        :value 197
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpBitwiseXor {
        :tag :OpBitwiseXor
        :value 198
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpBitwiseAnd {
        :tag :OpBitwiseAnd
        :value 199
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpNot {
        :tag :OpNot
        :value 200
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpBitFieldInsert {
        :tag :OpBitFieldInsert
        :value 201
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :BitInstructions
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Insert"}
            {:kind :IdRef :name "Offset"}
            {:kind :IdRef :name "Count"}
        ]
    }
    :OpBitFieldSExtract {
        :tag :OpBitFieldSExtract
        :value 202
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :BitInstructions
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Offset"}
            {:kind :IdRef :name "Count"}
        ]
    }
    :OpBitFieldUExtract {
        :tag :OpBitFieldUExtract
        :value 203
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :BitInstructions
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Offset"}
            {:kind :IdRef :name "Count"}
        ]
    }
    :OpBitReverse {
        :tag :OpBitReverse
        :value 204
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
            :BitInstructions
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
        ]
    }
    :OpBitCount {
        :tag :OpBitCount
        :value 205
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
        ]
    }
    :OpDPdx {
        :tag :OpDPdx
        :value 207
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpDPdy {
        :tag :OpDPdy
        :value 208
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpFwidth {
        :tag :OpFwidth
        :value 209
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpDPdxFine {
        :tag :OpDPdxFine
        :value 210
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpDPdyFine {
        :tag :OpDPdyFine
        :value 211
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpFwidthFine {
        :tag :OpFwidthFine
        :value 212
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpDPdxCoarse {
        :tag :OpDPdxCoarse
        :value 213
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpDPdyCoarse {
        :tag :OpDPdyCoarse
        :value 214
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpFwidthCoarse {
        :tag :OpFwidthCoarse
        :value 215
        :version { :major 1 :minor 0 }
        :capabilities [
            :DerivativeControl
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "P"}
        ]
    }
    :OpEmitVertex {
        :tag :OpEmitVertex
        :value 218
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :OpEndPrimitive {
        :tag :OpEndPrimitive
        :value 219
        :version { :major 1 :minor 0 }
        :capabilities [
            :Geometry
        ]
    }
    :OpEmitStreamVertex {
        :tag :OpEmitStreamVertex
        :value 220
        :version { :major 1 :minor 0 }
        :capabilities [
            :GeometryStreams
        ]
        :operands [
            {:kind :IdRef :name "Stream"}
        ]
    }
    :OpEndStreamPrimitive {
        :tag :OpEndStreamPrimitive
        :value 221
        :version { :major 1 :minor 0 }
        :capabilities [
            :GeometryStreams
        ]
        :operands [
            {:kind :IdRef :name "Stream"}
        ]
    }
    :OpControlBarrier {
        :tag :OpControlBarrier
        :value 224
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpMemoryBarrier {
        :tag :OpMemoryBarrier
        :value 225
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpAtomicLoad {
        :tag :OpAtomicLoad
        :value 227
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpAtomicStore {
        :tag :OpAtomicStore
        :value 228
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicExchange {
        :tag :OpAtomicExchange
        :value 229
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicCompareExchange {
        :tag :OpAtomicCompareExchange
        :value 230
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Equal"}
            {:kind :IdMemorySemantics :name "Unequal"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Comparator"}
        ]
    }
    :OpAtomicCompareExchangeWeak {
        :tag :OpAtomicCompareExchangeWeak
        :value 231
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Equal"}
            {:kind :IdMemorySemantics :name "Unequal"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Comparator"}
        ]
    }
    :OpAtomicIIncrement {
        :tag :OpAtomicIIncrement
        :value 232
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpAtomicIDecrement {
        :tag :OpAtomicIDecrement
        :value 233
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpAtomicIAdd {
        :tag :OpAtomicIAdd
        :value 234
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicISub {
        :tag :OpAtomicISub
        :value 235
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicSMin {
        :tag :OpAtomicSMin
        :value 236
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicUMin {
        :tag :OpAtomicUMin
        :value 237
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicSMax {
        :tag :OpAtomicSMax
        :value 238
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicUMax {
        :tag :OpAtomicUMax
        :value 239
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicAnd {
        :tag :OpAtomicAnd
        :value 240
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicOr {
        :tag :OpAtomicOr
        :value 241
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicXor {
        :tag :OpAtomicXor
        :value 242
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpPhi {
        :tag :OpPhi
        :value 245
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :PairIdRefIdRef :quantifier :* :name "Variable, Parent, ..."}
        ]
    }
    :OpLoopMerge {
        :tag :OpLoopMerge
        :value 246
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Merge Block"}
            {:kind :IdRef :name "Continue Target"}
            {:kind :LoopControl}
        ]
    }
    :OpSelectionMerge {
        :tag :OpSelectionMerge
        :value 247
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Merge Block"}
            {:kind :SelectionControl}
        ]
    }
    :OpLabel {
        :tag :OpLabel
        :value 248
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpBranch {
        :tag :OpBranch
        :value 249
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Target Label"}
        ]
    }
    :OpBranchConditional {
        :tag :OpBranchConditional
        :value 250
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Condition"}
            {:kind :IdRef :name "True Label"}
            {:kind :IdRef :name "False Label"}
            {:kind :LiteralInteger :quantifier :* :name "Branch weights"}
        ]
    }
    :OpSwitch {
        :tag :OpSwitch
        :value 251
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Selector"}
            {:kind :IdRef :name "Default"}
            {:kind :PairLiteralIntegerIdRef :quantifier :* :name "Target"}
        ]
    }
    :OpKill {
        :tag :OpKill
        :value 252
        :version { :major 1 :minor 0 }
        :capabilities [
            :Shader
        ]
    }
    :OpReturn {
        :tag :OpReturn
        :value 253
        :version { :major 1 :minor 0 }
    }
    :OpReturnValue {
        :tag :OpReturnValue
        :value 254
        :version { :major 1 :minor 0 }
        :operands [
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpUnreachable {
        :tag :OpUnreachable
        :value 255
        :version { :major 1 :minor 0 }
    }
    :OpLifetimeStart {
        :tag :OpLifetimeStart
        :value 256
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :LiteralInteger :name "Size"}
        ]
    }
    :OpLifetimeStop {
        :tag :OpLifetimeStop
        :value 257
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :LiteralInteger :name "Size"}
        ]
    }
    :OpGroupAsyncCopy {
        :tag :OpGroupAsyncCopy
        :value 259
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Destination"}
            {:kind :IdRef :name "Source"}
            {:kind :IdRef :name "Num Elements"}
            {:kind :IdRef :name "Stride"}
            {:kind :IdRef :name "Event"}
        ]
    }
    :OpGroupWaitEvents {
        :tag :OpGroupWaitEvents
        :value 260
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Num Events"}
            {:kind :IdRef :name "Events List"}
        ]
    }
    :OpGroupAll {
        :tag :OpGroupAll
        :value 261
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupAny {
        :tag :OpGroupAny
        :value 262
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupBroadcast {
        :tag :OpGroupBroadcast
        :value 263
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "LocalId"}
        ]
    }
    :OpGroupIAdd {
        :tag :OpGroupIAdd
        :value 264
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFAdd {
        :tag :OpGroupFAdd
        :value 265
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFMin {
        :tag :OpGroupFMin
        :value 266
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupUMin {
        :tag :OpGroupUMin
        :value 267
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupSMin {
        :tag :OpGroupSMin
        :value 268
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFMax {
        :tag :OpGroupFMax
        :value 269
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupUMax {
        :tag :OpGroupUMax
        :value 270
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupSMax {
        :tag :OpGroupSMax
        :value 271
        :version { :major 1 :minor 0 }
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpReadPipe {
        :tag :OpReadPipe
        :value 274
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpWritePipe {
        :tag :OpWritePipe
        :value 275
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpReservedReadPipe {
        :tag :OpReservedReadPipe
        :value 276
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Index"}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpReservedWritePipe {
        :tag :OpReservedWritePipe
        :value 277
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Index"}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpReserveReadPipePackets {
        :tag :OpReserveReadPipePackets
        :value 278
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Num Packets"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpReserveWritePipePackets {
        :tag :OpReserveWritePipePackets
        :value 279
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Num Packets"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpCommitReadPipe {
        :tag :OpCommitReadPipe
        :value 280
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpCommitWritePipe {
        :tag :OpCommitWritePipe
        :value 281
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpIsValidReserveId {
        :tag :OpIsValidReserveId
        :value 282
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Reserve Id"}
        ]
    }
    :OpGetNumPipePackets {
        :tag :OpGetNumPipePackets
        :value 283
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpGetMaxPipePackets {
        :tag :OpGetMaxPipePackets
        :value 284
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpGroupReserveReadPipePackets {
        :tag :OpGroupReserveReadPipePackets
        :value 285
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Num Packets"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpGroupReserveWritePipePackets {
        :tag :OpGroupReserveWritePipePackets
        :value 286
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Num Packets"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpGroupCommitReadPipe {
        :tag :OpGroupCommitReadPipe
        :value 287
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpGroupCommitWritePipe {
        :tag :OpGroupCommitWritePipe
        :value 288
        :version { :major 1 :minor 0 }
        :capabilities [
            :Pipes
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Pipe"}
            {:kind :IdRef :name "Reserve Id"}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpEnqueueMarker {
        :tag :OpEnqueueMarker
        :value 291
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Queue"}
            {:kind :IdRef :name "Num Events"}
            {:kind :IdRef :name "Wait Events"}
            {:kind :IdRef :name "Ret Event"}
        ]
    }
    :OpEnqueueKernel {
        :tag :OpEnqueueKernel
        :value 292
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Queue"}
            {:kind :IdRef :name "Flags"}
            {:kind :IdRef :name "ND Range"}
            {:kind :IdRef :name "Num Events"}
            {:kind :IdRef :name "Wait Events"}
            {:kind :IdRef :name "Ret Event"}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
            {:kind :IdRef :quantifier :* :name "Local Size"}
        ]
    }
    :OpGetKernelNDrangeSubGroupCount {
        :tag :OpGetKernelNDrangeSubGroupCount
        :value 293
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "ND Range"}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpGetKernelNDrangeMaxSubGroupSize {
        :tag :OpGetKernelNDrangeMaxSubGroupSize
        :value 294
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "ND Range"}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpGetKernelWorkGroupSize {
        :tag :OpGetKernelWorkGroupSize
        :value 295
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpGetKernelPreferredWorkGroupSizeMultiple {
        :tag :OpGetKernelPreferredWorkGroupSizeMultiple
        :value 296
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpRetainEvent {
        :tag :OpRetainEvent
        :value 297
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdRef :name "Event"}
        ]
    }
    :OpReleaseEvent {
        :tag :OpReleaseEvent
        :value 298
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdRef :name "Event"}
        ]
    }
    :OpCreateUserEvent {
        :tag :OpCreateUserEvent
        :value 299
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpIsValidEvent {
        :tag :OpIsValidEvent
        :value 300
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Event"}
        ]
    }
    :OpSetUserEventStatus {
        :tag :OpSetUserEventStatus
        :value 301
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdRef :name "Event"}
            {:kind :IdRef :name "Status"}
        ]
    }
    :OpCaptureEventProfilingInfo {
        :tag :OpCaptureEventProfilingInfo
        :value 302
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdRef :name "Event"}
            {:kind :IdRef :name "Profiling Info"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGetDefaultQueue {
        :tag :OpGetDefaultQueue
        :value 303
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpBuildNDRange {
        :tag :OpBuildNDRange
        :value 304
        :version { :major 1 :minor 0 }
        :capabilities [
            :DeviceEnqueue
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "GlobalWorkSize"}
            {:kind :IdRef :name "LocalWorkSize"}
            {:kind :IdRef :name "GlobalWorkOffset"}
        ]
    }
    :OpImageSparseSampleImplicitLod {
        :tag :OpImageSparseSampleImplicitLod
        :value 305
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseSampleExplicitLod {
        :tag :OpImageSparseSampleExplicitLod
        :value 306
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSparseSampleDrefImplicitLod {
        :tag :OpImageSparseSampleDrefImplicitLod
        :value 307
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseSampleDrefExplicitLod {
        :tag :OpImageSparseSampleDrefExplicitLod
        :value 308
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSparseSampleProjImplicitLod {
        :tag :OpImageSparseSampleProjImplicitLod
        :value 309
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseSampleProjExplicitLod {
        :tag :OpImageSparseSampleProjExplicitLod
        :value 310
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSparseSampleProjDrefImplicitLod {
        :tag :OpImageSparseSampleProjDrefImplicitLod
        :value 311
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseSampleProjDrefExplicitLod {
        :tag :OpImageSparseSampleProjDrefExplicitLod
        :value 312
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands}
        ]
    }
    :OpImageSparseFetch {
        :tag :OpImageSparseFetch
        :value 313
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseGather {
        :tag :OpImageSparseGather
        :value 314
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Component"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseDrefGather {
        :tag :OpImageSparseDrefGather
        :value 315
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "D~ref~"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpImageSparseTexelsResident {
        :tag :OpImageSparseTexelsResident
        :value 316
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Resident Code"}
        ]
    }
    :OpNoLine {
        :tag :OpNoLine
        :value 317
        :version { :major 1 :minor 0 }
    }
    :OpAtomicFlagTestAndSet {
        :tag :OpAtomicFlagTestAndSet
        :value 318
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpAtomicFlagClear {
        :tag :OpAtomicFlagClear
        :value 319
        :version { :major 1 :minor 0 }
        :capabilities [
            :Kernel
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpImageSparseRead {
        :tag :OpImageSparseRead
        :value 320
        :version { :major 1 :minor 0 }
        :capabilities [
            :SparseResidency
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpSizeOf {
        :tag :OpSizeOf
        :value 321
        :version { :major 1 :minor 1 }
        :capabilities [
            :Addresses
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpTypePipeStorage {
        :tag :OpTypePipeStorage
        :value 322
        :version { :major 1 :minor 1 }
        :capabilities [
            :PipeStorage
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpConstantPipeStorage {
        :tag :OpConstantPipeStorage
        :value 323
        :version { :major 1 :minor 1 }
        :capabilities [
            :PipeStorage
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :LiteralInteger :name "Packet Size"}
            {:kind :LiteralInteger :name "Packet Alignment"}
            {:kind :LiteralInteger :name "Capacity"}
        ]
    }
    :OpCreatePipeFromPipeStorage {
        :tag :OpCreatePipeFromPipeStorage
        :value 324
        :version { :major 1 :minor 1 }
        :capabilities [
            :PipeStorage
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pipe Storage"}
        ]
    }
    :OpGetKernelLocalSizeForSubgroupCount {
        :tag :OpGetKernelLocalSizeForSubgroupCount
        :value 325
        :version { :major 1 :minor 1 }
        :capabilities [
            :SubgroupDispatch
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Subgroup Count"}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpGetKernelMaxNumSubgroups {
        :tag :OpGetKernelMaxNumSubgroups
        :value 326
        :version { :major 1 :minor 1 }
        :capabilities [
            :SubgroupDispatch
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Invoke"}
            {:kind :IdRef :name "Param"}
            {:kind :IdRef :name "Param Size"}
            {:kind :IdRef :name "Param Align"}
        ]
    }
    :OpTypeNamedBarrier {
        :tag :OpTypeNamedBarrier
        :value 327
        :version { :major 1 :minor 1 }
        :capabilities [
            :NamedBarrier
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpNamedBarrierInitialize {
        :tag :OpNamedBarrierInitialize
        :value 328
        :version { :major 1 :minor 1 }
        :capabilities [
            :NamedBarrier
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Subgroup Count"}
        ]
    }
    :OpMemoryNamedBarrier {
        :tag :OpMemoryNamedBarrier
        :value 329
        :version { :major 1 :minor 1 }
        :capabilities [
            :NamedBarrier
        ]
        :operands [
            {:kind :IdRef :name "Named Barrier"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpModuleProcessed {
        :tag :OpModuleProcessed
        :value 330
        :version { :major 1 :minor 1 }
        :operands [
            {:kind :LiteralString :name "Process"}
        ]
    }
    :OpExecutionModeId {
        :tag :OpExecutionModeId
        :value 331
        :version { :major 1 :minor 2 }
        :operands [
            {:kind :IdRef :name "Entry Point"}
            {:kind :ExecutionMode :name "Mode"}
        ]
    }
    :OpDecorateId {
        :tag :OpDecorateId
        :value 332
        :version { :major 1 :minor 2 }
        :extensions [
            :SPV_GOOGLE_hlsl_functionality1
        ]
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :Decoration}
        ]
    }
    :OpGroupNonUniformElect {
        :tag :OpGroupNonUniformElect
        :value 333
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniform
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
        ]
    }
    :OpGroupNonUniformAll {
        :tag :OpGroupNonUniformAll
        :value 334
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformVote
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupNonUniformAny {
        :tag :OpGroupNonUniformAny
        :value 335
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformVote
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupNonUniformAllEqual {
        :tag :OpGroupNonUniformAllEqual
        :value 336
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformVote
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformBroadcast {
        :tag :OpGroupNonUniformBroadcast
        :value 337
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Id"}
        ]
    }
    :OpGroupNonUniformBroadcastFirst {
        :tag :OpGroupNonUniformBroadcastFirst
        :value 338
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformBallot {
        :tag :OpGroupNonUniformBallot
        :value 339
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupNonUniformInverseBallot {
        :tag :OpGroupNonUniformInverseBallot
        :value 340
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformBallotBitExtract {
        :tag :OpGroupNonUniformBallotBitExtract
        :value 341
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Index"}
        ]
    }
    :OpGroupNonUniformBallotBitCount {
        :tag :OpGroupNonUniformBallotBitCount
        :value 342
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformBallotFindLSB {
        :tag :OpGroupNonUniformBallotFindLSB
        :value 343
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformBallotFindMSB {
        :tag :OpGroupNonUniformBallotFindMSB
        :value 344
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformBallot
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpGroupNonUniformShuffle {
        :tag :OpGroupNonUniformShuffle
        :value 345
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformShuffle
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Id"}
        ]
    }
    :OpGroupNonUniformShuffleXor {
        :tag :OpGroupNonUniformShuffleXor
        :value 346
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformShuffle
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Mask"}
        ]
    }
    :OpGroupNonUniformShuffleUp {
        :tag :OpGroupNonUniformShuffleUp
        :value 347
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformShuffleRelative
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Delta"}
        ]
    }
    :OpGroupNonUniformShuffleDown {
        :tag :OpGroupNonUniformShuffleDown
        :value 348
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformShuffleRelative
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Delta"}
        ]
    }
    :OpGroupNonUniformIAdd {
        :tag :OpGroupNonUniformIAdd
        :value 349
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformFAdd {
        :tag :OpGroupNonUniformFAdd
        :value 350
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformIMul {
        :tag :OpGroupNonUniformIMul
        :value 351
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformFMul {
        :tag :OpGroupNonUniformFMul
        :value 352
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformSMin {
        :tag :OpGroupNonUniformSMin
        :value 353
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformUMin {
        :tag :OpGroupNonUniformUMin
        :value 354
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformFMin {
        :tag :OpGroupNonUniformFMin
        :value 355
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformSMax {
        :tag :OpGroupNonUniformSMax
        :value 356
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformUMax {
        :tag :OpGroupNonUniformUMax
        :value 357
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformFMax {
        :tag :OpGroupNonUniformFMax
        :value 358
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformBitwiseAnd {
        :tag :OpGroupNonUniformBitwiseAnd
        :value 359
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformBitwiseOr {
        :tag :OpGroupNonUniformBitwiseOr
        :value 360
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformBitwiseXor {
        :tag :OpGroupNonUniformBitwiseXor
        :value 361
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformLogicalAnd {
        :tag :OpGroupNonUniformLogicalAnd
        :value 362
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformLogicalOr {
        :tag :OpGroupNonUniformLogicalOr
        :value 363
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformLogicalXor {
        :tag :OpGroupNonUniformLogicalXor
        :value 364
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformArithmetic
            :GroupNonUniformClustered
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpGroupNonUniformQuadBroadcast {
        :tag :OpGroupNonUniformQuadBroadcast
        :value 365
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformQuad
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Index"}
        ]
    }
    :OpGroupNonUniformQuadSwap {
        :tag :OpGroupNonUniformQuadSwap
        :value 366
        :version { :major 1 :minor 3 }
        :capabilities [
            :GroupNonUniformQuad
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Direction"}
        ]
    }
    :OpCopyLogical {
        :tag :OpCopyLogical
        :value 400
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpPtrEqual {
        :tag :OpPtrEqual
        :value 401
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpPtrNotEqual {
        :tag :OpPtrNotEqual
        :value 402
        :version { :major 1 :minor 4 }
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpPtrDiff {
        :tag :OpPtrDiff
        :value 403
        :version { :major 1 :minor 4 }
        :capabilities [
            :Addresses
            :VariablePointers
            :VariablePointersStorageBuffer
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpColorAttachmentReadEXT {
        :tag :OpColorAttachmentReadEXT
        :value 4160
        :capabilities [
            :TileImageColorReadAccessEXT
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Attachment"}
            {:kind :IdRef :quantifier :? :name "Sample"}
        ]
    }
    :OpDepthAttachmentReadEXT {
        :tag :OpDepthAttachmentReadEXT
        :value 4161
        :capabilities [
            :TileImageDepthReadAccessEXT
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :? :name "Sample"}
        ]
    }
    :OpStencilAttachmentReadEXT {
        :tag :OpStencilAttachmentReadEXT
        :value 4162
        :capabilities [
            :TileImageStencilReadAccessEXT
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :? :name "Sample"}
        ]
    }
    :OpTerminateInvocation {
        :tag :OpTerminateInvocation
        :value 4416
        :version { :major 1 :minor 6 }
        :extensions [
            :SPV_KHR_terminate_invocation
        ]
        :capabilities [
            :Shader
        ]
    }
    :OpSubgroupBallotKHR {
        :tag :OpSubgroupBallotKHR
        :value 4421
        :extensions [
            :SPV_KHR_shader_ballot
        ]
        :capabilities [
            :SubgroupBallotKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpSubgroupFirstInvocationKHR {
        :tag :OpSubgroupFirstInvocationKHR
        :value 4422
        :extensions [
            :SPV_KHR_shader_ballot
        ]
        :capabilities [
            :SubgroupBallotKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpSubgroupAllKHR {
        :tag :OpSubgroupAllKHR
        :value 4428
        :extensions [
            :SPV_KHR_subgroup_vote
        ]
        :capabilities [
            :SubgroupVoteKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpSubgroupAnyKHR {
        :tag :OpSubgroupAnyKHR
        :value 4429
        :extensions [
            :SPV_KHR_subgroup_vote
        ]
        :capabilities [
            :SubgroupVoteKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpSubgroupAllEqualKHR {
        :tag :OpSubgroupAllEqualKHR
        :value 4430
        :extensions [
            :SPV_KHR_subgroup_vote
        ]
        :capabilities [
            :SubgroupVoteKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupNonUniformRotateKHR {
        :tag :OpGroupNonUniformRotateKHR
        :value 4431
        :capabilities [
            :GroupNonUniformRotateKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Delta"}
            {:kind :IdRef :quantifier :? :name "ClusterSize"}
        ]
    }
    :OpSubgroupReadInvocationKHR {
        :tag :OpSubgroupReadInvocationKHR
        :value 4432
        :extensions [
            :SPV_KHR_shader_ballot
        ]
        :capabilities [
            :SubgroupBallotKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "Index"}
        ]
    }
    :OpTraceRayKHR {
        :tag :OpTraceRayKHR
        :value 4445
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingKHR
        ]
        :operands [
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Ray Flags"}
            {:kind :IdRef :name "Cull Mask"}
            {:kind :IdRef :name "SBT Offset"}
            {:kind :IdRef :name "SBT Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Ray Origin"}
            {:kind :IdRef :name "Ray Tmin"}
            {:kind :IdRef :name "Ray Direction"}
            {:kind :IdRef :name "Ray Tmax"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpExecuteCallableKHR {
        :tag :OpExecuteCallableKHR
        :value 4446
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingKHR
        ]
        :operands [
            {:kind :IdRef :name "SBT Index"}
            {:kind :IdRef :name "Callable Data"}
        ]
    }
    :OpConvertUToAccelerationStructureKHR {
        :tag :OpConvertUToAccelerationStructureKHR
        :value 4447
        :extensions [
            :SPV_KHR_ray_tracing
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayTracingKHR
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Accel"}
        ]
    }
    :OpIgnoreIntersectionKHR {
        :tag :OpIgnoreIntersectionKHR
        :value 4448
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingKHR
        ]
    }
    :OpTerminateRayKHR {
        :tag :OpTerminateRayKHR
        :value 4449
        :extensions [
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingKHR
        ]
    }
    :OpSDot {
        :tag :OpSDot
        :value 4450
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpUDot {
        :tag :OpUDot
        :value 4451
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpSUDot {
        :tag :OpSUDot
        :value 4452
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpSDotAccSat {
        :tag :OpSDotAccSat
        :value 4453
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :IdRef :name "Accumulator"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpUDotAccSat {
        :tag :OpUDotAccSat
        :value 4454
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :IdRef :name "Accumulator"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpSUDotAccSat {
        :tag :OpSUDotAccSat
        :value 4455
        :version { :major 1 :minor 6 }
        :capabilities [
            :DotProduct
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Vector 1"}
            {:kind :IdRef :name "Vector 2"}
            {:kind :IdRef :name "Accumulator"}
            {:kind :PackedVectorFormat :quantifier :? :name "Packed Vector Format"}
        ]
    }
    :OpTypeCooperativeMatrixKHR {
        :tag :OpTypeCooperativeMatrixKHR
        :value 4456
        :capabilities [
            :CooperativeMatrixKHR
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Component Type"}
            {:kind :IdScope :name "Scope"}
            {:kind :IdRef :name "Rows"}
            {:kind :IdRef :name "Columns"}
            {:kind :IdRef :name "Use"}
        ]
    }
    :OpCooperativeMatrixLoadKHR {
        :tag :OpCooperativeMatrixLoadKHR
        :value 4457
        :capabilities [
            :CooperativeMatrixKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "MemoryLayout"}
            {:kind :IdRef :quantifier :? :name "Stride"}
            {:kind :MemoryAccess :quantifier :? :name "Memory Operand"}
        ]
    }
    :OpCooperativeMatrixStoreKHR {
        :tag :OpCooperativeMatrixStoreKHR
        :value 4458
        :capabilities [
            :CooperativeMatrixKHR
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Object"}
            {:kind :IdRef :name "MemoryLayout"}
            {:kind :IdRef :quantifier :? :name "Stride"}
            {:kind :MemoryAccess :quantifier :? :name "Memory Operand"}
        ]
    }
    :OpCooperativeMatrixMulAddKHR {
        :tag :OpCooperativeMatrixMulAddKHR
        :value 4459
        :capabilities [
            :CooperativeMatrixKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :IdRef :name "B"}
            {:kind :IdRef :name "C"}
            {:kind :CooperativeMatrixOperands :quantifier :? :name "Cooperative Matrix Operands"}
        ]
    }
    :OpCooperativeMatrixLengthKHR {
        :tag :OpCooperativeMatrixLengthKHR
        :value 4460
        :capabilities [
            :CooperativeMatrixKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Type"}
        ]
    }
    :OpTypeRayQueryKHR {
        :tag :OpTypeRayQueryKHR
        :value 4472
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpRayQueryInitializeKHR {
        :tag :OpRayQueryInitializeKHR
        :value 4473
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "RayFlags"}
            {:kind :IdRef :name "CullMask"}
            {:kind :IdRef :name "RayOrigin"}
            {:kind :IdRef :name "RayTMin"}
            {:kind :IdRef :name "RayDirection"}
            {:kind :IdRef :name "RayTMax"}
        ]
    }
    :OpRayQueryTerminateKHR {
        :tag :OpRayQueryTerminateKHR
        :value 4474
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGenerateIntersectionKHR {
        :tag :OpRayQueryGenerateIntersectionKHR
        :value 4475
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "HitT"}
        ]
    }
    :OpRayQueryConfirmIntersectionKHR {
        :tag :OpRayQueryConfirmIntersectionKHR
        :value 4476
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryProceedKHR {
        :tag :OpRayQueryProceedKHR
        :value 4477
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetIntersectionTypeKHR {
        :tag :OpRayQueryGetIntersectionTypeKHR
        :value 4479
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpImageSampleWeightedQCOM {
        :tag :OpImageSampleWeightedQCOM
        :value 4480
        :capabilities [
            :TextureSampleWeightedQCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Texture"}
            {:kind :IdRef :name "Coordinates"}
            {:kind :IdRef :name "Weights"}
        ]
    }
    :OpImageBoxFilterQCOM {
        :tag :OpImageBoxFilterQCOM
        :value 4481
        :capabilities [
            :TextureBoxFilterQCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Texture"}
            {:kind :IdRef :name "Coordinates"}
            {:kind :IdRef :name "Box Size"}
        ]
    }
    :OpImageBlockMatchSSDQCOM {
        :tag :OpImageBlockMatchSSDQCOM
        :value 4482
        :capabilities [
            :TextureBlockMatchQCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpImageBlockMatchSADQCOM {
        :tag :OpImageBlockMatchSADQCOM
        :value 4483
        :capabilities [
            :TextureBlockMatchQCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpImageBlockMatchWindowSSDQCOM {
        :tag :OpImageBlockMatchWindowSSDQCOM
        :value 4500
        :capabilities [
            :TextureBlockMatch2QCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target Sampled Image"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference Sampled Image"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpImageBlockMatchWindowSADQCOM {
        :tag :OpImageBlockMatchWindowSADQCOM
        :value 4501
        :capabilities [
            :TextureBlockMatch2QCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target Sampled Image"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference Sampled Image"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpImageBlockMatchGatherSSDQCOM {
        :tag :OpImageBlockMatchGatherSSDQCOM
        :value 4502
        :capabilities [
            :TextureBlockMatch2QCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target Sampled Image"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference Sampled Image"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpImageBlockMatchGatherSADQCOM {
        :tag :OpImageBlockMatchGatherSADQCOM
        :value 4503
        :capabilities [
            :TextureBlockMatch2QCOM
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Target Sampled Image"}
            {:kind :IdRef :name "Target Coordinates"}
            {:kind :IdRef :name "Reference Sampled Image"}
            {:kind :IdRef :name "Reference Coordinates"}
            {:kind :IdRef :name "Block Size"}
        ]
    }
    :OpGroupIAddNonUniformAMD {
        :tag :OpGroupIAddNonUniformAMD
        :value 5000
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFAddNonUniformAMD {
        :tag :OpGroupFAddNonUniformAMD
        :value 5001
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFMinNonUniformAMD {
        :tag :OpGroupFMinNonUniformAMD
        :value 5002
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupUMinNonUniformAMD {
        :tag :OpGroupUMinNonUniformAMD
        :value 5003
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupSMinNonUniformAMD {
        :tag :OpGroupSMinNonUniformAMD
        :value 5004
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFMaxNonUniformAMD {
        :tag :OpGroupFMaxNonUniformAMD
        :value 5005
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupUMaxNonUniformAMD {
        :tag :OpGroupUMaxNonUniformAMD
        :value 5006
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupSMaxNonUniformAMD {
        :tag :OpGroupSMaxNonUniformAMD
        :value 5007
        :extensions [
            :SPV_AMD_shader_ballot
        ]
        :capabilities [
            :Groups
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpFragmentMaskFetchAMD {
        :tag :OpFragmentMaskFetchAMD
        :value 5011
        :extensions [
            :SPV_AMD_shader_fragment_mask
        ]
        :capabilities [
            :FragmentMaskAMD
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
        ]
    }
    :OpFragmentFetchAMD {
        :tag :OpFragmentFetchAMD
        :value 5012
        :extensions [
            :SPV_AMD_shader_fragment_mask
        ]
        :capabilities [
            :FragmentMaskAMD
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Fragment Index"}
        ]
    }
    :OpReadClockKHR {
        :tag :OpReadClockKHR
        :value 5056
        :capabilities [
            :ShaderClockKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Scope"}
        ]
    }
    :OpFinalizeNodePayloadsAMDX {
        :tag :OpFinalizeNodePayloadsAMDX
        :value 5075
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Payload Array"}
        ]
    }
    :OpFinishWritingNodePayloadAMDX {
        :tag :OpFinishWritingNodePayloadAMDX
        :value 5078
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpInitializeNodePayloadsAMDX {
        :tag :OpInitializeNodePayloadsAMDX
        :value 5090
        :capabilities [
            :ShaderEnqueueAMDX
        ]
        :operands [
            {:kind :IdRef :name "Payload Array"}
            {:kind :IdScope :name "Visibility"}
            {:kind :IdRef :name "Payload Count"}
            {:kind :IdRef :name "Node Index"}
        ]
    }
    :OpGroupNonUniformQuadAllKHR {
        :tag :OpGroupNonUniformQuadAllKHR
        :value 5110
        :capabilities [
            :QuadControlKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpGroupNonUniformQuadAnyKHR {
        :tag :OpGroupNonUniformQuadAnyKHR
        :value 5111
        :capabilities [
            :QuadControlKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Predicate"}
        ]
    }
    :OpHitObjectRecordHitMotionNV {
        :tag :OpHitObjectRecordHitMotionNV
        :value 5249
        :capabilities [
            :ShaderInvocationReorderNV
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "InstanceId"}
            {:kind :IdRef :name "PrimitiveId"}
            {:kind :IdRef :name "GeometryIndex"}
            {:kind :IdRef :name "Hit Kind"}
            {:kind :IdRef :name "SBT Record Offset"}
            {:kind :IdRef :name "SBT Record Stride"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "Current Time"}
            {:kind :IdRef :name "HitObject Attributes"}
        ]
    }
    :OpHitObjectRecordHitWithIndexMotionNV {
        :tag :OpHitObjectRecordHitWithIndexMotionNV
        :value 5250
        :capabilities [
            :ShaderInvocationReorderNV
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "InstanceId"}
            {:kind :IdRef :name "PrimitiveId"}
            {:kind :IdRef :name "GeometryIndex"}
            {:kind :IdRef :name "Hit Kind"}
            {:kind :IdRef :name "SBT Record Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "Current Time"}
            {:kind :IdRef :name "HitObject Attributes"}
        ]
    }
    :OpHitObjectRecordMissMotionNV {
        :tag :OpHitObjectRecordMissMotionNV
        :value 5251
        :capabilities [
            :ShaderInvocationReorderNV
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "SBT Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "Current Time"}
        ]
    }
    :OpHitObjectGetWorldToObjectNV {
        :tag :OpHitObjectGetWorldToObjectNV
        :value 5252
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetObjectToWorldNV {
        :tag :OpHitObjectGetObjectToWorldNV
        :value 5253
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetObjectRayDirectionNV {
        :tag :OpHitObjectGetObjectRayDirectionNV
        :value 5254
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetObjectRayOriginNV {
        :tag :OpHitObjectGetObjectRayOriginNV
        :value 5255
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectTraceRayMotionNV {
        :tag :OpHitObjectTraceRayMotionNV
        :value 5256
        :capabilities [
            :ShaderInvocationReorderNV
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "RayFlags"}
            {:kind :IdRef :name "Cullmask"}
            {:kind :IdRef :name "SBT Record Offset"}
            {:kind :IdRef :name "SBT Record Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "Time"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpHitObjectGetShaderRecordBufferHandleNV {
        :tag :OpHitObjectGetShaderRecordBufferHandleNV
        :value 5257
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetShaderBindingTableRecordIndexNV {
        :tag :OpHitObjectGetShaderBindingTableRecordIndexNV
        :value 5258
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectRecordEmptyNV {
        :tag :OpHitObjectRecordEmptyNV
        :value 5259
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectTraceRayNV {
        :tag :OpHitObjectTraceRayNV
        :value 5260
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "RayFlags"}
            {:kind :IdRef :name "Cullmask"}
            {:kind :IdRef :name "SBT Record Offset"}
            {:kind :IdRef :name "SBT Record Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpHitObjectRecordHitNV {
        :tag :OpHitObjectRecordHitNV
        :value 5261
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "InstanceId"}
            {:kind :IdRef :name "PrimitiveId"}
            {:kind :IdRef :name "GeometryIndex"}
            {:kind :IdRef :name "Hit Kind"}
            {:kind :IdRef :name "SBT Record Offset"}
            {:kind :IdRef :name "SBT Record Stride"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "HitObject Attributes"}
        ]
    }
    :OpHitObjectRecordHitWithIndexNV {
        :tag :OpHitObjectRecordHitWithIndexNV
        :value 5262
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Acceleration Structure"}
            {:kind :IdRef :name "InstanceId"}
            {:kind :IdRef :name "PrimitiveId"}
            {:kind :IdRef :name "GeometryIndex"}
            {:kind :IdRef :name "Hit Kind"}
            {:kind :IdRef :name "SBT Record Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
            {:kind :IdRef :name "HitObject Attributes"}
        ]
    }
    :OpHitObjectRecordMissNV {
        :tag :OpHitObjectRecordMissNV
        :value 5263
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "SBT Index"}
            {:kind :IdRef :name "Origin"}
            {:kind :IdRef :name "TMin"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "TMax"}
        ]
    }
    :OpHitObjectExecuteShaderNV {
        :tag :OpHitObjectExecuteShaderNV
        :value 5264
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpHitObjectGetCurrentTimeNV {
        :tag :OpHitObjectGetCurrentTimeNV
        :value 5265
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetAttributesNV {
        :tag :OpHitObjectGetAttributesNV
        :value 5266
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :name "Hit Object Attribute"}
        ]
    }
    :OpHitObjectGetHitKindNV {
        :tag :OpHitObjectGetHitKindNV
        :value 5267
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetPrimitiveIndexNV {
        :tag :OpHitObjectGetPrimitiveIndexNV
        :value 5268
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetGeometryIndexNV {
        :tag :OpHitObjectGetGeometryIndexNV
        :value 5269
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetInstanceIdNV {
        :tag :OpHitObjectGetInstanceIdNV
        :value 5270
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetInstanceCustomIndexNV {
        :tag :OpHitObjectGetInstanceCustomIndexNV
        :value 5271
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetWorldRayDirectionNV {
        :tag :OpHitObjectGetWorldRayDirectionNV
        :value 5272
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetWorldRayOriginNV {
        :tag :OpHitObjectGetWorldRayOriginNV
        :value 5273
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetRayTMaxNV {
        :tag :OpHitObjectGetRayTMaxNV
        :value 5274
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectGetRayTMinNV {
        :tag :OpHitObjectGetRayTMinNV
        :value 5275
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectIsEmptyNV {
        :tag :OpHitObjectIsEmptyNV
        :value 5276
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectIsHitNV {
        :tag :OpHitObjectIsHitNV
        :value 5277
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpHitObjectIsMissNV {
        :tag :OpHitObjectIsMissNV
        :value 5278
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit Object"}
        ]
    }
    :OpReorderThreadWithHitObjectNV {
        :tag :OpReorderThreadWithHitObjectNV
        :value 5279
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hit Object"}
            {:kind :IdRef :quantifier :? :name "Hint"}
            {:kind :IdRef :quantifier :? :name "Bits"}
        ]
    }
    :OpReorderThreadWithHintNV {
        :tag :OpReorderThreadWithHintNV
        :value 5280
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdRef :name "Hint"}
            {:kind :IdRef :name "Bits"}
        ]
    }
    :OpTypeHitObjectNV {
        :tag :OpTypeHitObjectNV
        :value 5281
        :capabilities [
            :ShaderInvocationReorderNV
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpImageSampleFootprintNV {
        :tag :OpImageSampleFootprintNV
        :value 5283
        :extensions [
            :SPV_NV_shader_image_footprint
        ]
        :capabilities [
            :ImageFootprintNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Sampled Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Granularity"}
            {:kind :IdRef :name "Coarse"}
            {:kind :ImageOperands :quantifier :?}
        ]
    }
    :OpEmitMeshTasksEXT {
        :tag :OpEmitMeshTasksEXT
        :value 5294
        :capabilities [
            :MeshShadingEXT
        ]
        :operands [
            {:kind :IdRef :name "Group Count X"}
            {:kind :IdRef :name "Group Count Y"}
            {:kind :IdRef :name "Group Count Z"}
            {:kind :IdRef :quantifier :? :name "Payload"}
        ]
    }
    :OpSetMeshOutputsEXT {
        :tag :OpSetMeshOutputsEXT
        :value 5295
        :capabilities [
            :MeshShadingEXT
        ]
        :operands [
            {:kind :IdRef :name "Vertex Count"}
            {:kind :IdRef :name "Primitive Count"}
        ]
    }
    :OpGroupNonUniformPartitionNV {
        :tag :OpGroupNonUniformPartitionNV
        :value 5296
        :extensions [
            :SPV_NV_shader_subgroup_partitioned
        ]
        :capabilities [
            :GroupNonUniformPartitionedNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpWritePackedPrimitiveIndices4x8NV {
        :tag :OpWritePackedPrimitiveIndices4x8NV
        :value 5299
        :extensions [
            :SPV_NV_mesh_shader
        ]
        :capabilities [
            :MeshShadingNV
        ]
        :operands [
            {:kind :IdRef :name "Index Offset"}
            {:kind :IdRef :name "Packed Indices"}
        ]
    }
    :OpFetchMicroTriangleVertexPositionNV {
        :tag :OpFetchMicroTriangleVertexPositionNV
        :value 5300
        :capabilities [
            :DisplacementMicromapNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Instance Id"}
            {:kind :IdRef :name "Geometry Index"}
            {:kind :IdRef :name "Primitive Index"}
            {:kind :IdRef :name "Barycentric"}
        ]
    }
    :OpFetchMicroTriangleVertexBarycentricNV {
        :tag :OpFetchMicroTriangleVertexBarycentricNV
        :value 5301
        :capabilities [
            :DisplacementMicromapNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Instance Id"}
            {:kind :IdRef :name "Geometry Index"}
            {:kind :IdRef :name "Primitive Index"}
            {:kind :IdRef :name "Barycentric"}
        ]
    }
    :OpReportIntersectionKHR {
        :tag :OpReportIntersectionKHR
        :value 5334
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Hit"}
            {:kind :IdRef :name "HitKind"}
        ]
    }
    :OpIgnoreIntersectionNV {
        :tag :OpIgnoreIntersectionNV
        :value 5335
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
        ]
    }
    :OpTerminateRayNV {
        :tag :OpTerminateRayNV
        :value 5336
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
        ]
    }
    :OpTraceNV {
        :tag :OpTraceNV
        :value 5337
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
        ]
        :operands [
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Ray Flags"}
            {:kind :IdRef :name "Cull Mask"}
            {:kind :IdRef :name "SBT Offset"}
            {:kind :IdRef :name "SBT Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Ray Origin"}
            {:kind :IdRef :name "Ray Tmin"}
            {:kind :IdRef :name "Ray Direction"}
            {:kind :IdRef :name "Ray Tmax"}
            {:kind :IdRef :name "PayloadId"}
        ]
    }
    :OpTraceMotionNV {
        :tag :OpTraceMotionNV
        :value 5338
        :extensions [
            :SPV_NV_ray_tracing_motion_blur
        ]
        :capabilities [
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Ray Flags"}
            {:kind :IdRef :name "Cull Mask"}
            {:kind :IdRef :name "SBT Offset"}
            {:kind :IdRef :name "SBT Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Ray Origin"}
            {:kind :IdRef :name "Ray Tmin"}
            {:kind :IdRef :name "Ray Direction"}
            {:kind :IdRef :name "Ray Tmax"}
            {:kind :IdRef :name "Time"}
            {:kind :IdRef :name "PayloadId"}
        ]
    }
    :OpTraceRayMotionNV {
        :tag :OpTraceRayMotionNV
        :value 5339
        :extensions [
            :SPV_NV_ray_tracing_motion_blur
        ]
        :capabilities [
            :RayTracingMotionBlurNV
        ]
        :operands [
            {:kind :IdRef :name "Accel"}
            {:kind :IdRef :name "Ray Flags"}
            {:kind :IdRef :name "Cull Mask"}
            {:kind :IdRef :name "SBT Offset"}
            {:kind :IdRef :name "SBT Stride"}
            {:kind :IdRef :name "Miss Index"}
            {:kind :IdRef :name "Ray Origin"}
            {:kind :IdRef :name "Ray Tmin"}
            {:kind :IdRef :name "Ray Direction"}
            {:kind :IdRef :name "Ray Tmax"}
            {:kind :IdRef :name "Time"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpRayQueryGetIntersectionTriangleVertexPositionsKHR {
        :tag :OpRayQueryGetIntersectionTriangleVertexPositionsKHR
        :value 5340
        :capabilities [
            :RayQueryPositionFetchKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpTypeAccelerationStructureKHR {
        :tag :OpTypeAccelerationStructureKHR
        :value 5341
        :extensions [
            :SPV_NV_ray_tracing
            :SPV_KHR_ray_tracing
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayTracingNV
            :RayTracingKHR
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpExecuteCallableNV {
        :tag :OpExecuteCallableNV
        :value 5344
        :extensions [
            :SPV_NV_ray_tracing
        ]
        :capabilities [
            :RayTracingNV
        ]
        :operands [
            {:kind :IdRef :name "SBT Index"}
            {:kind :IdRef :name "Callable DataId"}
        ]
    }
    :OpTypeCooperativeMatrixNV {
        :tag :OpTypeCooperativeMatrixNV
        :value 5358
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :CooperativeMatrixNV
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Component Type"}
            {:kind :IdScope :name "Execution"}
            {:kind :IdRef :name "Rows"}
            {:kind :IdRef :name "Columns"}
        ]
    }
    :OpCooperativeMatrixLoadNV {
        :tag :OpCooperativeMatrixLoadNV
        :value 5359
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :CooperativeMatrixNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Stride"}
            {:kind :IdRef :name "Column Major"}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpCooperativeMatrixStoreNV {
        :tag :OpCooperativeMatrixStoreNV
        :value 5360
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :CooperativeMatrixNV
        ]
        :operands [
            {:kind :IdRef :name "Pointer"}
            {:kind :IdRef :name "Object"}
            {:kind :IdRef :name "Stride"}
            {:kind :IdRef :name "Column Major"}
            {:kind :MemoryAccess :quantifier :?}
        ]
    }
    :OpCooperativeMatrixMulAddNV {
        :tag :OpCooperativeMatrixMulAddNV
        :value 5361
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :CooperativeMatrixNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :IdRef :name "B"}
            {:kind :IdRef :name "C"}
        ]
    }
    :OpCooperativeMatrixLengthNV {
        :tag :OpCooperativeMatrixLengthNV
        :value 5362
        :extensions [
            :SPV_NV_cooperative_matrix
        ]
        :capabilities [
            :CooperativeMatrixNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Type"}
        ]
    }
    :OpBeginInvocationInterlockEXT {
        :tag :OpBeginInvocationInterlockEXT
        :value 5364
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderSampleInterlockEXT
            :FragmentShaderPixelInterlockEXT
            :FragmentShaderShadingRateInterlockEXT
        ]
    }
    :OpEndInvocationInterlockEXT {
        :tag :OpEndInvocationInterlockEXT
        :value 5365
        :extensions [
            :SPV_EXT_fragment_shader_interlock
        ]
        :capabilities [
            :FragmentShaderSampleInterlockEXT
            :FragmentShaderPixelInterlockEXT
            :FragmentShaderShadingRateInterlockEXT
        ]
    }
    :OpDemoteToHelperInvocation {
        :tag :OpDemoteToHelperInvocation
        :value 5380
        :version { :major 1 :minor 6 }
        :capabilities [
            :DemoteToHelperInvocation
        ]
    }
    :OpIsHelperInvocationEXT {
        :tag :OpIsHelperInvocationEXT
        :value 5381
        :extensions [
            :SPV_EXT_demote_to_helper_invocation
        ]
        :capabilities [
            :DemoteToHelperInvocationEXT
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpConvertUToImageNV {
        :tag :OpConvertUToImageNV
        :value 5391
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpConvertUToSamplerNV {
        :tag :OpConvertUToSamplerNV
        :value 5392
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpConvertImageToUNV {
        :tag :OpConvertImageToUNV
        :value 5393
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpConvertSamplerToUNV {
        :tag :OpConvertSamplerToUNV
        :value 5394
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpConvertUToSampledImageNV {
        :tag :OpConvertUToSampledImageNV
        :value 5395
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpConvertSampledImageToUNV {
        :tag :OpConvertSampledImageToUNV
        :value 5396
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpSamplerImageAddressingModeNV {
        :tag :OpSamplerImageAddressingModeNV
        :value 5397
        :capabilities [
            :BindlessTextureNV
        ]
        :operands [
            {:kind :LiteralInteger :name "Bit Width"}
        ]
    }
    :OpRawAccessChainNV {
        :tag :OpRawAccessChainNV
        :value 5398
        :capabilities [
            :RawAccessChainsNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Base"}
            {:kind :IdRef :name "Byte stride"}
            {:kind :IdRef :name "Element index"}
            {:kind :IdRef :name "Byte offset"}
            {:kind :RawAccessChainOperands :quantifier :?}
        ]
    }
    :OpSubgroupShuffleINTEL {
        :tag :OpSubgroupShuffleINTEL
        :value 5571
        :capabilities [
            :SubgroupShuffleINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Data"}
            {:kind :IdRef :name "InvocationId"}
        ]
    }
    :OpSubgroupShuffleDownINTEL {
        :tag :OpSubgroupShuffleDownINTEL
        :value 5572
        :capabilities [
            :SubgroupShuffleINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Current"}
            {:kind :IdRef :name "Next"}
            {:kind :IdRef :name "Delta"}
        ]
    }
    :OpSubgroupShuffleUpINTEL {
        :tag :OpSubgroupShuffleUpINTEL
        :value 5573
        :capabilities [
            :SubgroupShuffleINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Previous"}
            {:kind :IdRef :name "Current"}
            {:kind :IdRef :name "Delta"}
        ]
    }
    :OpSubgroupShuffleXorINTEL {
        :tag :OpSubgroupShuffleXorINTEL
        :value 5574
        :capabilities [
            :SubgroupShuffleINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Data"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpSubgroupBlockReadINTEL {
        :tag :OpSubgroupBlockReadINTEL
        :value 5575
        :capabilities [
            :SubgroupBufferBlockIOINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Ptr"}
        ]
    }
    :OpSubgroupBlockWriteINTEL {
        :tag :OpSubgroupBlockWriteINTEL
        :value 5576
        :capabilities [
            :SubgroupBufferBlockIOINTEL
        ]
        :operands [
            {:kind :IdRef :name "Ptr"}
            {:kind :IdRef :name "Data"}
        ]
    }
    :OpSubgroupImageBlockReadINTEL {
        :tag :OpSubgroupImageBlockReadINTEL
        :value 5577
        :capabilities [
            :SubgroupImageBlockIOINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
        ]
    }
    :OpSubgroupImageBlockWriteINTEL {
        :tag :OpSubgroupImageBlockWriteINTEL
        :value 5578
        :capabilities [
            :SubgroupImageBlockIOINTEL
        ]
        :operands [
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Data"}
        ]
    }
    :OpSubgroupImageMediaBlockReadINTEL {
        :tag :OpSubgroupImageMediaBlockReadINTEL
        :value 5580
        :capabilities [
            :SubgroupImageMediaBlockIOINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Width"}
            {:kind :IdRef :name "Height"}
        ]
    }
    :OpSubgroupImageMediaBlockWriteINTEL {
        :tag :OpSubgroupImageMediaBlockWriteINTEL
        :value 5581
        :capabilities [
            :SubgroupImageMediaBlockIOINTEL
        ]
        :operands [
            {:kind :IdRef :name "Image"}
            {:kind :IdRef :name "Coordinate"}
            {:kind :IdRef :name "Width"}
            {:kind :IdRef :name "Height"}
            {:kind :IdRef :name "Data"}
        ]
    }
    :OpUCountLeadingZerosINTEL {
        :tag :OpUCountLeadingZerosINTEL
        :value 5585
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpUCountTrailingZerosINTEL {
        :tag :OpUCountTrailingZerosINTEL
        :value 5586
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand"}
        ]
    }
    :OpAbsISubINTEL {
        :tag :OpAbsISubINTEL
        :value 5587
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpAbsUSubINTEL {
        :tag :OpAbsUSubINTEL
        :value 5588
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIAddSatINTEL {
        :tag :OpIAddSatINTEL
        :value 5589
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUAddSatINTEL {
        :tag :OpUAddSatINTEL
        :value 5590
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIAverageINTEL {
        :tag :OpIAverageINTEL
        :value 5591
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUAverageINTEL {
        :tag :OpUAverageINTEL
        :value 5592
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIAverageRoundedINTEL {
        :tag :OpIAverageRoundedINTEL
        :value 5593
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUAverageRoundedINTEL {
        :tag :OpUAverageRoundedINTEL
        :value 5594
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpISubSatINTEL {
        :tag :OpISubSatINTEL
        :value 5595
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUSubSatINTEL {
        :tag :OpUSubSatINTEL
        :value 5596
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpIMul32x16INTEL {
        :tag :OpIMul32x16INTEL
        :value 5597
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpUMul32x16INTEL {
        :tag :OpUMul32x16INTEL
        :value 5598
        :capabilities [
            :IntegerFunctions2INTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Operand 1"}
            {:kind :IdRef :name "Operand 2"}
        ]
    }
    :OpConstantFunctionPointerINTEL {
        :tag :OpConstantFunctionPointerINTEL
        :value 5600
        :extensions [
            :SPV_INTEL_function_pointers
        ]
        :capabilities [
            :FunctionPointersINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Function"}
        ]
    }
    :OpFunctionPointerCallINTEL {
        :tag :OpFunctionPointerCallINTEL
        :value 5601
        :extensions [
            :SPV_INTEL_function_pointers
        ]
        :capabilities [
            :FunctionPointersINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Operand 1"}
        ]
    }
    :OpAsmTargetINTEL {
        :tag :OpAsmTargetINTEL
        :value 5609
        :capabilities [
            :AsmINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :LiteralString :name "Asm target"}
        ]
    }
    :OpAsmINTEL {
        :tag :OpAsmINTEL
        :value 5610
        :capabilities [
            :AsmINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Asm type"}
            {:kind :IdRef :name "Target"}
            {:kind :LiteralString :name "Asm instructions"}
            {:kind :LiteralString :name "Constraints"}
        ]
    }
    :OpAsmCallINTEL {
        :tag :OpAsmCallINTEL
        :value 5611
        :capabilities [
            :AsmINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Asm"}
            {:kind :IdRef :quantifier :* :name "Argument 0"}
        ]
    }
    :OpAtomicFMinEXT {
        :tag :OpAtomicFMinEXT
        :value 5614
        :capabilities [
            :AtomicFloat16MinMaxEXT
            :AtomicFloat32MinMaxEXT
            :AtomicFloat64MinMaxEXT
            :AtomicFloat16VectorNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAtomicFMaxEXT {
        :tag :OpAtomicFMaxEXT
        :value 5615
        :capabilities [
            :AtomicFloat16MinMaxEXT
            :AtomicFloat32MinMaxEXT
            :AtomicFloat64MinMaxEXT
            :AtomicFloat16VectorNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpAssumeTrueKHR {
        :tag :OpAssumeTrueKHR
        :value 5630
        :extensions [
            :SPV_KHR_expect_assume
        ]
        :capabilities [
            :ExpectAssumeKHR
        ]
        :operands [
            {:kind :IdRef :name "Condition"}
        ]
    }
    :OpExpectKHR {
        :tag :OpExpectKHR
        :value 5631
        :extensions [
            :SPV_KHR_expect_assume
        ]
        :capabilities [
            :ExpectAssumeKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Value"}
            {:kind :IdRef :name "ExpectedValue"}
        ]
    }
    :OpDecorateString {
        :tag :OpDecorateString
        :value 5632
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_GOOGLE_decorate_string
            :SPV_GOOGLE_hlsl_functionality1
        ]
        :operands [
            {:kind :IdRef :name "Target"}
            {:kind :Decoration}
        ]
    }
    :OpMemberDecorateString {
        :tag :OpMemberDecorateString
        :value 5633
        :version { :major 1 :minor 4 }
        :extensions [
            :SPV_GOOGLE_decorate_string
            :SPV_GOOGLE_hlsl_functionality1
        ]
        :operands [
            {:kind :IdRef :name "Struct Type"}
            {:kind :LiteralInteger :name "Member"}
            {:kind :Decoration}
        ]
    }
    :OpVmeImageINTEL {
        :tag :OpVmeImageINTEL
        :value 5699
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image Type"}
            {:kind :IdRef :name "Sampler"}
        ]
    }
    :OpTypeVmeImageINTEL {
        :tag :OpTypeVmeImageINTEL
        :value 5700
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Image Type"}
        ]
    }
    :OpTypeAvcImePayloadINTEL {
        :tag :OpTypeAvcImePayloadINTEL
        :value 5701
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcRefPayloadINTEL {
        :tag :OpTypeAvcRefPayloadINTEL
        :value 5702
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcSicPayloadINTEL {
        :tag :OpTypeAvcSicPayloadINTEL
        :value 5703
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcMcePayloadINTEL {
        :tag :OpTypeAvcMcePayloadINTEL
        :value 5704
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcMceResultINTEL {
        :tag :OpTypeAvcMceResultINTEL
        :value 5705
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcImeResultINTEL {
        :tag :OpTypeAvcImeResultINTEL
        :value 5706
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcImeResultSingleReferenceStreamoutINTEL {
        :tag :OpTypeAvcImeResultSingleReferenceStreamoutINTEL
        :value 5707
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcImeResultDualReferenceStreamoutINTEL {
        :tag :OpTypeAvcImeResultDualReferenceStreamoutINTEL
        :value 5708
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcImeSingleReferenceStreaminINTEL {
        :tag :OpTypeAvcImeSingleReferenceStreaminINTEL
        :value 5709
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcImeDualReferenceStreaminINTEL {
        :tag :OpTypeAvcImeDualReferenceStreaminINTEL
        :value 5710
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcRefResultINTEL {
        :tag :OpTypeAvcRefResultINTEL
        :value 5711
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpTypeAvcSicResultINTEL {
        :tag :OpTypeAvcSicResultINTEL
        :value 5712
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceGetDefaultInterBaseMultiReferencePenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultInterBaseMultiReferencePenaltyINTEL
        :value 5713
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceSetInterBaseMultiReferencePenaltyINTEL {
        :tag :OpSubgroupAvcMceSetInterBaseMultiReferencePenaltyINTEL
        :value 5714
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Reference Base Penalty"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultInterShapePenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultInterShapePenaltyINTEL
        :value 5715
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceSetInterShapePenaltyINTEL {
        :tag :OpSubgroupAvcMceSetInterShapePenaltyINTEL
        :value 5716
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Shape Penalty"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultInterDirectionPenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultInterDirectionPenaltyINTEL
        :value 5717
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceSetInterDirectionPenaltyINTEL {
        :tag :OpSubgroupAvcMceSetInterDirectionPenaltyINTEL
        :value 5718
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Direction Cost"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultIntraLumaShapePenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultIntraLumaShapePenaltyINTEL
        :value 5719
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultInterMotionVectorCostTableINTEL {
        :tag :OpSubgroupAvcMceGetDefaultInterMotionVectorCostTableINTEL
        :value 5720
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultHighPenaltyCostTableINTEL {
        :tag :OpSubgroupAvcMceGetDefaultHighPenaltyCostTableINTEL
        :value 5721
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceGetDefaultMediumPenaltyCostTableINTEL {
        :tag :OpSubgroupAvcMceGetDefaultMediumPenaltyCostTableINTEL
        :value 5722
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceGetDefaultLowPenaltyCostTableINTEL {
        :tag :OpSubgroupAvcMceGetDefaultLowPenaltyCostTableINTEL
        :value 5723
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceSetMotionVectorCostFunctionINTEL {
        :tag :OpSubgroupAvcMceSetMotionVectorCostFunctionINTEL
        :value 5724
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Cost Center Delta"}
            {:kind :IdRef :name "Packed Cost Table"}
            {:kind :IdRef :name "Cost Precision"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultIntraLumaModePenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultIntraLumaModePenaltyINTEL
        :value 5725
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Slice Type"}
            {:kind :IdRef :name "Qp"}
        ]
    }
    :OpSubgroupAvcMceGetDefaultNonDcLumaIntraPenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultNonDcLumaIntraPenaltyINTEL
        :value 5726
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceGetDefaultIntraChromaModeBasePenaltyINTEL {
        :tag :OpSubgroupAvcMceGetDefaultIntraChromaModeBasePenaltyINTEL
        :value 5727
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationChromaINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpSubgroupAvcMceSetAcOnlyHaarINTEL {
        :tag :OpSubgroupAvcMceSetAcOnlyHaarINTEL
        :value 5728
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceSetSourceInterlacedFieldPolarityINTEL {
        :tag :OpSubgroupAvcMceSetSourceInterlacedFieldPolarityINTEL
        :value 5729
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Source Field Polarity"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceSetSingleReferenceInterlacedFieldPolarityINTEL {
        :tag :OpSubgroupAvcMceSetSingleReferenceInterlacedFieldPolarityINTEL
        :value 5730
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Reference Field Polarity"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceSetDualReferenceInterlacedFieldPolaritiesINTEL {
        :tag :OpSubgroupAvcMceSetDualReferenceInterlacedFieldPolaritiesINTEL
        :value 5731
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Forward Reference Field Polarity"}
            {:kind :IdRef :name "Backward Reference Field Polarity"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToImePayloadINTEL {
        :tag :OpSubgroupAvcMceConvertToImePayloadINTEL
        :value 5732
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToImeResultINTEL {
        :tag :OpSubgroupAvcMceConvertToImeResultINTEL
        :value 5733
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToRefPayloadINTEL {
        :tag :OpSubgroupAvcMceConvertToRefPayloadINTEL
        :value 5734
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToRefResultINTEL {
        :tag :OpSubgroupAvcMceConvertToRefResultINTEL
        :value 5735
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToSicPayloadINTEL {
        :tag :OpSubgroupAvcMceConvertToSicPayloadINTEL
        :value 5736
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceConvertToSicResultINTEL {
        :tag :OpSubgroupAvcMceConvertToSicResultINTEL
        :value 5737
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetMotionVectorsINTEL {
        :tag :OpSubgroupAvcMceGetMotionVectorsINTEL
        :value 5738
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterDistortionsINTEL {
        :tag :OpSubgroupAvcMceGetInterDistortionsINTEL
        :value 5739
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetBestInterDistortionsINTEL {
        :tag :OpSubgroupAvcMceGetBestInterDistortionsINTEL
        :value 5740
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterMajorShapeINTEL {
        :tag :OpSubgroupAvcMceGetInterMajorShapeINTEL
        :value 5741
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterMinorShapeINTEL {
        :tag :OpSubgroupAvcMceGetInterMinorShapeINTEL
        :value 5742
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterDirectionsINTEL {
        :tag :OpSubgroupAvcMceGetInterDirectionsINTEL
        :value 5743
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterMotionVectorCountINTEL {
        :tag :OpSubgroupAvcMceGetInterMotionVectorCountINTEL
        :value 5744
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterReferenceIdsINTEL {
        :tag :OpSubgroupAvcMceGetInterReferenceIdsINTEL
        :value 5745
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcMceGetInterReferenceInterlacedFieldPolaritiesINTEL {
        :tag :OpSubgroupAvcMceGetInterReferenceInterlacedFieldPolaritiesINTEL
        :value 5746
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Reference Ids"}
            {:kind :IdRef :name "Packed Reference Parameter Field Polarities"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeInitializeINTEL {
        :tag :OpSubgroupAvcImeInitializeINTEL
        :value 5747
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Coord"}
            {:kind :IdRef :name "Partition Mask"}
            {:kind :IdRef :name "SAD Adjustment"}
        ]
    }
    :OpSubgroupAvcImeSetSingleReferenceINTEL {
        :tag :OpSubgroupAvcImeSetSingleReferenceINTEL
        :value 5748
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Ref Offset"}
            {:kind :IdRef :name "Search Window Config"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeSetDualReferenceINTEL {
        :tag :OpSubgroupAvcImeSetDualReferenceINTEL
        :value 5749
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Fwd Ref Offset"}
            {:kind :IdRef :name "Bwd Ref Offset"}
            {:kind :IdRef :name "id> Search Window Config"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeRefWindowSizeINTEL {
        :tag :OpSubgroupAvcImeRefWindowSizeINTEL
        :value 5750
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Search Window Config"}
            {:kind :IdRef :name "Dual Ref"}
        ]
    }
    :OpSubgroupAvcImeAdjustRefOffsetINTEL {
        :tag :OpSubgroupAvcImeAdjustRefOffsetINTEL
        :value 5751
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Ref Offset"}
            {:kind :IdRef :name "Src Coord"}
            {:kind :IdRef :name "Ref Window Size"}
            {:kind :IdRef :name "Image Size"}
        ]
    }
    :OpSubgroupAvcImeConvertToMcePayloadINTEL {
        :tag :OpSubgroupAvcImeConvertToMcePayloadINTEL
        :value 5752
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeSetMaxMotionVectorCountINTEL {
        :tag :OpSubgroupAvcImeSetMaxMotionVectorCountINTEL
        :value 5753
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Max Motion Vector Count"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeSetUnidirectionalMixDisableINTEL {
        :tag :OpSubgroupAvcImeSetUnidirectionalMixDisableINTEL
        :value 5754
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeSetEarlySearchTerminationThresholdINTEL {
        :tag :OpSubgroupAvcImeSetEarlySearchTerminationThresholdINTEL
        :value 5755
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Threshold"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeSetWeightedSadINTEL {
        :tag :OpSubgroupAvcImeSetWeightedSadINTEL
        :value 5756
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Sad Weights"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithSingleReferenceINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithSingleReferenceINTEL
        :value 5757
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithDualReferenceINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithDualReferenceINTEL
        :value 5758
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithSingleReferenceStreaminINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithSingleReferenceStreaminINTEL
        :value 5759
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Streamin Components"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithDualReferenceStreaminINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithDualReferenceStreaminINTEL
        :value 5760
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Streamin Components"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithSingleReferenceStreamoutINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithSingleReferenceStreamoutINTEL
        :value 5761
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithDualReferenceStreamoutINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithDualReferenceStreamoutINTEL
        :value 5762
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithSingleReferenceStreaminoutINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithSingleReferenceStreaminoutINTEL
        :value 5763
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Streamin Components"}
        ]
    }
    :OpSubgroupAvcImeEvaluateWithDualReferenceStreaminoutINTEL {
        :tag :OpSubgroupAvcImeEvaluateWithDualReferenceStreaminoutINTEL
        :value 5764
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Streamin Components"}
        ]
    }
    :OpSubgroupAvcImeConvertToMceResultINTEL {
        :tag :OpSubgroupAvcImeConvertToMceResultINTEL
        :value 5765
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetSingleReferenceStreaminINTEL {
        :tag :OpSubgroupAvcImeGetSingleReferenceStreaminINTEL
        :value 5766
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetDualReferenceStreaminINTEL {
        :tag :OpSubgroupAvcImeGetDualReferenceStreaminINTEL
        :value 5767
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeStripSingleReferenceStreamoutINTEL {
        :tag :OpSubgroupAvcImeStripSingleReferenceStreamoutINTEL
        :value 5768
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeStripDualReferenceStreamoutINTEL {
        :tag :OpSubgroupAvcImeStripDualReferenceStreamoutINTEL
        :value 5769
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeMotionVectorsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeMotionVectorsINTEL
        :value 5770
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeDistortionsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeDistortionsINTEL
        :value 5771
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeReferenceIdsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutSingleReferenceMajorShapeReferenceIdsINTEL
        :value 5772
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeMotionVectorsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeMotionVectorsINTEL
        :value 5773
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
            {:kind :IdRef :name "Direction"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeDistortionsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeDistortionsINTEL
        :value 5774
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
            {:kind :IdRef :name "Direction"}
        ]
    }
    :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeReferenceIdsINTEL {
        :tag :OpSubgroupAvcImeGetStreamoutDualReferenceMajorShapeReferenceIdsINTEL
        :value 5775
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
            {:kind :IdRef :name "Major Shape"}
            {:kind :IdRef :name "Direction"}
        ]
    }
    :OpSubgroupAvcImeGetBorderReachedINTEL {
        :tag :OpSubgroupAvcImeGetBorderReachedINTEL
        :value 5776
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Image Select"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetTruncatedSearchIndicationINTEL {
        :tag :OpSubgroupAvcImeGetTruncatedSearchIndicationINTEL
        :value 5777
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetUnidirectionalEarlySearchTerminationINTEL {
        :tag :OpSubgroupAvcImeGetUnidirectionalEarlySearchTerminationINTEL
        :value 5778
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetWeightingPatternMinimumMotionVectorINTEL {
        :tag :OpSubgroupAvcImeGetWeightingPatternMinimumMotionVectorINTEL
        :value 5779
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcImeGetWeightingPatternMinimumDistortionINTEL {
        :tag :OpSubgroupAvcImeGetWeightingPatternMinimumDistortionINTEL
        :value 5780
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcFmeInitializeINTEL {
        :tag :OpSubgroupAvcFmeInitializeINTEL
        :value 5781
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Coord"}
            {:kind :IdRef :name "Motion Vectors"}
            {:kind :IdRef :name "Major Shapes"}
            {:kind :IdRef :name "Minor Shapes"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "Pixel Resolution"}
            {:kind :IdRef :name "Sad Adjustment"}
        ]
    }
    :OpSubgroupAvcBmeInitializeINTEL {
        :tag :OpSubgroupAvcBmeInitializeINTEL
        :value 5782
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Coord"}
            {:kind :IdRef :name "Motion Vectors"}
            {:kind :IdRef :name "Major Shapes"}
            {:kind :IdRef :name "Minor Shapes"}
            {:kind :IdRef :name "Direction"}
            {:kind :IdRef :name "Pixel Resolution"}
            {:kind :IdRef :name "Bidirectional Weight"}
            {:kind :IdRef :name "Sad Adjustment"}
        ]
    }
    :OpSubgroupAvcRefConvertToMcePayloadINTEL {
        :tag :OpSubgroupAvcRefConvertToMcePayloadINTEL
        :value 5783
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefSetBidirectionalMixDisableINTEL {
        :tag :OpSubgroupAvcRefSetBidirectionalMixDisableINTEL
        :value 5784
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefSetBilinearFilterEnableINTEL {
        :tag :OpSubgroupAvcRefSetBilinearFilterEnableINTEL
        :value 5785
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefEvaluateWithSingleReferenceINTEL {
        :tag :OpSubgroupAvcRefEvaluateWithSingleReferenceINTEL
        :value 5786
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefEvaluateWithDualReferenceINTEL {
        :tag :OpSubgroupAvcRefEvaluateWithDualReferenceINTEL
        :value 5787
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefEvaluateWithMultiReferenceINTEL {
        :tag :OpSubgroupAvcRefEvaluateWithMultiReferenceINTEL
        :value 5788
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Packed Reference Ids"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefEvaluateWithMultiReferenceInterlacedINTEL {
        :tag :OpSubgroupAvcRefEvaluateWithMultiReferenceInterlacedINTEL
        :value 5789
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Packed Reference Ids"}
            {:kind :IdRef :name "Packed Reference Field Polarities"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcRefConvertToMceResultINTEL {
        :tag :OpSubgroupAvcRefConvertToMceResultINTEL
        :value 5790
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicInitializeINTEL {
        :tag :OpSubgroupAvcSicInitializeINTEL
        :value 5791
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Coord"}
        ]
    }
    :OpSubgroupAvcSicConfigureSkcINTEL {
        :tag :OpSubgroupAvcSicConfigureSkcINTEL
        :value 5792
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Skip Block Partition Type"}
            {:kind :IdRef :name "Skip Motion Vector Mask"}
            {:kind :IdRef :name "Motion Vectors"}
            {:kind :IdRef :name "Bidirectional Weight"}
            {:kind :IdRef :name "Sad Adjustment"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicConfigureIpeLumaINTEL {
        :tag :OpSubgroupAvcSicConfigureIpeLumaINTEL
        :value 5793
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Luma Intra Partition Mask"}
            {:kind :IdRef :name "Intra Neighbour Availabilty"}
            {:kind :IdRef :name "Left Edge Luma Pixels"}
            {:kind :IdRef :name "Upper Left Corner Luma Pixel"}
            {:kind :IdRef :name "Upper Edge Luma Pixels"}
            {:kind :IdRef :name "Upper Right Edge Luma Pixels"}
            {:kind :IdRef :name "Sad Adjustment"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicConfigureIpeLumaChromaINTEL {
        :tag :OpSubgroupAvcSicConfigureIpeLumaChromaINTEL
        :value 5794
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationChromaINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Luma Intra Partition Mask"}
            {:kind :IdRef :name "Intra Neighbour Availabilty"}
            {:kind :IdRef :name "Left Edge Luma Pixels"}
            {:kind :IdRef :name "Upper Left Corner Luma Pixel"}
            {:kind :IdRef :name "Upper Edge Luma Pixels"}
            {:kind :IdRef :name "Upper Right Edge Luma Pixels"}
            {:kind :IdRef :name "Left Edge Chroma Pixels"}
            {:kind :IdRef :name "Upper Left Corner Chroma Pixel"}
            {:kind :IdRef :name "Upper Edge Chroma Pixels"}
            {:kind :IdRef :name "Sad Adjustment"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetMotionVectorMaskINTEL {
        :tag :OpSubgroupAvcSicGetMotionVectorMaskINTEL
        :value 5795
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Skip Block Partition Type"}
            {:kind :IdRef :name "Direction"}
        ]
    }
    :OpSubgroupAvcSicConvertToMcePayloadINTEL {
        :tag :OpSubgroupAvcSicConvertToMcePayloadINTEL
        :value 5796
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetIntraLumaShapePenaltyINTEL {
        :tag :OpSubgroupAvcSicSetIntraLumaShapePenaltyINTEL
        :value 5797
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Shape Penalty"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetIntraLumaModeCostFunctionINTEL {
        :tag :OpSubgroupAvcSicSetIntraLumaModeCostFunctionINTEL
        :value 5798
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Luma Mode Penalty"}
            {:kind :IdRef :name "Luma Packed Neighbor Modes"}
            {:kind :IdRef :name "Luma Packed Non Dc Penalty"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetIntraChromaModeCostFunctionINTEL {
        :tag :OpSubgroupAvcSicSetIntraChromaModeCostFunctionINTEL
        :value 5799
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationChromaINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Chroma Mode Base Penalty"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetBilinearFilterEnableINTEL {
        :tag :OpSubgroupAvcSicSetBilinearFilterEnableINTEL
        :value 5800
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetSkcForwardTransformEnableINTEL {
        :tag :OpSubgroupAvcSicSetSkcForwardTransformEnableINTEL
        :value 5801
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packed Sad Coefficients"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicSetBlockBasedRawSkipSadINTEL {
        :tag :OpSubgroupAvcSicSetBlockBasedRawSkipSadINTEL
        :value 5802
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Block Based Skip Type"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicEvaluateIpeINTEL {
        :tag :OpSubgroupAvcSicEvaluateIpeINTEL
        :value 5803
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicEvaluateWithSingleReferenceINTEL {
        :tag :OpSubgroupAvcSicEvaluateWithSingleReferenceINTEL
        :value 5804
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicEvaluateWithDualReferenceINTEL {
        :tag :OpSubgroupAvcSicEvaluateWithDualReferenceINTEL
        :value 5805
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Fwd Ref Image"}
            {:kind :IdRef :name "Bwd Ref Image"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicEvaluateWithMultiReferenceINTEL {
        :tag :OpSubgroupAvcSicEvaluateWithMultiReferenceINTEL
        :value 5806
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Packed Reference Ids"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicEvaluateWithMultiReferenceInterlacedINTEL {
        :tag :OpSubgroupAvcSicEvaluateWithMultiReferenceInterlacedINTEL
        :value 5807
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Src Image"}
            {:kind :IdRef :name "Packed Reference Ids"}
            {:kind :IdRef :name "Packed Reference Field Polarities"}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicConvertToMceResultINTEL {
        :tag :OpSubgroupAvcSicConvertToMceResultINTEL
        :value 5808
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetIpeLumaShapeINTEL {
        :tag :OpSubgroupAvcSicGetIpeLumaShapeINTEL
        :value 5809
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetBestIpeLumaDistortionINTEL {
        :tag :OpSubgroupAvcSicGetBestIpeLumaDistortionINTEL
        :value 5810
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetBestIpeChromaDistortionINTEL {
        :tag :OpSubgroupAvcSicGetBestIpeChromaDistortionINTEL
        :value 5811
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetPackedIpeLumaModesINTEL {
        :tag :OpSubgroupAvcSicGetPackedIpeLumaModesINTEL
        :value 5812
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetIpeChromaModeINTEL {
        :tag :OpSubgroupAvcSicGetIpeChromaModeINTEL
        :value 5813
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationChromaINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetPackedSkcLumaCountThresholdINTEL {
        :tag :OpSubgroupAvcSicGetPackedSkcLumaCountThresholdINTEL
        :value 5814
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetPackedSkcLumaSumThresholdINTEL {
        :tag :OpSubgroupAvcSicGetPackedSkcLumaSumThresholdINTEL
        :value 5815
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
            :SubgroupAvcMotionEstimationIntraINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpSubgroupAvcSicGetInterRawSadsINTEL {
        :tag :OpSubgroupAvcSicGetInterRawSadsINTEL
        :value 5816
        :capabilities [
            :SubgroupAvcMotionEstimationINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Payload"}
        ]
    }
    :OpVariableLengthArrayINTEL {
        :tag :OpVariableLengthArrayINTEL
        :value 5818
        :capabilities [
            :VariableLengthArrayINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Lenght"}
        ]
    }
    :OpSaveMemoryINTEL {
        :tag :OpSaveMemoryINTEL
        :value 5819
        :capabilities [
            :VariableLengthArrayINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
        ]
    }
    :OpRestoreMemoryINTEL {
        :tag :OpRestoreMemoryINTEL
        :value 5820
        :capabilities [
            :VariableLengthArrayINTEL
        ]
        :operands [
            {:kind :IdRef :name "Ptr"}
        ]
    }
    :OpArbitraryFloatSinCosPiINTEL {
        :tag :OpArbitraryFloatSinCosPiINTEL
        :value 5840
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "FromSign"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCastINTEL {
        :tag :OpArbitraryFloatCastINTEL
        :value 5841
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCastFromIntINTEL {
        :tag :OpArbitraryFloatCastFromIntINTEL
        :value 5842
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "FromSign"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCastToIntINTEL {
        :tag :OpArbitraryFloatCastToIntINTEL
        :value 5843
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatAddINTEL {
        :tag :OpArbitraryFloatAddINTEL
        :value 5846
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatSubINTEL {
        :tag :OpArbitraryFloatSubINTEL
        :value 5847
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatMulINTEL {
        :tag :OpArbitraryFloatMulINTEL
        :value 5848
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatDivINTEL {
        :tag :OpArbitraryFloatDivINTEL
        :value 5849
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatGTINTEL {
        :tag :OpArbitraryFloatGTINTEL
        :value 5850
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
        ]
    }
    :OpArbitraryFloatGEINTEL {
        :tag :OpArbitraryFloatGEINTEL
        :value 5851
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
        ]
    }
    :OpArbitraryFloatLTINTEL {
        :tag :OpArbitraryFloatLTINTEL
        :value 5852
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
        ]
    }
    :OpArbitraryFloatLEINTEL {
        :tag :OpArbitraryFloatLEINTEL
        :value 5853
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
        ]
    }
    :OpArbitraryFloatEQINTEL {
        :tag :OpArbitraryFloatEQINTEL
        :value 5854
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
        ]
    }
    :OpArbitraryFloatRecipINTEL {
        :tag :OpArbitraryFloatRecipINTEL
        :value 5855
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatRSqrtINTEL {
        :tag :OpArbitraryFloatRSqrtINTEL
        :value 5856
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCbrtINTEL {
        :tag :OpArbitraryFloatCbrtINTEL
        :value 5857
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatHypotINTEL {
        :tag :OpArbitraryFloatHypotINTEL
        :value 5858
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatSqrtINTEL {
        :tag :OpArbitraryFloatSqrtINTEL
        :value 5859
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatLogINTEL {
        :tag :OpArbitraryFloatLogINTEL
        :value 5860
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatLog2INTEL {
        :tag :OpArbitraryFloatLog2INTEL
        :value 5861
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatLog10INTEL {
        :tag :OpArbitraryFloatLog10INTEL
        :value 5862
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatLog1pINTEL {
        :tag :OpArbitraryFloatLog1pINTEL
        :value 5863
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatExpINTEL {
        :tag :OpArbitraryFloatExpINTEL
        :value 5864
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatExp2INTEL {
        :tag :OpArbitraryFloatExp2INTEL
        :value 5865
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatExp10INTEL {
        :tag :OpArbitraryFloatExp10INTEL
        :value 5866
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatExpm1INTEL {
        :tag :OpArbitraryFloatExpm1INTEL
        :value 5867
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatSinINTEL {
        :tag :OpArbitraryFloatSinINTEL
        :value 5868
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCosINTEL {
        :tag :OpArbitraryFloatCosINTEL
        :value 5869
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatSinCosINTEL {
        :tag :OpArbitraryFloatSinCosINTEL
        :value 5870
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatSinPiINTEL {
        :tag :OpArbitraryFloatSinPiINTEL
        :value 5871
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatCosPiINTEL {
        :tag :OpArbitraryFloatCosPiINTEL
        :value 5872
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatASinINTEL {
        :tag :OpArbitraryFloatASinINTEL
        :value 5873
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatASinPiINTEL {
        :tag :OpArbitraryFloatASinPiINTEL
        :value 5874
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatACosINTEL {
        :tag :OpArbitraryFloatACosINTEL
        :value 5875
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatACosPiINTEL {
        :tag :OpArbitraryFloatACosPiINTEL
        :value 5876
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatATanINTEL {
        :tag :OpArbitraryFloatATanINTEL
        :value 5877
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatATanPiINTEL {
        :tag :OpArbitraryFloatATanPiINTEL
        :value 5878
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatATan2INTEL {
        :tag :OpArbitraryFloatATan2INTEL
        :value 5879
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatPowINTEL {
        :tag :OpArbitraryFloatPowINTEL
        :value 5880
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatPowRINTEL {
        :tag :OpArbitraryFloatPowRINTEL
        :value 5881
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "M2"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpArbitraryFloatPowNINTEL {
        :tag :OpArbitraryFloatPowNINTEL
        :value 5882
        :capabilities [
            :ArbitraryPrecisionFloatingPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "A"}
            {:kind :LiteralInteger :name "M1"}
            {:kind :IdRef :name "B"}
            {:kind :LiteralInteger :name "Mout"}
            {:kind :LiteralInteger :name "EnableSubnormals"}
            {:kind :LiteralInteger :name "RoundingMode"}
            {:kind :LiteralInteger :name "RoundingAccuracy"}
        ]
    }
    :OpLoopControlINTEL {
        :tag :OpLoopControlINTEL
        :value 5887
        :extensions [
            :SPV_INTEL_unstructured_loop_controls
        ]
        :capabilities [
            :UnstructuredLoopControlsINTEL
        ]
        :operands [
            {:kind :LiteralInteger :quantifier :* :name "Loop Control Parameters"}
        ]
    }
    :OpAliasDomainDeclINTEL {
        :tag :OpAliasDomainDeclINTEL
        :value 5911
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :quantifier :? :name "Name"}
        ]
    }
    :OpAliasScopeDeclINTEL {
        :tag :OpAliasScopeDeclINTEL
        :value 5912
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :name "Alias Domain"}
            {:kind :IdRef :quantifier :? :name "Name"}
        ]
    }
    :OpAliasScopeListDeclINTEL {
        :tag :OpAliasScopeListDeclINTEL
        :value 5913
        :extensions [
            :SPV_INTEL_memory_access_aliasing
        ]
        :capabilities [
            :MemoryAccessAliasingINTEL
        ]
        :operands [
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "AliasScope1, AliasScope2, ..."}
        ]
    }
    :OpFixedSqrtINTEL {
        :tag :OpFixedSqrtINTEL
        :value 5923
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedRecipINTEL {
        :tag :OpFixedRecipINTEL
        :value 5924
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedRsqrtINTEL {
        :tag :OpFixedRsqrtINTEL
        :value 5925
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedSinINTEL {
        :tag :OpFixedSinINTEL
        :value 5926
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedCosINTEL {
        :tag :OpFixedCosINTEL
        :value 5927
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedSinCosINTEL {
        :tag :OpFixedSinCosINTEL
        :value 5928
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedSinPiINTEL {
        :tag :OpFixedSinPiINTEL
        :value 5929
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedCosPiINTEL {
        :tag :OpFixedCosPiINTEL
        :value 5930
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedSinCosPiINTEL {
        :tag :OpFixedSinCosPiINTEL
        :value 5931
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedLogINTEL {
        :tag :OpFixedLogINTEL
        :value 5932
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpFixedExpINTEL {
        :tag :OpFixedExpINTEL
        :value 5933
        :capabilities [
            :ArbitraryPrecisionFixedPointINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Input Type"}
            {:kind :IdRef :name "Input"}
            {:kind :LiteralInteger :name "S"}
            {:kind :LiteralInteger :name "I"}
            {:kind :LiteralInteger :name "rI"}
            {:kind :LiteralInteger :name "Q"}
            {:kind :LiteralInteger :name "O"}
        ]
    }
    :OpPtrCastToCrossWorkgroupINTEL {
        :tag :OpPtrCastToCrossWorkgroupINTEL
        :value 5934
        :capabilities [
            :USMStorageClassesINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpCrossWorkgroupCastToPtrINTEL {
        :tag :OpCrossWorkgroupCastToPtrINTEL
        :value 5938
        :capabilities [
            :USMStorageClassesINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
        ]
    }
    :OpReadPipeBlockingINTEL {
        :tag :OpReadPipeBlockingINTEL
        :value 5946
        :extensions [
            :SPV_INTEL_blocking_pipes
        ]
        :capabilities [
            :BlockingPipesINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpWritePipeBlockingINTEL {
        :tag :OpWritePipeBlockingINTEL
        :value 5947
        :extensions [
            :SPV_INTEL_blocking_pipes
        ]
        :capabilities [
            :BlockingPipesINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Packet Size"}
            {:kind :IdRef :name "Packet Alignment"}
        ]
    }
    :OpFPGARegINTEL {
        :tag :OpFPGARegINTEL
        :value 5949
        :extensions [
            :SPV_INTEL_fpga_reg
        ]
        :capabilities [
            :FPGARegINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Result"}
            {:kind :IdRef :name "Input"}
        ]
    }
    :OpRayQueryGetRayTMinKHR {
        :tag :OpRayQueryGetRayTMinKHR
        :value 6016
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetRayFlagsKHR {
        :tag :OpRayQueryGetRayFlagsKHR
        :value 6017
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetIntersectionTKHR {
        :tag :OpRayQueryGetIntersectionTKHR
        :value 6018
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionInstanceCustomIndexKHR {
        :tag :OpRayQueryGetIntersectionInstanceCustomIndexKHR
        :value 6019
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionInstanceIdKHR {
        :tag :OpRayQueryGetIntersectionInstanceIdKHR
        :value 6020
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionInstanceShaderBindingTableRecordOffsetKHR {
        :tag :OpRayQueryGetIntersectionInstanceShaderBindingTableRecordOffsetKHR
        :value 6021
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionGeometryIndexKHR {
        :tag :OpRayQueryGetIntersectionGeometryIndexKHR
        :value 6022
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionPrimitiveIndexKHR {
        :tag :OpRayQueryGetIntersectionPrimitiveIndexKHR
        :value 6023
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionBarycentricsKHR {
        :tag :OpRayQueryGetIntersectionBarycentricsKHR
        :value 6024
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionFrontFaceKHR {
        :tag :OpRayQueryGetIntersectionFrontFaceKHR
        :value 6025
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionCandidateAABBOpaqueKHR {
        :tag :OpRayQueryGetIntersectionCandidateAABBOpaqueKHR
        :value 6026
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetIntersectionObjectRayDirectionKHR {
        :tag :OpRayQueryGetIntersectionObjectRayDirectionKHR
        :value 6027
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionObjectRayOriginKHR {
        :tag :OpRayQueryGetIntersectionObjectRayOriginKHR
        :value 6028
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetWorldRayDirectionKHR {
        :tag :OpRayQueryGetWorldRayDirectionKHR
        :value 6029
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetWorldRayOriginKHR {
        :tag :OpRayQueryGetWorldRayOriginKHR
        :value 6030
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
        ]
    }
    :OpRayQueryGetIntersectionObjectToWorldKHR {
        :tag :OpRayQueryGetIntersectionObjectToWorldKHR
        :value 6031
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpRayQueryGetIntersectionWorldToObjectKHR {
        :tag :OpRayQueryGetIntersectionWorldToObjectKHR
        :value 6032
        :extensions [
            :SPV_KHR_ray_query
        ]
        :capabilities [
            :RayQueryKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "RayQuery"}
            {:kind :IdRef :name "Intersection"}
        ]
    }
    :OpAtomicFAddEXT {
        :tag :OpAtomicFAddEXT
        :value 6035
        :extensions [
            :SPV_EXT_shader_atomic_float_add
        ]
        :capabilities [
            :AtomicFloat16AddEXT
            :AtomicFloat32AddEXT
            :AtomicFloat64AddEXT
            :AtomicFloat16VectorNV
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Pointer"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
            {:kind :IdRef :name "Value"}
        ]
    }
    :OpTypeBufferSurfaceINTEL {
        :tag :OpTypeBufferSurfaceINTEL
        :value 6086
        :capabilities [
            :VectorComputeINTEL
        ]
        :operands [
            {:kind :IdResult}
            {:kind :AccessQualifier :name "AccessQualifier"}
        ]
    }
    :OpTypeStructContinuedINTEL {
        :tag :OpTypeStructContinuedINTEL
        :value 6090
        :capabilities [
            :LongCompositesINTEL
        ]
        :operands [
            {:kind :IdRef :quantifier :* :name "Member 0 type, + member 1 type, + ..."}
        ]
    }
    :OpConstantCompositeContinuedINTEL {
        :tag :OpConstantCompositeContinuedINTEL
        :value 6091
        :capabilities [
            :LongCompositesINTEL
        ]
        :operands [
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpSpecConstantCompositeContinuedINTEL {
        :tag :OpSpecConstantCompositeContinuedINTEL
        :value 6092
        :capabilities [
            :LongCompositesINTEL
        ]
        :operands [
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpCompositeConstructContinuedINTEL {
        :tag :OpCompositeConstructContinuedINTEL
        :value 6096
        :capabilities [
            :LongCompositesINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :quantifier :* :name "Constituents"}
        ]
    }
    :OpConvertFToBF16INTEL {
        :tag :OpConvertFToBF16INTEL
        :value 6116
        :capabilities [
            :BFloat16ConversionINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "Float Value"}
        ]
    }
    :OpConvertBF16ToFINTEL {
        :tag :OpConvertBF16ToFINTEL
        :value 6117
        :capabilities [
            :BFloat16ConversionINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "BFloat16 Value"}
        ]
    }
    :OpControlBarrierArriveINTEL {
        :tag :OpControlBarrierArriveINTEL
        :value 6142
        :capabilities [
            :SplitBarrierINTEL
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpControlBarrierWaitINTEL {
        :tag :OpControlBarrierWaitINTEL
        :value 6143
        :capabilities [
            :SplitBarrierINTEL
        ]
        :operands [
            {:kind :IdScope :name "Execution"}
            {:kind :IdScope :name "Memory"}
            {:kind :IdMemorySemantics :name "Semantics"}
        ]
    }
    :OpGroupIMulKHR {
        :tag :OpGroupIMulKHR
        :value 6401
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupFMulKHR {
        :tag :OpGroupFMulKHR
        :value 6402
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupBitwiseAndKHR {
        :tag :OpGroupBitwiseAndKHR
        :value 6403
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupBitwiseOrKHR {
        :tag :OpGroupBitwiseOrKHR
        :value 6404
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupBitwiseXorKHR {
        :tag :OpGroupBitwiseXorKHR
        :value 6405
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupLogicalAndKHR {
        :tag :OpGroupLogicalAndKHR
        :value 6406
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupLogicalOrKHR {
        :tag :OpGroupLogicalOrKHR
        :value 6407
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpGroupLogicalXorKHR {
        :tag :OpGroupLogicalXorKHR
        :value 6408
        :capabilities [
            :GroupUniformArithmeticKHR
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdScope :name "Execution"}
            {:kind :GroupOperation :name "Operation"}
            {:kind :IdRef :name "X"}
        ]
    }
    :OpMaskedGatherINTEL {
        :tag :OpMaskedGatherINTEL
        :value 6428
        :capabilities [
            :MaskedGatherScatterINTEL
        ]
        :operands [
            {:kind :IdResultType}
            {:kind :IdResult}
            {:kind :IdRef :name "PtrVector"}
            {:kind :LiteralInteger :name "Alignment"}
            {:kind :IdRef :name "Mask"}
            {:kind :IdRef :name "FillEmpty"}
        ]
    }
    :OpMaskedScatterINTEL {
        :tag :OpMaskedScatterINTEL
        :value 6429
        :capabilities [
            :MaskedGatherScatterINTEL
        ]
        :operands [
            {:kind :IdRef :name "InputVector"}
            {:kind :IdRef :name "PtrVector"}
            {:kind :LiteralInteger :name "Alignment"}
            {:kind :IdRef :name "Mask"}
        ]
    }
}))

(set Op.enumerants.OpSDotKHR Op.enumerants.OpSDot)
(set Op.enumerants.OpUDotKHR Op.enumerants.OpUDot)
(set Op.enumerants.OpSUDotKHR Op.enumerants.OpSUDot)
(set Op.enumerants.OpSDotAccSatKHR Op.enumerants.OpSDotAccSat)
(set Op.enumerants.OpUDotAccSatKHR Op.enumerants.OpUDotAccSat)
(set Op.enumerants.OpSUDotAccSatKHR Op.enumerants.OpSUDotAccSat)
(set Op.enumerants.OpReportIntersectionNV Op.enumerants.OpReportIntersectionKHR)
(set Op.enumerants.OpTypeAccelerationStructureNV Op.enumerants.OpTypeAccelerationStructureKHR)
(set Op.enumerants.OpDemoteToHelperInvocationEXT Op.enumerants.OpDemoteToHelperInvocation)
(set Op.enumerants.OpDecorateStringGOOGLE Op.enumerants.OpDecorateString)
(set Op.enumerants.OpMemberDecorateStringGOOGLE Op.enumerants.OpMemberDecorateString)


(local ExtGLSL (mk-enum :ExtGLSL :ext {
    :Round {
        :tag :Round
        :value 1
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :RoundEven {
        :tag :RoundEven
        :value 2
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Trunc {
        :tag :Trunc
        :value 3
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :FAbs {
        :tag :FAbs
        :value 4
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :SAbs {
        :tag :SAbs
        :value 5
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :FSign {
        :tag :FSign
        :value 6
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :SSign {
        :tag :SSign
        :value 7
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Floor {
        :tag :Floor
        :value 8
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Ceil {
        :tag :Ceil
        :value 9
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Fract {
        :tag :Fract
        :value 10
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Radians {
        :tag :Radians
        :value 11
        :operands [
            {:kind :IdRef :name "degrees"}
        ]
    }
    :Degrees {
        :tag :Degrees
        :value 12
        :operands [
            {:kind :IdRef :name "radians"}
        ]
    }
    :Sin {
        :tag :Sin
        :value 13
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Cos {
        :tag :Cos
        :value 14
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Tan {
        :tag :Tan
        :value 15
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Asin {
        :tag :Asin
        :value 16
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Acos {
        :tag :Acos
        :value 17
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Atan {
        :tag :Atan
        :value 18
        :operands [
            {:kind :IdRef :name "y_over_x"}
        ]
    }
    :Sinh {
        :tag :Sinh
        :value 19
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Cosh {
        :tag :Cosh
        :value 20
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Tanh {
        :tag :Tanh
        :value 21
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Asinh {
        :tag :Asinh
        :value 22
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Acosh {
        :tag :Acosh
        :value 23
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Atanh {
        :tag :Atanh
        :value 24
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Atan2 {
        :tag :Atan2
        :value 25
        :operands [
            {:kind :IdRef :name "y"}
            {:kind :IdRef :name "x"}
        ]
    }
    :Pow {
        :tag :Pow
        :value 26
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :Exp {
        :tag :Exp
        :value 27
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Log {
        :tag :Log
        :value 28
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Exp2 {
        :tag :Exp2
        :value 29
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Log2 {
        :tag :Log2
        :value 30
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Sqrt {
        :tag :Sqrt
        :value 31
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :InverseSqrt {
        :tag :InverseSqrt
        :value 32
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Determinant {
        :tag :Determinant
        :value 33
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :MatrixInverse {
        :tag :MatrixInverse
        :value 34
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Modf {
        :tag :Modf
        :value 35
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "i"}
        ]
    }
    :ModfStruct {
        :tag :ModfStruct
        :value 36
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :FMin {
        :tag :FMin
        :value 37
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :UMin {
        :tag :UMin
        :value 38
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :SMin {
        :tag :SMin
        :value 39
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :FMax {
        :tag :FMax
        :value 40
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :UMax {
        :tag :UMax
        :value 41
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :SMax {
        :tag :SMax
        :value 42
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :FClamp {
        :tag :FClamp
        :value 43
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "minVal"}
            {:kind :IdRef :name "maxVal"}
        ]
    }
    :UClamp {
        :tag :UClamp
        :value 44
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "minVal"}
            {:kind :IdRef :name "maxVal"}
        ]
    }
    :SClamp {
        :tag :SClamp
        :value 45
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "minVal"}
            {:kind :IdRef :name "maxVal"}
        ]
    }
    :FMix {
        :tag :FMix
        :value 46
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
            {:kind :IdRef :name "a"}
        ]
    }
    :IMix {
        :tag :IMix
        :value 47
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
            {:kind :IdRef :name "a"}
        ]
    }
    :Step {
        :tag :Step
        :value 48
        :operands [
            {:kind :IdRef :name "edge"}
            {:kind :IdRef :name "x"}
        ]
    }
    :SmoothStep {
        :tag :SmoothStep
        :value 49
        :operands [
            {:kind :IdRef :name "edge0"}
            {:kind :IdRef :name "edge1"}
            {:kind :IdRef :name "x"}
        ]
    }
    :Fma {
        :tag :Fma
        :value 50
        :operands [
            {:kind :IdRef :name "a"}
            {:kind :IdRef :name "b"}
            {:kind :IdRef :name "c"}
        ]
    }
    :Frexp {
        :tag :Frexp
        :value 51
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "exp"}
        ]
    }
    :FrexpStruct {
        :tag :FrexpStruct
        :value 52
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Ldexp {
        :tag :Ldexp
        :value 53
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "exp"}
        ]
    }
    :PackSnorm4x8 {
        :tag :PackSnorm4x8
        :value 54
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :PackUnorm4x8 {
        :tag :PackUnorm4x8
        :value 55
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :PackSnorm2x16 {
        :tag :PackSnorm2x16
        :value 56
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :PackUnorm2x16 {
        :tag :PackUnorm2x16
        :value 57
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :PackHalf2x16 {
        :tag :PackHalf2x16
        :value 58
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :PackDouble2x32 {
        :tag :PackDouble2x32
        :value 59
        :capabilities [
            :Float64
        ]
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :UnpackSnorm2x16 {
        :tag :UnpackSnorm2x16
        :value 60
        :operands [
            {:kind :IdRef :name "p"}
        ]
    }
    :UnpackUnorm2x16 {
        :tag :UnpackUnorm2x16
        :value 61
        :operands [
            {:kind :IdRef :name "p"}
        ]
    }
    :UnpackHalf2x16 {
        :tag :UnpackHalf2x16
        :value 62
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :UnpackSnorm4x8 {
        :tag :UnpackSnorm4x8
        :value 63
        :operands [
            {:kind :IdRef :name "p"}
        ]
    }
    :UnpackUnorm4x8 {
        :tag :UnpackUnorm4x8
        :value 64
        :operands [
            {:kind :IdRef :name "p"}
        ]
    }
    :UnpackDouble2x32 {
        :tag :UnpackDouble2x32
        :value 65
        :capabilities [
            :Float64
        ]
        :operands [
            {:kind :IdRef :name "v"}
        ]
    }
    :Length {
        :tag :Length
        :value 66
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :Distance {
        :tag :Distance
        :value 67
        :operands [
            {:kind :IdRef :name "p0"}
            {:kind :IdRef :name "p1"}
        ]
    }
    :Cross {
        :tag :Cross
        :value 68
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :Normalize {
        :tag :Normalize
        :value 69
        :operands [
            {:kind :IdRef :name "x"}
        ]
    }
    :FaceForward {
        :tag :FaceForward
        :value 70
        :operands [
            {:kind :IdRef :name "N"}
            {:kind :IdRef :name "I"}
            {:kind :IdRef :name "Nref"}
        ]
    }
    :Reflect {
        :tag :Reflect
        :value 71
        :operands [
            {:kind :IdRef :name "I"}
            {:kind :IdRef :name "N"}
        ]
    }
    :Refract {
        :tag :Refract
        :value 72
        :operands [
            {:kind :IdRef :name "I"}
            {:kind :IdRef :name "N"}
            {:kind :IdRef :name "eta"}
        ]
    }
    :FindILsb {
        :tag :FindILsb
        :value 73
        :operands [
            {:kind :IdRef :name "Value"}
        ]
    }
    :FindSMsb {
        :tag :FindSMsb
        :value 74
        :operands [
            {:kind :IdRef :name "Value"}
        ]
    }
    :FindUMsb {
        :tag :FindUMsb
        :value 75
        :operands [
            {:kind :IdRef :name "Value"}
        ]
    }
    :InterpolateAtCentroid {
        :tag :InterpolateAtCentroid
        :value 76
        :capabilities [
            :InterpolationFunction
        ]
        :operands [
            {:kind :IdRef :name "interpolant"}
        ]
    }
    :InterpolateAtSample {
        :tag :InterpolateAtSample
        :value 77
        :capabilities [
            :InterpolationFunction
        ]
        :operands [
            {:kind :IdRef :name "interpolant"}
            {:kind :IdRef :name "sample"}
        ]
    }
    :InterpolateAtOffset {
        :tag :InterpolateAtOffset
        :value 78
        :capabilities [
            :InterpolationFunction
        ]
        :operands [
            {:kind :IdRef :name "interpolant"}
            {:kind :IdRef :name "offset"}
        ]
    }
    :NMin {
        :tag :NMin
        :value 79
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :NMax {
        :tag :NMax
        :value 80
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "y"}
        ]
    }
    :NClamp {
        :tag :NClamp
        :value 81
        :operands [
            {:kind :IdRef :name "x"}
            {:kind :IdRef :name "minVal"}
            {:kind :IdRef :name "maxVal"}
        ]
    }
}))


{
    : ImageOperands
    : FPFastMathMode
    : SelectionControl
    : LoopControl
    : FunctionControl
    : MemorySemantics
    : MemoryAccess
    : KernelProfilingInfo
    : RayFlags
    : FragmentShadingRate
    : RawAccessChainOperands
    : SourceLanguage
    : ExecutionModel
    : AddressingModel
    : MemoryModel
    : ExecutionMode
    : StorageClass
    : Dim
    : SamplerAddressingMode
    : SamplerFilterMode
    : ImageFormat
    : ImageChannelOrder
    : ImageChannelDataType
    : FPRoundingMode
    : FPDenormMode
    : QuantizationModes
    : FPOperationMode
    : OverflowModes
    : LinkageType
    : AccessQualifier
    : HostAccessQualifier
    : FunctionParameterAttribute
    : Decoration
    : BuiltIn
    : Scope
    : GroupOperation
    : KernelEnqueueFlags
    : Capability
    : RayQueryIntersection
    : RayQueryCommittedIntersectionType
    : RayQueryCandidateIntersectionType
    : PackedVectorFormat
    : CooperativeMatrixOperands
    : CooperativeMatrixLayout
    : CooperativeMatrixUse
    : InitializationModeQualifier
    : LoadCacheControl
    : StoreCacheControl
    : NamedMaximumNumberOfRegisters
    : Op
    : SpecConstantOp
    :LiteralSpecConstantOpInteger SpecConstantOp
    : ExtGLSL
    : magic-number
    : major-version
    : minor-version
    : version
    : revision
}
