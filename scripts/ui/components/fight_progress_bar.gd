extends Control

@export var bar_height: float = 20.0
@export var fill_speed: float = 5.0
@export var background_color: Color = Color(0.15, 0.15, 0.15)

@export_group("Progress Colors")
@export var color_low: Color = Color(0.8, 0.2, 0.2)
@export var color_mid_low: Color = Color(0.9, 0.5, 0.1)
@export var color_mid_high: Color = Color(0.9, 0.9, 0.1)
@export var color_high: Color = Color(0.2, 0.8, 0.2)

var target_progress: float = 0.0
var displayed_progress: float = 0.0


func _ready() -> void:
	custom_minimum_size.y = bar_height


func _process(delta: float) -> void:
	displayed_progress = move_toward(displayed_progress, target_progress, delta * fill_speed)
	queue_redraw()


func set_progress(value: float) -> void:
	target_progress = clampf(value, 0.0, 1.0)


func _get_progress_color(pct: float) -> Color:
	if pct < 0.25:
		return color_low.lerp(color_mid_low, pct / 0.25)
	elif pct < 0.5:
		return color_mid_low.lerp(color_mid_high, (pct - 0.25) / 0.25)
	elif pct < 0.75:
		return color_mid_high.lerp(color_high, (pct - 0.5) / 0.25)
	return color_high


func _draw() -> void:
	var bar_rect: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(bar_rect, background_color)

	if displayed_progress > 0.0:
		var fill_color: Color = _get_progress_color(displayed_progress)
		var fill_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(size.x * displayed_progress, size.y))
		draw_rect(fill_rect, fill_color)
