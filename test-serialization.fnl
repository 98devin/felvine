
(local base (include :base))
(local types (include :spirv))

(local
    { : serialize
      : serializable-with-fmt
      : serialize-tmp
      : serialize-tmp-with
      : serialize-list
      : SpirvHeader
    } base)

(local
    { : AddressingModel
      : BuiltIn
      : Capability
      : Decoration
      : Dim
      : ExecutionModel
      : ExecutionMode
      : ExtGLSL
      : FunctionControl
      : ImageFormat
      : MemoryModel
      : Op
      : SourceLanguage
      : StorageClass
    } types)

(local spv-list [
    (SpirvHeader.new { :identifierBound 100 })
    ; mode setting
    (Op.OpCapability Capability.Shader)
    (Op.OpCapability Capability.StorageUniformBufferBlock16)
    (Op.OpExtInstImport 1 :GLSL.std.450)
    (Op.OpMemoryModel AddressingModel.Logical MemoryModel.GLSL450)
    (Op.OpEntryPoint ExecutionModel.Fragment 4 :main [11 15 21 40 43])
    (Op.OpExecutionMode 4 ExecutionMode.OriginUpperLeft)
    
    ; debug information
    (Op.OpSource SourceLanguage.GLSL 460)
    (Op.OpName 8 :sdfValue)
    (Op.OpName 11 :glyphAtlas)
    (Op.OpName 15 :glyphSampler)
    (Op.OpName 21 :vertexUV)
    (Op.OpName 28 :edgeWidth)
    (Op.OpName 31 :smoothedValue)
    (Op.OpName 40 :fragColor)
    (Op.OpName 43 :vertexColor)
    
    ; annotations
    (Op.OpDecorate 11 (Decoration.DescriptorSet 0))
    (Op.OpDecorate 11 (Decoration.Binding 1))
    (Op.OpDecorate 15 (Decoration.DescriptorSet 0))
    (Op.OpDecorate 15 (Decoration.Binding 0))
    (Op.OpDecorate 21 (Decoration.Location 0))
    (Op.OpDecorate 40 (Decoration.Location 0))
    (Op.OpDecorate 43 (Decoration.Location 1))
    
    ; types variables and constants
    (Op.OpTypeVoid 2)
    (Op.OpTypeFunction 3 2 [])
    (Op.OpTypeFloat 6 32)
    (Op.OpTypePointer 7 StorageClass.Function 6)
    (Op.OpTypeImage 9 6 Dim.2D 0 0 0 1 ImageFormat.Unknown)
    (Op.OpTypePointer 10 StorageClass.UniformConstant 9)
    (Op.OpVariable 10 11 StorageClass.UniformConstant)
    (Op.OpTypeSampler 13)
    (Op.OpTypePointer 14 StorageClass.UniformConstant 13)
    (Op.OpVariable 14 15 StorageClass.UniformConstant)
    (Op.OpTypeSampledImage 17 9)
    (Op.OpTypeVector 19 6 2)
    (Op.OpTypePointer 20 StorageClass.Input 19)
    (Op.OpVariable 20 21 StorageClass.Input)
    (Op.OpTypeVector 23 6 4)
    (Op.OpTypeInt 25 32 0)
    (Op.OpConstant 25 26 (serializable-with-fmt "I" 0))
    (Op.OpConstant 6 32 (serializable-with-fmt "f" 0.5))
    (Op.OpTypePointer 39 StorageClass.Output 23)
    (Op.OpVariable 39 40 StorageClass.Output)
    (Op.OpTypePointer 42 StorageClass.Input 23)
    (Op.OpVariable 42 43 StorageClass.Input)

    ; function body
    (Op.OpFunction 2 4 (FunctionControl) 3)
        (Op.OpLabel 5)
        (Op.OpVariable 7 8 StorageClass.Function)
        (Op.OpVariable 7 28 StorageClass.Function)
        (Op.OpVariable 7 31 StorageClass.Function)
        (Op.OpLoad 9 12 11)
        (Op.OpLoad 13 16 15)
        (Op.OpSampledImage 17 18 12 16)
        (Op.OpLoad 19 22 21)
        (Op.OpImageSampleImplicitLod 23 24 18 22)
        (Op.OpCompositeExtract 6 27 24 [0])
        (Op.OpStore 8 27)
        (Op.OpLoad 6 29 8)
        (Op.OpFwidth 6 30 29)
        (Op.OpStore 28 30)
        (Op.OpLoad 6 33 28)
        (Op.OpFSub 6 34 32 33)
        (Op.OpLoad 6 35 28)
        (Op.OpFAdd 6 36 32 35)
        (Op.OpLoad 6 37 8)
        (Op.OpExtInst 6 38 1 (ExtGLSL.SmoothStep 34 36 37))
        (Op.OpStore 31 38)
        (Op.OpLoad 6 41 31)
        (Op.OpLoad 23 44 43)
        (Op.OpVectorTimesScalar 23 45 44 41)
        (Op.OpStore 40 45)
        Op.OpReturn
    Op.OpFunctionEnd
])

(each [i v (ipairs spv-list)]
    (print v))

(local buffer (serialize-tmp-with serialize-list spv-list))

(let [f (assert (io.open "out.spv" :wb))]
    (f:write (table.concat buffer))
    (f:close))