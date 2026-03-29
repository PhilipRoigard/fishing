extends Control

signal consumable_used(effect: Enums.ConsumableEffect)

@export var cooldown_duration: float = 2.0
@export var slot_size: float = 64.0
@export var cooldown_color: Color = Color(0.0, 0.0, 0.0, 0.5)

var effect_type: Enums.ConsumableEffect = Enums.ConsumableEffect.STUN
var remaining_count: int = 0
var is_on_cooldown: bool = false
var cooldown_remaining: float = 0.0

var icon_texture: Texture2D
var count_label: Label
var cooldown_overlay: ColorRect
var touch_button: Button


func _ready() -> void:
	custom_minimum_size = Vector2(slot_size, slot_size)
	_build_layout()
	_update_display()


func _build_layout() -> void:
	touch_button = Button.new()
	touch_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_button.pressed.connect(_on_pressed)
	add_child(touch_button)

	cooldown_overlay = ColorRect.new()
	cooldown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	cooldown_overlay.color = cooldown_color
	cooldown_overlay.visible = false
	cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cooldown_overlay)

	count_label = Label.new()
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(count_label)


func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_remaining -= delta
		if cooldown_remaining <= 0.0:
			is_on_cooldown = false
			cooldown_overlay.visible = false


func setup(effect: Enums.ConsumableEffect, count: int, icon: Texture2D = null) -> void:
	effect_type = effect
	remaining_count = count
	icon_texture = icon
	_update_display()


func _on_pressed() -> void:
	if remaining_count <= 0 or is_on_cooldown:
		return
	remaining_count -= 1
	is_on_cooldown = true
	cooldown_remaining = cooldown_duration
	cooldown_overlay.visible = true
	consumable_used.emit(effect_type)
	HapticManager.medium_tap()
	_update_display()


func _update_display() -> void:
	if count_label:
		count_label.text = str(remaining_count)
	if touch_button:
		touch_button.disabled = remaining_count <= 0
		touch_button.modulate = Color.WHITE if remaining_count > 0 else Color(0.4, 0.4, 0.4)
