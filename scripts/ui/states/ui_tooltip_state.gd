extends UIStateNode

var tip_text_content: String = ""


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		tip_text_content = meta.get("text", "")
	elif meta is String:
		tip_text_content = meta
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var dimmer: ColorRect = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.5)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var dismiss: Button = Button.new()
	dismiss.set_anchors_preset(Control.PRESET_FULL_RECT)
	dismiss.modulate = Color(1, 1, 1, 0)
	dismiss.pressed.connect(_back)
	add_child(dismiss)

	var popup: PanelContainer = PanelContainer.new()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.offset_left = -140
	popup.offset_right = 140
	popup.offset_top = -100
	popup.offset_bottom = 100
	popup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var popup_style: StyleBoxFlat = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.88, 0.86, 0.8)
	popup_style.corner_radius_top_left = 8
	popup_style.corner_radius_top_right = 8
	popup_style.corner_radius_bottom_left = 8
	popup_style.corner_radius_bottom_right = 8
	popup_style.border_width_bottom = 2
	popup_style.border_width_top = 2
	popup_style.border_width_left = 2
	popup_style.border_width_right = 2
	popup_style.border_color = Color(0.4, 0.4, 0.4)
	popup_style.content_margin_top = 16
	popup_style.content_margin_bottom = 16
	popup_style.content_margin_left = 16
	popup_style.content_margin_right = 16
	popup.add_theme_stylebox_override("panel", popup_style)
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	popup.add_child(vbox)

	var text_label: Label = Label.new()
	text_label.text = tip_text_content
	text_label.add_theme_font_size_override("font_size", 13)
	text_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(text_label)

	var close_btn: Button = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(100, 32)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(_back)
	vbox.add_child(close_btn)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
