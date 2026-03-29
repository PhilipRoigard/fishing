extends Node

var safe_area_margins: Dictionary = {
	"top": 0,
	"bottom": 0,
	"left": 0,
	"right": 0,
}


func _ready() -> void:
	_update_safe_area()


func _update_safe_area() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	safe_area_margins["top"] = safe_area.position.y
	safe_area_margins["bottom"] = screen_size.y - (safe_area.position.y + safe_area.size.y)
	safe_area_margins["left"] = safe_area.position.x
	safe_area_margins["right"] = screen_size.x - (safe_area.position.x + safe_area.size.x)


func get_top_margin() -> int:
	return safe_area_margins["top"]


func get_bottom_margin() -> int:
	return safe_area_margins["bottom"]
