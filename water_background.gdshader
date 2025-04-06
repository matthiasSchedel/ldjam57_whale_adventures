shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amplitude = 0.008;
uniform vec4 water_tint : source_color = vec4(0.2, 0.4, 0.6, 0.15);

void fragment() {
    vec2 distorted_uv = UV;
    distorted_uv.x += sin(UV.y * 10.0 + TIME * wave_speed) * wave_amplitude;
    distorted_uv.y += cos(UV.x * 10.0 + TIME * wave_speed) * wave_amplitude;

    vec4 color = texture(TEXTURE, distorted_uv);

    color.rgb = mix(color.rgb, water_tint.rgb, water_tint.a * 0.8);

    color.rgb *= (1.0 - UV.y * 0.15);

    COLOR = color;
}