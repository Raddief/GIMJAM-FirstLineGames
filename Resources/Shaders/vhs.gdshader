shader_type canvas_item;

/* REQUIRED in Godot 4.5 */
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

/* VHS controls */
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.35;
uniform float noise_strength    : hint_range(0.0, 1.0) = 0.2;
uniform float distortion        : hint_range(0.0, 0.02) = 0.004;
uniform float chroma_offset     : hint_range(0.0, 0.01) = 0.003;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;
uniform float time_scale = 1.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float t = TIME * time_scale;

    /* Horizontal tape wobble */
    float wobble = sin(uv.y * 80.0 + t * 6.0) * distortion;
    uv.x += wobble;

    /* Chromatic aberration */
    float r = texture(screen_texture, uv + vec2(chroma_offset, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(chroma_offset, 0.0)).b;

    vec3 color = vec3(r, g, b);

    /* Scanlines */
    float scanline = sin(uv.y * 800.0);
    color *= 1.0 - scanline * scanline_strength;

    /* Noise */
    float n = rand(uv * t) * noise_strength;
    color += n;

    /* Vignette */
    vec2 centered = uv - 0.5;
    float dist = length(centered);
    float vignette = smoothstep(0.4, 0.8, dist);
    color *= 1.0 - vignette * vignette_strength;

    COLOR = vec4(color, 1.0);
}
