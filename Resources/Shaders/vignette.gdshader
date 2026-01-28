shader_type canvas_item;

/* Core */
uniform float intensity : hint_range(0.0, 1.5) = 0.75;
uniform float softness  : hint_range(0.01, 1.0) = 0.35;

/* Shape */
uniform float roundness : hint_range(0.2, 2.0) = 1.0;
uniform float inner_radius : hint_range(0.0, 1.0) = 0.45;

/* Offset */
uniform float offset_x : hint_range(-0.5, 0.5) = 0.0;
uniform float offset_y : hint_range(-0.5, 0.5) = 0.0;

/* Color */
uniform vec3 vignette_color : source_color = vec3(0.0);

void fragment() {
    vec2 uv = SCREEN_UV;

    // Get viewport size (CanvasItem-safe)
    vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;

    // Aspect ratio correction
    vec2 aspect = vec2(
        viewport_size.x / viewport_size.y,
        1.0
    );

    vec2 offset = vec2(offset_x, offset_y);
    vec2 centered_uv = (uv - 0.5 + offset) * aspect;

    // Shape control
    centered_uv = pow(abs(centered_uv), vec2(roundness));

    float dist = length(centered_uv);

    float vignette = smoothstep(
        inner_radius,
        inner_radius + softness,
        dist
    );

    COLOR = vec4(vignette_color, vignette * intensity);
}
