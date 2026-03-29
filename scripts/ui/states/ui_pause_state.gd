extends UIStateNode


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	get_tree().paused = true


func exit() -> void:
	get_tree().paused = false
	super()
	_clear_children()


func _build_layout() -> void:
	var dimmer: ColorRect = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.5)
	add_child(dimmer)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(260, 280)
	panel.offset_left = -130
	panel.offset_right = 130
	panel.offset_top = -140
	panel.offset_bottom = 140
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var resume_button: Button = Button.new()
	resume_button.text = "Resume"
	resume_button.custom_minimum_size = Vector2(180, 50)
	resume_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	resume_button.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_button)

	var settings_button: Button = Button.new()
	settings_button.text = "Settings"
	settings_button.custom_minimum_size = Vector2(180, 50)
	settings_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_button.pressed.connect(_on_settings_pressed)
	vbox.add_child(settings_button)

	var quit_button: Button = Button.new()
	quit_button.text = "Quit to Menu"
	quit_button.custom_minimum_size = Vector2(180, 50)
	quit_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit_button.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_button)


func _on_resume_pressed() -> void:
	HapticManager.light_tap()
	_back()


func _on_settings_pressed() -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.SETTINGS)


func _on_quit_pressed() -> void:
	HapticManager.light_tap()
	state_machine.show_yes_no_popup(
		"Return to main menu?",
		"Yes",
		"No",
		func() -> void:
			SignalBus.fishing_session_ended.emit()
			SignalBus.game_mode_changed.emit(Enums.GameMode.MAIN_MENU)
			state_machine.change_state(UIStateMachine.State.MAIN_MENU),
		func() -> void: pass
	)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
