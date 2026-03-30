class_name ItemCard
extends PanelContainer

signal selected

@onready var item_texture: TextureRect = $MarginContainer/TextureRect
@onready var level_label: Label = %LevelLabel
@onready var selection_highlight: ColorRect = %SelectionHighlight

var item_id: String = ""
var uuid: String = ""
var _press_position: Vector2 = Vector2.ZERO
var _is_pressed: bool = false
const TAP_THRESHOLD: float = 20.0


func set_selected(is_selected: bool) -> void:
	selection_highlight.visible = is_selected


func set_dimmed(dimmed: bool) -> void:
	modulate = Color(1, 1, 1, 0.3) if dimmed else Color.WHITE


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_position = event.global_position
			_is_pressed = true
		else:
			if _is_pressed:
				var distance: float = event.global_position.distance_to(_press_position)
				if distance < TAP_THRESHOLD:
					selected.emit()
			_is_pressed = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END or what == NOTIFICATION_FOCUS_EXIT:
		_is_pressed = false


func set_item_data(id: String, p_uuid: String, texture: Texture2D, level: int, quality_color: Color) -> void:
	item_id = id
	uuid = p_uuid
	item_texture.texture = texture
	level_label.text = "Lv.%d" % level

	var style: StyleBoxFlat = StyleBoxFlat.new()
	var quality_bg: Color = quality_color.darkened(0.5)
	style.bg_color = quality_bg
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	style.border_color = quality_bg.lightened(0.2)
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1

	add_theme_stylebox_override("panel", style)
