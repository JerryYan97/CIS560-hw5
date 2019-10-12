#version 150

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;


vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                 dot(p, vec2(269.5,183.3))))
                 * 43758.5453);
}

float WorleyNoise(vec2 uv) {
    uv *= 15.0; // Change this to any number you want.
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.0; // Minimum distance initialized to max.
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            vec2 neighbor = vec2(float(x), float(y)); // Direction in which neighbor cell lies
            vec2 point = random2(uvInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
            vec2 diff = neighbor + point - uvFract; // Distance between fragment coord and neighbor’s Voronoi point
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

float pixel_grayValue(vec2 relative_uv)
{
    // get the color in true uv coord of the worley noise
    // get the gray value at the target uv pos
    float tGray = WorleyNoise(fs_UV + relative_uv);

    // return the gray value
    return tGray;
}

vec2 sobel_filter_gradient()
{
    // get the size of texel
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);
    float dx = texel_size.x;
    float dy = texel_size.y;
    // get the grey value of nearby texel powered by WorleyNoise
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

    // return the gradient vector
    return vec2(sx, sy);
}


vec3 BlinnPhongColor(vec3 normal)
{
    // init required parameters
    // get the size of texel
    vec2 texel_size = 1.0 / textureSize(u_RenderedTexture, 0);

    // calculate diffuse color
    // get normalized normal vector
    vec3 norNormal = normalize(normal);
    // calculate the distort pos
    // get distort rate
    float distortRate = 20;
    // distorted relative uv
    vec2 distortedUV = vec2(normal.x * texel_size.x, normal.y * texel_size.y);
    distortedUV *= distortRate;
    // get distort pos
    vec2 samplePos = fs_UV + distortedUV;
    // get distorted diffuseColor
    vec3 diffuseColor = vec3(texture(u_RenderedTexture, samplePos));

    // calculate lightvec
    // get frag pos
    vec3 fragmentPos = vec3(fs_UV, 1);
    // get camera pos
    vec3 cameraPos = vec3(0, 0, 0);
    // get light vector
    vec3 lightVector = cameraPos - fragmentPos;

    // calculate the diffuse term
    float diffuseTerm = dot(normalize(normal), normalize(lightVector));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0, 1);

    // get ambientTerm
    float ambientTerm = 0.2;

    //calculate the specular intensity
    vec3 V = cameraPos - fragmentPos;
    vec3 H = (V + lightVector) / 2;
    float exp = 50;
    float specularIntensity = max(pow(dot(normalize(H), normalize(normal)), exp), 0);

    //get total intensity
    float lightIntensity = diffuseTerm + ambientTerm + specularIntensity;

    //calculate the result color and output it
    return vec3(diffuseColor.rgb * lightIntensity);
}

vec3 CalculateGradiantNormal()
{
    vec2 gradient = sobel_filter_gradient();
    return vec3(gradient, -sqrt(1 - gradient.x * gradient.x - gradient.y * gradient.y));
}

void main()
{
    // TODO Homework 5

    // calculate the gradiant as normal of this fragment
    vec3 normal = CalculateGradiantNormal();
    //vec3 normal = vec3(0.5, 0, -1);

    // get the BlinnPhongColor
    vec3 resultColor = BlinnPhongColor(normal);

    // output the color
    color = resultColor;
    //color = normal;
}
