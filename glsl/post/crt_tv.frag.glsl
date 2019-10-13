#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

float vertJerkOpt = 1.0;
float vertMovementOpt = 1.0;
float bottomStaticOpt = 1.0;
float scalinesOpt = 1.0;
float rgbOffsetOpt = 1.0;
float horzFuzzOpt = 1.0;


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

float staticV(vec2 uv) {
    float iTime = u_Time;

    float staticHeight = fbm(9.0,iTime*1.2+3.0)*0.3+5.0;
    float staticAmount = fbm(1.0,iTime*1.2-6.0)*0.1+0.3;
    float staticStrength = fbm(-9.75,iTime*0.6-3.0)*2.0+2.0;
    return (1.0-step(fbm(5.0*pow(iTime,2.0)+pow(uv.x*7.0,1.2),pow((mod(iTime,100.0)+100.0)*uv.y*0.3+3.0,staticHeight)),staticAmount))*staticStrength;
}

void main()
{
    vec2 uv =  fs_UV;
    float iTime = u_Time;

    float jerkOffset = (1.0 - step(fbm(iTime * 1.3, 5.0), 0.8)) * 0.05;

    float fuzzOffset = fbm(iTime * 15.0, uv.y * 80.0) * 0.003;
    float largeFuzzOffset = fbm(iTime * 1.0, uv.y * 25.0) * 0.004;

    float vertMovementOn = (1.0-step(fbm(iTime * 0.2, 8.0), 0.4)) * vertMovementOpt;
    float vertJerk = (1.0 - step(fbm(iTime * 1.5, 5.0), 0.6)) * vertJerkOpt;
    float vertJerk2 = (1.0 - step(fbm(iTime * 5.5, 5.0), 0.2)) * vertJerkOpt;

    float yOffset = abs(sin(iTime) * 4.0) * vertMovementOn + vertJerk * vertJerk2 * 0.3;
    float y = mod(uv.y + yOffset, 1.0);

    float xOffset = (fuzzOffset + largeFuzzOffset) * horzFuzzOpt;

    float staticVal = 0.0;

    for (float y = -1.0; y <= 1.0; y += 1.0) {
        float maxDist = 5.0/200.0;
        float dist = y/200.0;
        staticVal += staticV(vec2(uv.x,uv.y+dist))*(maxDist-abs(dist))*1.5;
    }

    staticVal *= bottomStaticOpt;

    float red 	= texture(u_RenderedTexture, vec2(uv.x + xOffset -0.01*rgbOffsetOpt,y)).r+staticVal;
    float green = texture(u_RenderedTexture, vec2(uv.x + xOffset,	  y)).g+staticVal;
    float blue 	= texture(u_RenderedTexture, vec2(uv.x + xOffset +0.01*rgbOffsetOpt,y)).b+staticVal;

    vec3 resColor = vec3(red,green,blue);
    float scanline = sin(uv.y*800.0)*0.04*scalinesOpt;
    resColor -= scanline;
    color = resColor;
}
