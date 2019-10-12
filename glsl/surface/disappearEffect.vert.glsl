#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;

uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec3 fs_Pos;
out vec3 fs_Nor;
out float fs_Should_Highlight;
out vec3 fs_Highlight_Color;

void main()
{
    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));


    vec4 modelposition = u_Model * vs_Pos;
    //vec4 modelposition = u_Model * vs_Dynamic_Pos;
    fs_Pos = vec3(modelposition);
    gl_Position = u_Proj * u_View * modelposition;
}
