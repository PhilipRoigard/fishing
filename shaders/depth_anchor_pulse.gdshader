shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * intensity;
	float border_dist = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge = smoothstep(0.15, 0.0, border_dist);
	vec3 anchor_color = vec3(0.2, 0.8, 0.6);
	vec3 result = mix(tex.rgb, anchor_color, edge * pulse * 0.6);
	COLOR = vec4(result, tex.a);
}
