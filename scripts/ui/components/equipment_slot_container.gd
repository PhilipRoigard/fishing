class_name EquipmentSlotComponent
extends PanelContainer

signal selected

const TAP_THRESHOLD: float = 20.0

var _item_card_scene: PackedScene = preload("res://scenes/ui/components/item_card.tscn")
var _item_card: ItemCard
var _press_position: Vector2 = Vector2.ZERO
var _is_pressed: bool = false
var _empty_style: StyleBox
var _slot_type: Enums.EquipmentSlot
var _slot_name: String = ""

@onready var equipment_texture: TextureRect = %EquipmentIcon


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	_empty_style = get_theme_stylebox("panel")


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


func setup_slot(slot_type: Enums.EquipmentSlot, slot_name: String) -> void:
	_slot_type = slot_type
	_slot_name = slot_name


func set_equipped_item(entry_id: String, entry_uuid: String, texture: Texture2D, level: int, quality: int) -> void:
	equipment_texture.visible = false

	var empty_stylebox: StyleBoxEmpty = StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty_stylebox)

	if _item_card:
		_item_card.queue_free()
		_item_card = null

	_item_card = _item_card_scene.instantiate() as ItemCard
	_item_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_item_card)
	_item_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var quality_color: Color = Enums.QUALITY_COLORS.get(quality, Color.WHITE)
	_item_card.set_item_data(entry_id, entry_uuid, texture, level, quality_color, quality)

	for connection: Dictionary in _item_card.selected.get_connections():
		_item_card.selected.disconnect(connection["callable"] as Callable)


func set_bait_stack(texture: Texture2D, quality: int, count: int) -> void:
	equipment_texture.visible = false

	var empty_stylebox: StyleBoxEmpty = StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty_stylebox)

	if _item_card:
		_item_card.queue_free()
		_item_card = null

	_item_card = _item_card_scene.instantiate() as ItemCard
	_item_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_item_card)
	_item_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var quality_color: Color = Enums.QUALITY_COLORS.get(quality, Color.WHITE)
	_item_card.set_item_data("bait", "", texture, 0, quality_color)
	_item_card.level_label.text = "x%d" % count

	for connection: Dictionary in _item_card.selected.get_connections():
		_item_card.selected.disconnect(connection["callable"] as Callable)


func unequip_item() -> void:
	equipment_texture.visible = true

	if _empty_style:
		add_theme_stylebox_override("panel", _empty_style)
	else:
		remove_theme_stylebox_override("panel")

	if _item_card:
		_item_card.queue_free()
		_item_card = null
