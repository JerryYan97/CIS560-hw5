#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec2 vs_UV;

out vec2 fs_UV;

void main()
{
    // TODO Homework 4
    vec3 fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));
    fs_Nor = mat3(u_View) * fs_Nor;

    vec4 p_view = u_View * u_Model * vs_Pos;
    vec3 e = normalize(p_view.xyz);
    vec3 r = reflect(e, fs_Nor);

    //fs_UV = vs_UV;
    float m = 2 * sqrt( pow( r.x, 2. ) +
                        pow( r.y, 2. ) +
                        pow( r.z + 1., 2. )
                      );

    fs_UV = r.xy / m + .5;
    vec4 modelposition = u_Model * vs_Pos;
    gl_Position = u_Proj * u_View * modelposition;
}
