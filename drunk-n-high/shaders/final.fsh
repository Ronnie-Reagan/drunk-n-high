#version 460 compatibility
#include "/settings.glsl"

uniform sampler2D texture;

uniform float viewWidth;
uniform float viewHeight;
uniform float time;

varying vec4 color;
varying vec2 coord0;

vec3 hueShift(vec3 c, float angle) {
    float s = sin(angle);
    float cc = cos(angle);

    mat3 rgb2yiq = mat3(
        0.299, 0.587, 0.114,
        0.596, -0.275, -0.321,
        0.212, -0.523, 0.311
    );
    mat3 yiq2rgb = mat3(
        1.0, 0.956, 0.621,
        1.0, -0.272, -0.647,
        1.0, -1.106, 1.703
    );

    vec3 yiq = rgb2yiq * c;
    float Y = yiq.x;
    float I = yiq.y * cc - yiq.z * s;
    float Q = yiq.y * s + yiq.z * cc;
    return yiq2rgb * vec3(Y, I, Q);
}

void main()
{
    vec2 uv = coord0;

    // Mirror effect
    #if MIRROR == 1
        uv.x = 1.0 - uv.x;
    #endif

    // Wobble / drunk distortion
    #if WOBBLE_STRENGTH > 0
        float t = time * WOBBLE_SPEED * 0.1;
        uv += sin(vec2(uv.y * 6.0 + t, uv.x * 6.0 - t)) 
              * (0.01 * WOBBLE_STRENGTH);
    #endif

    vec4 outcolor = texture2D(texture, uv);

    // Hue shift
    #if HUE_STRENGTH > 0
        vec3 shifted = hueShift(outcolor.rgb, HUE_ANGLE);
        outcolor.rgb = mix(outcolor.rgb, shifted, HUE_STRENGTH);
    #endif

    gl_FragData[0] = outcolor;
}
