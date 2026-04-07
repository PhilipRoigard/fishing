extends CanvasLayer

var screen_overlay: ColorRect
var effect_label: Label
var active_tweens: Array[Tween] = []


func _ready() -> void:
	layer = 20

	screen_overlay = ColorRect.new()
	screen_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	screen_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_overlay)

	effect_label = Label.new()
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.set_anchors_preset(Control.PRESET_CENTER)
	effect_label.offset_left = -200
	effect_label.offset_right = 200
	effect_label.offset_top = -40
	effect_label.offset_bottom = 40
	effect_label.add_theme_font_size_override("font_size", 36)
	effect_label.visible = false
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(effect_label)

	SignalBus.consumable_effect_started.connect(_on_effect_started)
	SignalBus.consumable_effect_ended.connect(_on_effect_ended)


func _exit_tree() -> void:
	if SignalBus.consumable_effect_started.is_connected(_on_effect_started):
		SignalBus.consumable_effect_started.disconnect(_on_effect_started)
	if SignalBus.consumable_effect_ended.is_connected(_on_effect_ended):
		SignalBus.consumable_effect_ended.disconnect(_on_effect_ended)
	_kill_tweens()


func _kill_tweens() -> void:
	for tw: Tween in active_tweens:
		if tw and tw.is_valid():
			tw.kill()
	active_tweens.clear()


func _on_effect_started(effect: int) -> void:
	match effect:
		Enums.ConsumableEffect.STUN:
			_play_stun()
		Enums.ConsumableEffect.RESTRICT_RANGE:
			_play_anchor()
		Enums.ConsumableEffect.LINE_SURGE:
			_play_surge()
		Enums.ConsumableEffect.SLACK_RELEASE:
			_play_slack()
		Enums.ConsumableEffect.WIDEN_BRACKET:
			_play_widen()


func _on_effect_ended(effect: int) -> void:
	pass


func _play_stun() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("STUNNED!", Color(0.4, 0.85, 1.0))
	_flash_screen(Color(0.3, 0.7, 1.0, 0.5), 0.3)


func _play_anchor() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("ANCHORED!", Color(0.2, 1.0, 0.65))
	_flash_screen(Color(0.1, 0.9, 0.5, 0.4), 0.3)


func _play_surge() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("SURGE!", Color(1.0, 0.9, 0.15))
	_flash_screen(Color(1.0, 0.85, 0.1, 0.6), 0.15)
	_shake_screen(0.35, 6.0)


func _play_slack() -> void:
	HapticManager.medium_tap()
	_show_effect_text("SLACK!", Color(0.5, 0.8, 1.0))
	_flash_screen(Color(0.4, 0.6, 1.0, 0.35), 0.25)


func _play_widen() -> void:
	HapticManager.medium_tap()
	_show_effect_text("NET DRAG!", Color(0.3, 1.0, 0.5))
	_flash_screen(Color(0.2, 0.9, 0.4, 0.35), 0.25)


func _flash_screen(color: Color, duration: float) -> void:
	screen_overlay.color = color
	var tw: Tween = create_tween()
	tw.tween_property(screen_overlay, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT)
	active_tweens.append(tw)


func _show_effect_text(text: String, color: Color) -> void:
	effect_label.text = text
	effect_label.add_theme_color_override("font_color", color)
	effect_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	effect_label.add_theme_constant_override("outline_size", 4)
	effect_label.visible = true
	effect_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	effect_label.scale = Vector2(0.3, 0.3)
	effect_label.pivot_offset = effect_label.size * 0.5

	var tw: Tween = create_tween()
	tw.tween_property(effect_label, "scale", Vector2(1.15, 1.15), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(effect_label, "scale", Vector2.ONE, 0.06)
	tw.tween_interval(0.5)
	tw.tween_property(effect_label, "modulate:a", 0.0, 0.25)
	tw.tween_callback(func() -> void: effect_label.visible = false)
	active_tweens.append(tw)


func _shake_screen(duration: float, intensity: float) -> void:
	var original_offset: Vector2 = offset
	var steps: int = int(duration / 0.025)
	var tw: Tween = create_tween()
	for i: int in steps:
		var shake_offset: Vector2 = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tw.tween_property(self, "offset", original_offset + shake_offset, 0.025)
	tw.tween_property(self, "offset", original_offset, 0.025)
	active_tweens.append(tw)
