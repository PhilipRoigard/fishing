extends UIStateNode

var description_text: String = ""
var yes_text: String = "Yes"
var no_text: String = "No"
var yes_func: Callable = func() -> void: pass
var no_func: Callable = func() -> void: pass


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		description_text = meta.get("desc", "")
		yes_text = meta.get("yes_text", "Yes")
		no_text = meta.get("no_text", "No")
		yes_func = meta.get("yes_func", func() -> void: pass)
		no_func = meta.get("no_func", func() -> void: pass)
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var dimmer: ColorRect = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.4)
	add_child(dimmer)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(280, 200)
	panel.offset_left = -140
	panel.offset_right = 140
	panel.offset_top = -100
	panel.offset_bottom = 100
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	var desc_label: Label = Label.new()
	desc_label.text = description_text
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 20)
	vbox.add_child(button_row)

	var yes_button: Button = Button.new()
	yes_button.text = yes_text
	yes_button.custom_minimum_size = Vector2(100, 44)
	yes_button.pressed.connect(_on_yes_pressed)
	button_row.add_child(yes_button)

	var no_button: Button = Button.new()
	no_button.text = no_text
	no_button.custom_minimum_size = Vector2(100, 44)
	no_button.pressed.connect(_on_no_pressed)
	button_row.add_child(no_button)


func _on_yes_pressed() -> void:
	HapticManager.light_tap()
	var callback: Callable = yes_func
	_back()
	callback.call()


func _on_no_pressed() -> void:
	HapticManager.light_tap()
	var callback: Callable = no_func
	_back()
	callback.call()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
