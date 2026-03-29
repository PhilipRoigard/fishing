extends Control

@export var bar_height: float = 20.0
@export var fill_speed: float = 8.0
@export var pulse_min_alpha: float = 0.7

@export_group("Zone Colors")
@export var safe_color: Color = Color(0.2, 0.8, 0.2)
@export var warning_color: Color = Color(0.9, 0.9, 0.1)
@export var danger_color: Color = Color(0.9, 0.5, 0.1)
@export var critical_color: Color = Color(0.9, 0.15, 0.15)
@export var background_color: Color = Color(0.15, 0.15, 0.15)

var target_tension: float = 0.0
var displayed_tension: float = 0.0
var pulse_time: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	custom_minimum_size.y = bar_height


func _process(delta: float) -> void:
	displayed_tension = move_toward(displayed_tension, target_tension, delta * fill_speed)

	var pulse_speed: float = _get_pulse_speed()
	if pulse_speed > 0.0:
		pulse_time += delta * pulse_speed
	else:
		pulse_time = 0.0

	if displayed_tension >= 0.9:
		shake_offset = Vector2(randf_range(-2.0, 2.0), randf_range(-1.0, 1.0))
	else:
		shake_offset = Vector2.ZERO

	queue_redraw()


func set_tension(value: float) -> void:
	target_tension = clampf(value, 0.0, 1.0)


func _get_pulse_speed() -> float:
	if displayed_tension >= 0.9:
		return 12.0
	elif displayed_tension >= 0.75:
		return 6.0
	elif displayed_tension >= 0.5:
		return 3.0
	return 0.0


func _get_tension_color(tension_pct: float) -> Color:
	if tension_pct < 0.5:
		return safe_color
	elif tension_pct < 0.75:
		return warning_color
	elif tension_pct < 0.9:
		return danger_color
	return critical_color


func _draw() -> void:
	var bar_rect: Rect2 = Rect2(shake_offset, size)
	draw_rect(bar_rect, background_color)

	if displayed_tension > 0.0:
		var fill_color: Color = _get_tension_color(displayed_tension)

		if pulse_time > 0.0:
			var pulse_alpha: float = lerpf(pulse_min_alpha, 1.0, (sin(pulse_time) + 1.0) * 0.5)
			fill_color.a = pulse_alpha

		var fill_rect: Rect2 = Rect2(shake_offset, Vector2(size.x * displayed_tension, size.y))
		draw_rect(fill_rect, fill_color)
