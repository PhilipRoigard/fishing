shader_type canvas_item;

uniform vec3 surface_color : source_color = vec3(0.4, 0.75, 0.9);
uniform vec3 mid_color : source_color = vec3(0.15, 0.4, 0.7);
uniform vec3 deep_color : source_color = vec3(0.04, 0.08, 0.18);
uniform float depth_offset : hint_range(0.0, 1.0) = 0.0;
uniform float time : hint_range(0.0, 1000.0) = 0.0;
uniform float wave_strength : hint_range(0.0, 0.02) = 0.005;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.5;
uniform float vignette_base : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_depth_scale : hint_range(0.0, 2.0) = 0.6;
uniform float vignette_softness : hint_range(0.1, 2.0) = 0.7;

void fragment() {
	vec2 uv = UV;

	float wave_offset_x = sin(uv.y * 12.0 + time * wave_speed) * wave_strength;
	float wave_offset_y = cos(uv.x * 10.0 + time * wave_speed * 0.8) * wave_strength * 0.5;
	uv += vec2(wave_offset_x, wave_offset_y);

	float depth_uv = clamp(uv.y + depth_offset, 0.0, 1.0);

	vec3 color;
	if (depth_uv < 0.5) {
		color = mix(surface_color, mid_color, depth_uv * 2.0);
	} else {
		color = mix(mid_color, deep_color, (depth_uv - 0.5) * 2.0);
	}

	float caustic = sin(uv.x * 30.0 + time * 0.7) * sin(uv.y * 25.0 - time * 0.5);
	caustic = caustic * 0.5 + 0.5;
	float caustic_mask = 1.0 - smoothstep(0.0, 0.4, depth_uv);
	color += vec3(caustic * 0.04 * caustic_mask);

	vec2 center = uv - vec2(0.5);
	float vignette_dist = length(center * vec2(1.0, 0.8));
	float vignette_amount = vignette_base + depth_uv * vignette_depth_scale;
	float vignette = 1.0 - smoothstep(vignette_softness, vignette_softness + 0.4, vignette_dist + vignette_amount * 0.3);
	color *= vignette;

	COLOR = vec4(color, 1.0);
}
