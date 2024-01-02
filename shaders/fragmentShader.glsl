#version 300 es

precision highp int;
precision highp float;

//UNIFORMS
//matrices
uniform mat4 uNormalMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;
//transfer function
uniform vec4 uTF;
uniform float uTFOpacity;
uniform vec3 uTFColor;
//light
uniform float uLightLambda;
uniform float uLightPhi;
uniform float uLightRadius;
uniform float uLightDistance;
uniform int uLightNRays;
//textures
uniform highp sampler3D uVolume;

//VARYINGS
in vec3 vTextureCoord;
in vec3 cameraPosition;
in vec3 rayDirection;

out vec4 frag_color;

float CalculateY(float x) {
  if (x < uTF.x || x > uTF.w) return 0.0;
  else if (x > uTF.y && x < uTF.z) return 1.1;
  else if (x < uTF.y) {
    return (x - uTF.x) / (uTF.y-uTF.x);
  }
  else return (x - uTF.w) / (uTF.z-uTF.w);
}

void main(void) {

  vec4 entryPointView = uModelViewMatrix * vec4(vTextureCoord, 1.0);
  vec4 exitPointView = uModelViewMatrix * vec4(vTextureCoord + rayDirection * uLightDistance, 1.0);

  vec3 entryPoint = entryPointView.xyz / entryPointView.w;
  vec3 exitPoint = exitPointView.xyz / exitPointView.w;

  float rayLength = length(exitPoint - entryPoint);

  float voxelSize = 1.0 / float(textureSize(uVolume, 0).x);
  float As = voxelSize * 0.5 / rayLength;

  float totalOpacity = 0.0;
  vec4 totalColor = vec4(0.0);
  vec3 current = cameraPosition;

  for (float i = 0.0; i < rayLength; i += As ) {
    float voxel = CalculateY(texture(uVolume, current).r);

    totalColor += vec4(uTFColor, 1.0) * uTFOpacity * (1.0 - totalOpacity);
    totalOpacity += uTFOpacity * (1.0 - totalOpacity) * voxel;

    if (totalOpacity >= 0.95) break;

    current += rayDirection * As;
    
  }

  highp vec4 texelColor = totalColor;

  frag_color = totalColor;
  
}

//send the data to the texture!
