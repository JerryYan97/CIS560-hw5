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

void main()
{
    // TODO Homework 4
    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));

    // Deform  the vertices.
    //vec4 normPos = normalize(vs_Pos);
    vec4 normPos = vec4(normalize(vec3(vs_Pos.xyz)), 1);
    vec4 diffVec = vs_Pos - normPos;
    float sRate = smoothstep(0, 1, abs(sin(0.01 * u_Time)));
    diffVec *= sRate;
    vec4 vs_Dynamic_Pos = vs_Pos - diffVec;


    //vec4 modelposition = u_Model * vs_Pos;
    vec4 modelposition = u_Model * vs_Dynamic_Pos;
    fs_Pos = vec3(modelposition);
    gl_Position = u_Proj * u_View * modelposition;
}
