#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

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

float PeriodicallyLinearInterpolate(float i)
{
    float speedControler = 100;
    float val = mod(i, speedControler) / speedControler;
    return val;
}

bool InRange(float lineV, float range)
{
    float fragV = fs_UV.y;
    if(fragV >= (lineV - range) && fragV <= (lineV + range))
    {
        return true;
    }
    else{
        return false;
    }
}

void main()
{
    // get unit offset between each channel on the u axis
    float differU = 0.01;
    vec2 differUV = vec2(differU, 0);

    // get the flipped effect for the whole final image
    // this effect needs to change the differUV to an assigned value periodically
    // use sin() get a smooth periodically float, which is related to the input time.
    // this variable would change according to the input time, which is a uniform for all fragment shaders
    float smoothPeriodicallyFloat = sin(u_Time / 10);
    // use abs() to improve the frequency of the status that this value is larger than one target value
    smoothPeriodicallyFloat = abs(smoothPeriodicallyFloat);
    // use step() to get the value that can help us determine whether this image should be distorted at this time
    float flagVal = step(smoothPeriodicallyFloat, 0.6);
    // get a factor to enlarge the differUV, which can help us get the enlarged image
    float enlargeFactor = flagVal * 2;
    // change the differUV value
    differUV += vec2(differU * enlargeFactor, 0);

    // determine whether this texel should be distorted
    // get the v value of the line
    // this v value should repeatedly go from 0 to 1
    float lineV = PeriodicallyLinearInterpolate(u_Time);

    // get the range of the strip
    float range = 0.005;

    // a set of flags used to determine whether this texel stays in the range
    bool inRangeFlag1 = InRange(lineV, range);
    bool inRangeFlag2 = InRange(lineV - 27 * range, range - 0.002);
    bool inRangeFlag3 = InRange(lineV + 9 * range, range + 0.007);
    bool inRangeFlag4 = InRange(lineV + 86 * range, range + 0.011);
    bool inRangeFlag5 = InRange(lineV - 121 * range, range + 0.002);
    bool inRangeFlag6 = InRange(lineV + 51 * range, range - 0.003);
    bool inRangeFlag = inRangeFlag1 || inRangeFlag2 || inRangeFlag3 || inRangeFlag4 || inRangeFlag5 || inRangeFlag6;

    vec3 leftTextureColor, currentTextureColor, rightTextureColor;
    float redColor, greenColor, blueColor;
    if(inRangeFlag)
    {
        // larger distorted color extraction
        // used for the situation that this texel is in the range of a target line
        // enlarge the differUV
        differUV *= 1.5;
        // use fbm nose distort the uv pos to get a distorted color
        // get distorted relative offset
        float relativeOffset = fbm(fs_UV.x, fs_UV.y);
        vec2 distortedRelativeOffset = vec2(relativeOffset, relativeOffset);
        distortedRelativeOffset /= 10;
        // get the red color of the texel located at a unit offset left-handed
        leftTextureColor = vec3(texture(u_RenderedTexture, fs_UV - differUV + distortedRelativeOffset));
        redColor = leftTextureColor.r;
        // get the green color of the texel located at this position
        currentTextureColor = vec3(texture(u_RenderedTexture, fs_UV + distortedRelativeOffset));
        greenColor = currentTextureColor.g;
        // get the blue color of the texel located at a unit offset righ-handed
        rightTextureColor = vec3(texture(u_RenderedTexture, fs_UV + differUV + distortedRelativeOffset));
        blueColor = rightTextureColor.b;
    }
    else{
        // offsetted color extraction
        // used for normal situation
        // get the red color of the texel located at a unit offset left-handed
        leftTextureColor = vec3(texture(u_RenderedTexture, fs_UV - differUV));
        redColor = leftTextureColor.r;
        // get the green color of the texel located at this position
        currentTextureColor = vec3(texture(u_RenderedTexture, fs_UV));
        greenColor = currentTextureColor.g;
        // get the blue color of the texel located at a unit offset righ-handed
        rightTextureColor = vec3(texture(u_RenderedTexture, fs_UV + differUV));
        blueColor = rightTextureColor.b;
    }

    // blend colors
    vec3 blendedColor = vec3(redColor, greenColor, blueColor);
    // output blended color
    color = blendedColor;
}
