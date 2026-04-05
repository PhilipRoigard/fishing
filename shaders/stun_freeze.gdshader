shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_scale : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float wave = sin(UV.y * 40.0 + TIME * time_scale) * 0.003 * intensity;
	vec4 shifted = texture(TEXTURE, UV + vec2(wave, 0.0));
	vec3 ice_tint = vec3(0.4, 0.7, 1.0);
	vec3 result = mix(shifted.rgb, ice_tint, intensity * 0.5);
	float sparkle = step(0.98, fract(sin(dot(UV * 50.0 + TIME, vec2(12.9898, 78.233))) * 43758.5453));
	result += vec3(sparkle * intensity * 0.6);
	COLOR = vec4(result, tex.a);
}
