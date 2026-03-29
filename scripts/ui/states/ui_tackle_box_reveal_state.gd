extends UIStateNode

var result_name_label: Label
var result_quality_label: Label
var collect_button: Button
var pull_results: Array = []


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		pull_results = meta.get("results", [])
	_build_layout()
	_show_result()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(280, 300)
	panel.offset_left = -140
	panel.offset_right = 140
	panel.offset_top = -150
	panel.offset_bottom = 150
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "You got..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	result_name_label = Label.new()
	result_name_label.text = ""
	result_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(result_name_label)

	result_quality_label = Label.new()
	result_quality_label.text = ""
	result_quality_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(result_quality_label)

	collect_button = Button.new()
	collect_button.text = "Collect"
	collect_button.custom_minimum_size = Vector2(160, 50)
	collect_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	collect_button.pressed.connect(_on_collect_pressed)
	vbox.add_child(collect_button)


func _show_result() -> void:
	if pull_results.is_empty():
		return

	var result: Variant = pull_results[0]
	if result is TackleBoxPullResult:
		var pull: TackleBoxPullResult = result as TackleBoxPullResult
		if result_name_label:
			result_name_label.text = pull.item_id
		var quality_name: String = Enums.QUALITY_NAMES.get(pull.quality, "Common")
		if result_quality_label:
			result_quality_label.text = quality_name
			result_quality_label.modulate = Enums.QUALITY_COLORS.get(pull.quality, Color.WHITE)


func _on_collect_pressed() -> void:
	HapticManager.success_feedback()
	_back()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
