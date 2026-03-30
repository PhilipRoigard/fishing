extends ColorRect

var surface_color: Color = Color(0.3, 0.75, 0.95)
var mid_color: Color = Color(0.1, 0.35, 0.65)
var deep_color: Color = Color(0.02, 0.04, 0.1)
var abyss_color: Color = Color(0.01, 0.01, 0.03)

@export var max_depth_for_gradient: float = 3000.0

const WATER_START_Y: float = 140.0
var _camera_y: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	var viewport: Viewport = get_viewport()
	if viewport:
		var canvas: Transform2D = viewport.get_canvas_transform()
		_camera_y = -canvas.origin.y
	queue_redraw()


func _draw() -> void:
	var rect_size: Vector2 = size
	if rect_size.x <= 0 or rect_size.y <= 0:
		rect_size = Vector2(360, 640)

	var band_height: float = 4.0
	var bands: int = int(rect_size.y / band_height) + 1

	for i: int in bands:
		var screen_y: float = i * band_height
		var world_y: float = _camera_y + screen_y
		var water_depth: float = maxf(world_y - WATER_START_Y, 0.0)
		var depth_t: float = clampf(water_depth / max_depth_for_gradient, 0.0, 1.0)

		var band_color: Color
		if world_y < WATER_START_Y:
			band_color = Color(0.45, 0.3, 0.18)
		elif depth_t < 0.3:
			band_color = surface_color.lerp(mid_color, depth_t / 0.3)
		elif depth_t < 0.7:
			band_color = mid_color.lerp(deep_color, (depth_t - 0.3) / 0.4)
		else:
			band_color = deep_color.lerp(abyss_color, (depth_t - 0.7) / 0.3)
		draw_rect(Rect2(0, screen_y, rect_size.x, band_height + 1), band_color)


func apply_zone_colors(zone_entry: Variant) -> void:
	if not zone_entry:
		return
	surface_color = zone_entry.background_color_top
	deep_color = zone_entry.background_color_bottom
	mid_color = surface_color.lerp(deep_color, 0.4)
