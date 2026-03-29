extends UIStateNode

var play_button: Button
var settings_button: Button


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()


func exit() -> void:
	super()
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

	var title_label: Label = Label.new()
	title_label.text = "Wharf Fisher"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

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
