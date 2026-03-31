shader_type canvas_item;
render_mode blend_add;

uniform float sheen_width : hint_range(0.01, 0.6) = 0.35;
uniform float sheen_angle : hint_range(-1.0, 1.0) = 0.5;
uniform float sheen_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float sheen_speed : hint_range(0.1, 5.0) = 3.0;
uniform float pause_duration : hint_range(0.0, 5.0) = 3.5;

void fragment() {
	float diagonal_max = 1.0 + abs(sheen_angle);
	float sweep_start = -sheen_width;
	float sweep_end = diagonal_max + sheen_width;
	float cycle_duration = 1.0 / sheen_speed + pause_duration;
	float t = mod(TIME, cycle_duration);
	float sweep_time = 1.0 / sheen_speed;
	float progress = clamp(t / sweep_time, 0.0, 1.0);
	float sheen_pos = mix(sweep_start, sweep_end, progress);
	float diagonal = UV.x + UV.y * sheen_angle;
	float dist = abs(diagonal - sheen_pos);
	float sheen = smoothstep(sheen_width, 0.0, dist) * sheen_intensity;
	COLOR = vec4(vec3(sheen), sheen);
}
