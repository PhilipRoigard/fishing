shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);

	float ring = smoothstep(0.05, 0.0, abs(dist - 0.35 * intensity)) * intensity;
	float ring2 = smoothstep(0.03, 0.0, abs(dist - 0.2 * intensity)) * intensity * 0.6;
	float core_glow = smoothstep(0.3, 0.0, dist) * intensity * 0.5;

	float rays = 0.0;
	float angle = atan(UV.y - 0.5, UV.x - 0.5);
	rays = pow(abs(sin(angle * 6.0 + TIME * 3.0)), 8.0) * intensity * 0.3;
	rays *= smoothstep(0.5, 0.1, dist);

	vec3 gold = vec3(1.0, 0.85, 0.2);
	vec3 white_hot = vec3(1.0, 1.0, 0.9);
	float total = ring + ring2 + core_glow + rays;
	vec3 col = mix(gold, white_hot, core_glow);

	COLOR = vec4(col, total);
}
