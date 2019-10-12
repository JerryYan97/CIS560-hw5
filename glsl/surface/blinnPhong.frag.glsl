#version 330

//This is a fragment shader. If you've opened this file first, please open and read lambert.vert.glsl before reading on.
//Unlike the vertex shader, the fragment shader actually does compute the shading of geometry.
//For every pixel in your program's output screen, the fragment shader is run for every bit of geometry that particular pixel overlaps.
//By implicitly interpolating the position data passed into the fragment shader by the vertex shader, the fragment shader
//can compute what color to apply to its pixel based on things like vertex position, light position, and vertex color.

uniform sampler2D u_Texture; // The texture to be read from by this shader

//These are the interpolated values out of the rasterizer, so you can't know
//their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec2 fs_UV;

in vec4 fs_CameraPos;
in vec4 fs_Pos;

layout(location = 0) out vec3 out_Col;//This is the final output color that you will see on your screen for the pixel that is currently being processed.

void main()
{
    // TODO Homework 4
    // Material base color (before shading)
    vec4 diffuseColor = texture(u_Texture, fs_UV);
    // Calculate the diffuse term for Lambert shading
    // fs_LightVec: vec from a fragment on a model to camera postion.
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);
    float ambientTerm = 0.2;

    // Calculate the Blinn-Phong specularIntensity
    vec4 V = fs_CameraPos - fs_Pos;
    vec4 H = (V + fs_LightVec) / 2;
    float exp = 50;
    float specularIntensity = max(pow(dot(normalize(H), normalize(fs_Nor)), exp), 0);


    float lightIntensity = diffuseTerm + ambientTerm + specularIntensity;   //Add a small float value to the color multiplier
                                                                            //to simulate ambient lighting. This ensures that faces that are not                                                                            //lit by our point light are not completely black.
    out_Col = vec3(diffuseColor.rgb * lightIntensity);
}
