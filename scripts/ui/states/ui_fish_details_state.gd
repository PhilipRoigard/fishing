extends UIStateNode

var fish_id: String = ""


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		fish_id = meta.get("fish_id", "")
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(fish_id)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 20)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 20)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	if not fish_data:
		var unknown_label: Label = Label.new()
		unknown_label.text = "Fish not found"
		vbox.add_child(unknown_label)
	else:
		var name_label: Label = Label.new()
		name_label.text = fish_data.display_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_label)

		var rarity_name: String = Enums.RARITY_NAMES.get(fish_data.rarity, "Common")
		var rarity_label: Label = Label.new()
		rarity_label.text = rarity_name
		rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(rarity_label)

		var separator: HSeparator = HSeparator.new()
		vbox.add_child(separator)

		var depth_label: Label = Label.new()
		depth_label.text = "Depth: " + str(int(fish_data.min_depth)) + "m - " + str(int(fish_data.max_depth)) + "m"
		vbox.add_child(depth_label)

		if fish_data.bait_requirement_id != "":
			var bait_label: Label = Label.new()
			bait_label.text = "Requires bait: " + fish_data.bait_requirement_id
			vbox.add_child(bait_label)

		var value_label: Label = Label.new()
		value_label.text = "Sell value: " + str(fish_data.sell_value_coins) + " coins"
		vbox.add_child(value_label)

		var state: PlayerState = null
		if Main.instance and Main.instance.player_state_system:
			state = Main.instance.player_state_system.get_state()

		if state:
			var times_caught: int = state.collection_log.get(fish_id, 0)
			var caught_label: Label = Label.new()
			caught_label.text = "Times caught: " + str(times_caught)
			vbox.add_child(caught_label)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
