class_name ItemCard
extends PanelContainer

signal selected

static var _sheen_shader: Shader = preload("res://resources/shaders/ui_sheen.gdshader")

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
	modulate = Color(1, 1, 1, 0.4) if dimmed else Color.WHITE


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


func set_item_data(id: String, p_uuid: String, texture: Texture2D, level: int, quality_color: Color, quality: int = -1) -> void:
	item_id = id
	uuid = p_uuid
	item_texture.texture = texture
	level_label.text = "Lv.%d" % level
	self_modulate = quality_color
	_apply_legendary_sheen.call_deferred(quality == Enums.ItemQuality.LEGENDARY)


func _apply_legendary_sheen(enabled: bool) -> void:
	if enabled:
		ItemCard.add_sheen_to(self, {
			"sheen_width": 0.35,
			"sheen_speed": 3.0,
			"sheen_intensity": 0.4,
			"pause_duration": 3.5,
		})
	else:
		ItemCard.remove_sheen_from(self)


static func create_sheen_overlay(params: Dictionary = {}) -> ColorRect:
	var overlay: ColorRect = ColorRect.new()
	overlay.name = "SheenOverlay"
	overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sheen_material: ShaderMaterial = ShaderMaterial.new()
	sheen_material.shader = _sheen_shader
	for key: String in params:
		sheen_material.set_shader_parameter(key, params[key])
	overlay.material = sheen_material
	return overlay


static func add_sheen_to(target: Control, params: Dictionary = {}) -> void:
	var existing: Control = target.get_node_or_null("SheenOverlay")
	if existing:
		existing.queue_free()
	target.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	target.add_child(create_sheen_overlay(params))


static func remove_sheen_from(target: Control) -> void:
	var existing: Control = target.get_node_or_null("SheenOverlay")
	if existing:
		existing.queue_free()
	target.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
