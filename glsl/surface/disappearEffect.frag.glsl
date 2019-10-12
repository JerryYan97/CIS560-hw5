#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader
uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;
in vec3 fs_Highlight_Color;
in float fs_Should_Highlight;

layout(location = 0) out vec3 out_Col;

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p) {
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

void main()
{
    vec3 normalVec = fs_Nor;
    normalVec.x += 0.01 * u_Time;
    normalVec.y += 0.01 * u_Time;
    normalVec.z += 0.01 * u_Time;
    float n = noise(normalVec);

    float r = 0;
    float innerRadius = pow(fs_Pos.x, 2) + pow(fs_Pos.y, 2);
    // Note that smoothstep returns a value between 0 and 1
    float sRate = 4.2 * smoothstep(0, 1, abs(sin(0.01 * u_Time)));
    r += sRate;
    float rPower2 = pow(r, 2);
    if(rPower2 > innerRadius)
    {
        discard;
    }

    vec3 col = palette( n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
    out_Col = col;
}
