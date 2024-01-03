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
uniform int uStrategy;
//textures
uniform vec3 uDimensions;
uniform highp sampler3D uVolume;

//VARYINGS
in vec3 vTextureCoord;
in vec3 cameraPosition;

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

  vec3 rayDirection = normalize(vTextureCoord - cameraPosition);

  vec3 entryPoint = vTextureCoord;

  vec3 cubeMin = vec3(0.0);
  vec3 cubeMax = vec3(1.0);

  vec3 tMin = (cubeMin - cameraPosition) / rayDirection;
  vec3 tMax = (cubeMax - cameraPosition) / rayDirection;

  vec3 t1 = min(tMin, tMax);
  vec3 t2 = max(tMin, tMax);
  float tNear = max(max(t1.x, t1.y), t1.z);
  float tFar = min(min(t2.x, t2.y), t2.z);

  vec3 exitPoint = cameraPosition + rayDirection * tNear;

  float rayLength = length(exitPoint - entryPoint);

  float diagonalLength = sqrt(3.0) * length(uDimensions);
  float As = diagonalLength / 2.0;

  float totalOpacity = 0.0;
  vec4 totalColor = vec4(0.0);
  vec3 current = entryPoint;

  for (float i = 0.0; i < rayLength; i += As ) {
    float voxel = CalculateY(texture(uVolume, current).x);

    totalColor += vec4(uTFColor, 1.0) * uTFOpacity * (1.0 - totalOpacity);
    totalOpacity += uTFOpacity * (1.0 - totalOpacity) * voxel;

    if (totalOpacity >= 0.95) break;

    current += rayDirection * As;
    
  }

  highp vec4 texelColor = totalColor;

  frag_color = vec4(exitPoint, 1.0);
  //frag_color = totalColor;
}

//send the data to the texture!
