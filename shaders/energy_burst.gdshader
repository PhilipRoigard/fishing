shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 burst_color : source_color = vec4(1.0, 0.9, 0.2, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float ring = smoothstep(0.3 * intensity, 0.0, abs(dist - 0.4 * intensity));
	float glow = smoothstep(0.5, 0.0, dist) * intensity * 0.4;
	vec3 effect = burst_color.rgb * (ring + glow);
	COLOR = vec4(tex.rgb + effect, max(tex.a, (ring + glow) * intensity));
}
