extends UIStateNode

var play_button: Button
var settings_button: Button
var title_label: Label
var subtitle_label: Label
var title_tween: Tween


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_animate_title()


func exit() -> void:
	super()
	if title_tween and title_tween.is_valid():
		title_tween.kill()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.05, 0.12, 0.6)
	add_child(bg)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)

	title_label = Label.new()
	title_label.text = "Wharf Fisher"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "A relaxing fishing adventure"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9, 0.8))
	vbox.add_child(subtitle_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 40
	vbox.add_child(spacer)

	play_button = Button.new()
	play_button.text = "Play"
	play_button.custom_minimum_size = Vector2(200, 60)
	play_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play_button.pressed.connect(_on_play_pressed)
	vbox.add_child(play_button)

	settings_button = Button.new()
	settings_button.text = "Settings"
	settings_button.custom_minimum_size = Vector2(200, 50)
	settings_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_button.pressed.connect(_on_settings_pressed)
	vbox.add_child(settings_button)

	var version_spacer: Control = Control.new()
	version_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(version_spacer)

	var version_label: Label = Label.new()
	version_label.text = "v0.1.0"
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_font_size_override("font_size", 12)
	version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
	vbox.add_child(version_label)


func _animate_title() -> void:
	if not title_label or not subtitle_label:
		return
	title_label.modulate = Color(1, 1, 1, 0)
	subtitle_label.modulate = Color(1, 1, 1, 0)
	title_tween = create_tween()
	title_tween.tween_property(title_label, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)
	title_tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)


func _on_play_pressed() -> void:
	HapticManager.light_tap()
	state_machine.change_state(UIStateMachine.State.WHARF_HUB)
	SignalBus.game_mode_changed.emit(Enums.GameMode.WHARF_HUB)


func _on_settings_pressed() -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.SETTINGS)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
