#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;


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

float noise1D( vec2 p ) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) *
                 43758.5453);
}

float interpNoise2D(float x, float y) {
    float intX = floor(x);
    float fractX = fract(x);
    float intY = floor(y);
    float fractY = fract(y);

    float v1 = noise1D(vec2(intX, intY));
    float v2 = noise1D(vec2(intX + 1, intY));
    float v3 = noise1D(vec2(intX, intY + 1));
    float v4 = noise1D(vec2(intX + 1, intY + 1));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    return mix(i1, i2, fractY);
}

float fbm(float x, float y) {
    float total = 0;
    float persistence = 0.5f;
    int octaves = 8;

    for(int i = 1; i <= octaves; i++) {
        float freq = pow(2.f, i);
        float amp = pow(persistence, i);

        total += interpNoise2D(x * freq,
                               y * freq) * amp;
    }
    return total;
}

float mNoiseGenerator(vec2 uv)
{
    // texel_size in the coord of uv
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);

    // weighted Gray value of the current texel in the Noise Map
    float resGrayValue = 0;

    // accumulate the surrounded texel Gray value in the Noise Map
    for(int row = 0; row <= 10; row++)
    {
        for(int col = 0; col <= 10; col++)
        {
            // get the uv pos of the target surrounded texel
            vec2 tUVPos = GetUVPos(ivec2(row, col), texel_size, fs_UV);

            // get the weighted Gray value of the target surrounded texel
            // get the weight of the Gray value
            float tWeight = GetWeight(row, col);
            // get the Gray value
            float tWeightGrayValue = tWeight * fbm(tUVPos.x, tUVPos.y);

            // add this target surrounded texel color to the resCol
            resGrayValue += tWeightGrayValue;
        }
    }
    return resGrayValue;
}

vec3 palette(float t)
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 0.5);
    vec3 d = vec3(0.80, 0.90, 0.30);

    return a + b*cos( 6.28318*(c*t+d) );
}

void main()
{
    float noiseVal = fbm(fs_UV.x, fs_UV.y);
    float thresholdColor = smoothstep(0, 40, u_Time / 100);
    float thresholdDiscard = thresholdColor - 0.03;

    if(thresholdColor > noiseVal)
    {
        if(thresholdDiscard > noiseVal)
        {
            discard;
        }
        color = palette(u_Time);
    }
    else{
      color = vec3(texture(u_RenderedTexture, fs_UV));
    }
}
