#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

mat3 horiMat = mat3(
             3,  0, -3,
            10,  0,-10,
             3,  0, -3);
mat3 vertMat = mat3(
             3, 10,  3,
             0,  0,  0,
            -3,-10, -3);


vec3 sobel_filter()
{
    vec3 resColor = vec3(0, 0, 0);
    vec3 horizontal = vec3(0, 0, 0);
    vec3 vertical = vec3(0, 0, 0);
    // get the size of texel
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);
    float dx = texel_size.x;
    float dy = texel_size.y;

    for(int i = -1; i <= 1; i++)
    {
        for(int j = -1; j <= 1; j++)
        {
            vec2 neighborUV = vec2(fs_UV.x + i * dx, fs_UV.y + j * dy);
            vec3 currColor = vec3(texture(u_RenderedTexture, neighborUV));
            horizontal += horiMat[i + 1][j + 1] * currColor;
            vertical += vertMat[i + 1][j + 1] * currColor;
        }
    }
    resColor.x = sqrt(pow(horizontal.x, 2) + pow(vertical.x, 2));
    resColor.y = sqrt(pow(horizontal.y, 2) + pow(vertical.y, 2));
    resColor.z = sqrt(pow(horizontal.z, 2) + pow(vertical.z, 2));

    return resColor;
}

void main()
{
    // TODO Homework 5
    color = sobel_filter();
}
