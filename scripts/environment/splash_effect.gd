extends Node2D

var lifetime: float = 0.3
var max_radius: float = 20.0
var elapsed: float = 0.0
var splash_color: Color = Color(1.0, 1.0, 1.0, 0.8)


func _ready() -> void:
	z_index = 10


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = elapsed / lifetime
	var radius: float = max_radius * t
	var alpha: float = (1.0 - t) * splash_color.a
	var color: Color = Color(splash_color.r, splash_color.g, splash_color.b, alpha)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, 2.0)
	if radius > 4.0:
		var inner_alpha: float = alpha * 0.5
		var inner_color: Color = Color(splash_color.r, splash_color.g, splash_color.b, inner_alpha)
		draw_arc(Vector2.ZERO, radius * 0.5, 0.0, TAU, 24, inner_color, 1.5)
