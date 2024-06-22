#version 460
#extension GL_EXT_scalar_block_layout : require
#extension GL_NV_shader_subgroup_partitioned : require
#extension GL_ARB_sparse_texture2 : require

layout (set=0, binding=0) uniform sampler2D texture;
layout (set=0, binding=1) uniform Data { int values[]; } data[3];


layout (location=0) in vec4 inColor;
layout (location=1) in vec2 inUV;

layout (location=0) out vec4 outColor;

layout (push_constant, scalar) uniform Foo {
    vec3 a;
    mat4 matrices[2][2];
};


void main ()
{   
    uvec4 p = subgroupPartitionNV(inColor);
    outColor = subgroupPartitionedInclusiveAddNV(inColor, p);

    vec4 texel;
    if (sparseTexelsResidentARB(sparseTextureARB(texture, inUV, texel)))
        outColor += texel;
}