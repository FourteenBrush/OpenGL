#version 420 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 vPos;

uniform float uHorOffset;

void main() {
    vPos = aPos;
    gl_Position = vec4(aPos.x + uHorOffset, aPos.yz, 1.0);
}
