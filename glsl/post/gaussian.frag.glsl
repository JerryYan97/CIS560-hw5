#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

// Gaussian Kernel
uniform float weight[11 * 11] = float[](
0.006849,	0.007239,	0.007559,	0.007795,	0.007941,	0.00799,	0.007941,	0.007795,
0.007559,	0.007239,	0.006849,
0.007239,	0.007653,	0.00799,        0.00824,        0.008394,	0.008446,	0.008394,	0.00824,
0.00799,	0.007653,	0.007239,
0.007559,	0.00799,        0.008342,	0.008604,	0.008764,	0.008819,	0.008764,	0.008604,
0.008342,	0.00799,	0.007559,
0.007795,	0.00824,        0.008604,	0.008873,	0.009039,	0.009095,	0.009039,	0.008873,
0.008604,	0.00824,	0.007795,
0.007941,	0.008394,	0.008764,	0.009039,	0.009208,	0.009265,	0.009208,	0.009039,
0.008764,	0.008394,	0.007941,
0.00799,	0.008446,	0.008819,	0.009095,	0.009265,	0.009322,	0.009265,	0.009095,
0.008819,	0.008446,	0.00799,
0.007941,	0.008394,	0.008764,	0.009039,	0.009208,	0.009265,	0.009208,	0.009039,
0.008764,	0.008394,	0.007941,
0.007795,	0.00824,        0.008604,	0.008873,	0.009039,	0.009095,	0.009039,	0.008873,
0.008604,	0.00824,	0.007795,
0.007559,	0.00799,        0.008342,	0.008604,	0.008764,	0.008819,	0.008764,	0.008604,
0.008342,	0.00799,	0.007559,
0.007239,	0.007653,	0.00799,        0.00824,        0.008394,	0.008446,	0.008394,	0.00824,
0.00799,	0.007653,	0.007239,
0.006849,	0.007239,	0.007559,	0.007795,	0.007941,	0.00799,	0.007941,	0.007795,
0.007559,	0.007239,	0.006849);

// row = [0, 10], col = [0, 10]
float GetWeight(int row, int col)
{
    return weight[row * 11 + col];
}

// Input the kernel pos, current fragment uv pos and texel size. Return the uv pos at the tar kernel pos
vec2 GetUVPos(ivec2 kernelPos, vec2 texelSize, vec2 currentFragUVPos)
{
    // Init tar uv pos
    vec2 tUVPos = vec2(0, 0);

    // get the relative kernel pos
    ivec2 tRelativeKernelPos = kernelPos - ivec2(5, 5);

    // get the uv pos kernel pos
    tUVPos.x = currentFragUVPos.x + tRelativeKernelPos.x * texelSize.x;
    tUVPos.y = currentFragUVPos.y + tRelativeKernelPos.y * texelSize.y;

    return tUVPos;
}

void main()
{
    // TODO Homework 5
    // texel_size in the coord of uv
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);

    // weighted color of the current texel
    //vec3 resColor = vec3(GetWeight(5, 5) * texture(u_RenderedTexture, fs_UV));
    vec3 resColor = vec3(0, 0, 0);
    
    // accumulate the surrounded texel color 
    for(int row = 0; row <= 10; row++)
    {
        for(int col = 0; col <= 10; col++)
        {
            // get the uv pos of the target surrounded texel
            vec2 tUVPos = GetUVPos(ivec2(row, col), texel_size, fs_UV);

            // get the weighted color of the target surrounded texel
            // get the weight of the color
            float tWeight = GetWeight(row, col);
            // get the weighted color
            vec3 tWeightColor = vec3(tWeight * texture(u_RenderedTexture, tUVPos));

            // add this target surrounded texel color to the resCol
            resColor += tWeightColor;
        }
    }

    color = resColor;
}
