extends UIStateNode

var sfx_slider: HSlider
var music_slider: HSlider
var notifications_check: CheckButton
var sfx_value_label: Label
var music_value_label: Label

var stored_sfx_volume: float = 1.0
var stored_music_volume: float = 1.0
var stored_notifications_enabled: bool = true


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.08, 0.15, 0.85)
	add_child(bg)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 420)
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -210
	panel.offset_bottom = 210
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	var sfx_hbox: HBoxContainer = HBoxContainer.new()
	vbox.add_child(sfx_hbox)
	var sfx_label: Label = Label.new()
	sfx_label.text = "SFX Volume"
	sfx_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_hbox.add_child(sfx_label)
	sfx_value_label = Label.new()
	sfx_value_label.text = str(int(_get_bus_volume("SFX") * 100)) + "%"
	sfx_hbox.add_child(sfx_value_label)

	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = _get_bus_volume("SFX")
	sfx_slider.value_changed.connect(_on_sfx_changed)
	vbox.add_child(sfx_slider)

	var music_hbox: HBoxContainer = HBoxContainer.new()
	vbox.add_child(music_hbox)
	var music_label: Label = Label.new()
	music_label.text = "Music Volume"
	music_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_hbox.add_child(music_label)
	music_value_label = Label.new()
	music_value_label.text = str(int(_get_bus_volume("Music") * 100)) + "%"
	music_hbox.add_child(music_value_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = _get_bus_volume("Music")
	music_slider.value_changed.connect(_on_music_changed)
	vbox.add_child(music_slider)

	notifications_check = CheckButton.new()
	notifications_check.text = "Notifications"
	notifications_check.button_pressed = stored_notifications_enabled
	notifications_check.toggled.connect(_on_notifications_toggled)
	vbox.add_child(notifications_check)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	var reset_button: Button = Button.new()
	reset_button.text = "Reset Progress"
	reset_button.custom_minimum_size = Vector2(200, 44)
	reset_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset_button.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	reset_button.pressed.connect(_on_reset_pressed)
	vbox.add_child(reset_button)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _get_bus_volume(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		if bus_name == "SFX":
			return stored_sfx_volume
		return stored_music_volume
	var db: float = AudioServer.get_bus_volume_db(bus_idx)
	return db_to_linear(db)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))
	if bus_name == "SFX":
		stored_sfx_volume = linear
	else:
		stored_music_volume = linear


func _on_sfx_changed(value: float) -> void:
	_set_bus_volume("SFX", value)
	if sfx_value_label:
		sfx_value_label.text = str(int(value * 100)) + "%"


func _on_music_changed(value: float) -> void:
	_set_bus_volume("Music", value)
	if music_value_label:
		music_value_label.text = str(int(value * 100)) + "%"


func _on_notifications_toggled(toggled_on: bool) -> void:
	stored_notifications_enabled = toggled_on


func _on_reset_pressed() -> void:
	HapticManager.light_tap()
	state_machine.show_yes_no_popup(
		"Are you sure you want to reset all progress? This cannot be undone.",
		"Reset",
		"Cancel",
		_confirm_reset,
	)


func _confirm_reset() -> void:
	if Main.instance and Main.instance.player_state_system:
		var state: Variant = Main.instance.player_state_system.get_state()
		if state:
			state.coins = 0
			state.gems = 0
			state.fisherman_level = 1
			state.fisherman_xp = 0
			state.total_fish_caught = 0
			state.collection_log.clear()
	EquipmentManager.inventory.clear()
	EquipmentManager.loadout.clear()
	EquipmentManager._grant_starter_items()
	SignalBus.show_notification.emit("Progress has been reset", Color(1.0, 0.3, 0.3))


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
