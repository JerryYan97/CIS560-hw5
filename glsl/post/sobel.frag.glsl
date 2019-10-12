#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

uniform mat3x3 horiMat = mat3x3(
             3,  0, -3,
            10,  0,-10,
             3,  0, -3);
uniform mat3x3 vertMat = mat3x3(
             3, 10,  3,
             0,  0,  0,
            -3,-10, -3);

float pixel_grayValue(vec2 relative_uv)
{
    // get the color in true uv coord
    vec3 tColor = vec3(texture(u_RenderedTexture, fs_UV + relative_uv));

    // convert the color to gray value
    float tGray = 0.21 * tColor.r + 0.72 * tColor.g + 0.07 * tColor.b;

    // return the gray value
    return tGray;
}

float sobel_filter()
{
    // get the size of texel
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);
    float dx = texel_size.x;
    float dy = texel_size.y;
    // get the grey value of nearby texel
    float s00 = pixel_grayValue(vec2(dx, dy));
    float s10 = pixel_grayValue(vec2(-dx, 0));
    float s20 = pixel_grayValue(vec2(-dx, -dy));
    float s01 = pixel_grayValue(vec2(0, dy));
    float s21 = pixel_grayValue(vec2(0, -dy));
    float s02 = pixel_grayValue(vec2(dx, dy));
    float s12 = pixel_grayValue(vec2(dx, 0));
    float s22 = pixel_grayValue(vec2(dx, -dy));

    // calculate the gradients of horizontal and vertical
    float sx = 3 * s00 + 10 * s10 + 3 * s20 - (3 * s02 + 10 * s12 + 3 * s22);
    float sy = 3 * s00 + 10 * s01 + 3 * s02 - (3 * s20 + 10 * s21 + 3 * s22);

    // get the length of vec2 constructed by the gradients
    float len = length(vec2(sx, sy));

    // return the length as grey value
    return len;
}

void main()
{
    // TODO Homework 5
    float grayValue = sobel_filter();
    color = vec3(grayValue, grayValue, grayValue);
}
