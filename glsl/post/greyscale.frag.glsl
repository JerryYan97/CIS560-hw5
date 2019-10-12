#version 150

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;


float DisCal(vec2 center, vec2 current_UV)
{
    return length(center - current_UV);
}

// Less Distance, Greater Brightness Rate [0, 1]
float BrightnessRateCal(float distance)
{
    // Get greatest distance
    float gDistance = length(vec2(0.5, 0.5));

    // map [0, greatest distance] dis to [1,0] rate.
    // map [0, greatest distance] dis to [0,1]
    float tempRange = distance / gDistance;
    // map [0,1] to [1,0]
    tempRange = (tempRange - 1) / (-1);

    return tempRange;
}

void main()
{
    // TODO Homework 5
    vec3 tColor = vec3(texture(u_RenderedTexture, fs_UV));
    // Convert the color of this fragment into grey scale.
    float grey = 0.21 * tColor.r + 0.72 * tColor.g + 0.07 * tColor.b;
    tColor = vec3(grey, grey, grey);

    // Get the distance between this fragment and the center of the whole image.
    vec2 center_UV = vec2(0.5, 0.5);
    float dis = DisCal(center_UV, fs_UV);

    // Input the distance. Get the brightness of this fragment.
    float brightnessRate = BrightnessRateCal(dis);

    // Get the final color of this fragment.
    tColor = tColor * brightnessRate;

    color = tColor;
}
