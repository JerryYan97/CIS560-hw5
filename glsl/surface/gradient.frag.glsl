#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec3 fs_Nor;
in vec3 fs_LightVec;
in vec4 fs_Pos;

layout(location = 0) out vec3 out_Col;

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void main()
{
    // TODO Homework 4
    vec3 col = palette( fs_Nor.z, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );

    out_Col = col;
}
