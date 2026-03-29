extends UIStateNode

var sfx_slider: HSlider
var music_slider: HSlider
var notifications_check: CheckButton


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
	panel.custom_minimum_size = Vector2(300, 350)
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -175
	panel.offset_bottom = 175
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sfx_label: Label = Label.new()
	sfx_label.text = "SFX Volume"
	vbox.add_child(sfx_label)

	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = _get_bus_volume("SFX")
	sfx_slider.value_changed.connect(_on_sfx_changed)
	vbox.add_child(sfx_slider)

	var music_label: Label = Label.new()
	music_label.text = "Music Volume"
	vbox.add_child(music_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = _get_bus_volume("Music")
	music_slider.value_changed.connect(_on_music_changed)
	vbox.add_child(music_slider)

	notifications_check = CheckButton.new()
	notifications_check.text = "Notifications"
	notifications_check.button_pressed = true
	vbox.add_child(notifications_check)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _get_bus_volume(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return 1.0
	var db: float = AudioServer.get_bus_volume_db(bus_idx)
	return db_to_linear(db)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))


func _on_sfx_changed(value: float) -> void:
	_set_bus_volume("SFX", value)


func _on_music_changed(value: float) -> void:
	_set_bus_volume("Music", value)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
