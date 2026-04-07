shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_scale : hint_range(0.0, 5.0) = 3.0;

void fragment() {
	vec2 uv = UV;
	float wave = sin(uv.y * 30.0 + TIME * time_scale) * 0.005 * intensity;
	uv.x += wave;

	float sparkle = fract(sin(dot(floor(uv * 80.0) + TIME * 2.0, vec2(12.9898, 78.233))) * 43758.5453);
	sparkle = step(0.97, sparkle) * intensity;

	float edge_fade = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float vignette = smoothstep(0.0, 0.3, edge_fade);
	float border_glow = (1.0 - vignette) * intensity * 0.4;

	vec3 ice_color = vec3(0.3, 0.6, 1.0);
	float alpha = (border_glow + sparkle * 0.8) * intensity;
	COLOR = vec4(ice_color + vec3(sparkle), alpha);
}
