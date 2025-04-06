shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float wave_speed = 1.0;
uniform float wave_amplitude = 0.005;
uniform vec4 water_tint : source_color = vec4(0.2, 0.4, 0.6, 0.15);
uniform float caustics_intensity = 0.03;
uniform float blur_amount = 0.5;
uniform float vignette_strength = 0.3;
uniform float vignette_size = 0.7;
uniform float reflection_opacity = 0.3;  // New uniform to control reflection strength
uniform float darkness_overlay = 0.0; // 0.0 for normal, up to 1.0 for game over

// Pseudo-random function
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Simplex-like 2D noise
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    // Create more natural wave distortion
    vec2 distorted_uv = SCREEN_UV;
    float time = TIME * wave_speed;

    // Combine multiple waves for more natural movement
    distorted_uv.x += sin(SCREEN_UV.y * 8.0 + time) * wave_amplitude;
    distorted_uv.x += sin(SCREEN_UV.y * 12.0 + time * 1.1) * wave_amplitude * 0.5;
    distorted_uv.y += cos(SCREEN_UV.x * 8.0 + time * 0.9) * wave_amplitude;
    distorted_uv.y += cos(SCREEN_UV.x * 12.0 + time * 1.2) * wave_amplitude * 0.5;

    // Simple blur effect
    vec4 blur_color = vec4(0.0);
    float blur_size = blur_amount / 100.0;

    // 5-tap blur
    blur_color += texture(SCREEN_TEXTURE, distorted_uv + vec2(-blur_size, 0.0)) * 0.2;
    blur_color += texture(SCREEN_TEXTURE, distorted_uv + vec2(blur_size, 0.0)) * 0.2;
    blur_color += texture(SCREEN_TEXTURE, distorted_uv + vec2(0.0, -blur_size)) * 0.2;
    blur_color += texture(SCREEN_TEXTURE, distorted_uv + vec2(0.0, blur_size)) * 0.2;
    blur_color += texture(SCREEN_TEXTURE, distorted_uv) * 0.2;

    // Add caustics effect
    float caustics = noise(SCREEN_UV * 10.0 + vec2(time * 0.5, time * 0.7));
    caustics += noise(SCREEN_UV * 20.0 - vec2(time * 0.3, time * 0.4)) * 0.5;
    caustics = smoothstep(0.4, 0.6, caustics);

    // Create vignette
    vec2 vignette_uv = SCREEN_UV * 2.0 - 1.0;
    float vignette = 1.0 - dot(vignette_uv * vignette_size, vignette_uv * vignette_size);
    vignette = smoothstep(0.0, 1.0, vignette);
    vignette = pow(vignette, 1.0 + vignette_strength);

    // Apply water tint with depth
    float depth_factor = 1.0 - UV.y * 0.4;
    vec4 final_color = mix(blur_color, water_tint, water_tint.a * (1.0 - depth_factor));

    // Add caustics
    final_color.rgb += caustics * caustics_intensity * depth_factor;

    // Apply vignette
    final_color.rgb *= vignette;

    // Color absorption with depth (red light gets absorbed first, then green, blue penetrates deepest)
    final_color.r *= depth_factor;
    final_color.g *= depth_factor * 1.1;
    final_color.b *= depth_factor * 1.2;

    // Apply darkness overlay for game over
    final_color.rgb = mix(final_color.rgb, vec3(0.0), darkness_overlay);
    final_color.a = mix(reflection_opacity, 0.8, darkness_overlay);

    COLOR = final_color;
}