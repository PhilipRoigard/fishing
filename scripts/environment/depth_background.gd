extends ColorRect

var surface_color: Color = Color(0.3, 0.75, 0.95)
var mid_color: Color = Color(0.15, 0.55, 0.8)
var deep_color: Color = Color(0.04, 0.08, 0.18)
var current_depth_offset: float = 0.0
var target_depth_offset: float = 0.0

@export var depth_scroll_speed: float = 2.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SignalBus.cast_landed.connect(_on_cast_landed)


func _process(delta: float) -> void:
	current_depth_offset = lerpf(current_depth_offset, target_depth_offset, delta * depth_scroll_speed)
	queue_redraw()


func _draw() -> void:
	var rect_size: Vector2 = size
	if rect_size.x <= 0 or rect_size.y <= 0:
		rect_size = Vector2(360, 640)

	var band_height: float = 4.0
	var bands: int = int(rect_size.y / band_height) + 1

	for i: int in bands:
		var t: float = float(i) / float(bands)
		var depth_t: float = clampf(t + current_depth_offset, 0.0, 1.0)
		var band_color: Color
		if depth_t < 0.5:
			band_color = surface_color.lerp(mid_color, depth_t * 2.0)
		else:
			band_color = mid_color.lerp(deep_color, (depth_t - 0.5) * 2.0)
		draw_rect(Rect2(0, i * band_height, rect_size.x, band_height + 1), band_color)


func apply_zone_colors(zone_entry: Variant) -> void:
	if not zone_entry:
		return
	surface_color = zone_entry.background_color_top
	deep_color = zone_entry.background_color_bottom
	mid_color = surface_color.lerp(deep_color, 0.5)


func _on_cast_landed(depth: float) -> void:
	target_depth_offset = clampf(depth / 2000.0, 0.0, 0.8)
