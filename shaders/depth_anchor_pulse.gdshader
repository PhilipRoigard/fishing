shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.0;

void fragment() {
	float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * intensity;

	float edge_dist = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float border = smoothstep(0.08, 0.0, edge_dist) * pulse;

	float corner_dist = min(
		min(length(UV), length(UV - vec2(1.0, 0.0))),
		min(length(UV - vec2(0.0, 1.0)), length(UV - vec2(1.0, 1.0)))
	);
	float corner_glow = smoothstep(0.25, 0.0, corner_dist) * intensity * 0.3;

	float scan_line = smoothstep(0.01, 0.0, abs(UV.y - fract(TIME * 0.3))) * intensity * 0.15;

	vec3 anchor_color = vec3(0.1, 0.9, 0.6);
	float total = border + corner_glow + scan_line;

	COLOR = vec4(anchor_color, total);
}
