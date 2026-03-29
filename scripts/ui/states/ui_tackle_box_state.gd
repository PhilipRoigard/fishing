extends UIStateNode

var pack_list: VBoxContainer


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_packs()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 10)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 60)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Tackle Box"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	pack_list = VBoxContainer.new()
	pack_list.add_theme_constant_override("separation", 12)
	scroll.add_child(pack_list)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _refresh_packs() -> void:
	for child: Node in pack_list.get_children():
		child.queue_free()

	var pack_paths: Array[String] = [
		"res://data/gacha/basic_tackle_box.tres",
		"res://data/gacha/premium_tackle_box.tres",
		"res://data/gacha/legendary_tackle_box.tres",
	]

	for path: String in pack_paths:
		if not ResourceLoader.exists(path):
			continue
		var pack: TackleBoxPackDefinition = load(path) as TackleBoxPackDefinition
		if pack:
			var card: PanelContainer = _create_pack_card(pack)
			pack_list.add_child(card)


func _create_pack_card(pack: TackleBoxPackDefinition) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label: Label = Label.new()
	name_label.text = pack.display_name
	info_vbox.add_child(name_label)

	var cost_label: Label = Label.new()
	cost_label.text = str(pack.gem_cost) + " Gems"
	info_vbox.add_child(cost_label)

	var limit_label: Label = Label.new()
	limit_label.text = "Daily: " + str(pack.daily_limit) + " pulls"
	limit_label.modulate = Color(0.7, 0.7, 0.7)
	info_vbox.add_child(limit_label)

	var pull_button: Button = Button.new()
	pull_button.text = "Pull"
	pull_button.custom_minimum_size = Vector2(90, 50)
	pull_button.pressed.connect(_on_pull_pressed.bind(pack.id))
	hbox.add_child(pull_button)

	return panel


func _on_pull_pressed(pack_id: String) -> void:
	HapticManager.medium_tap()
	if not CurrencyManager:
		return

	var pack: TackleBoxPackDefinition = _find_pack_by_id(pack_id)
	if not pack:
		return

	if not CurrencyManager.can_afford_gems(pack.gem_cost):
		SignalBus.show_notification.emit("Not enough gems!", Color.RED)
		return

	CurrencyManager.spend_gems(pack.gem_cost)

	var weights: Dictionary = pack.get_quality_weights()
	var total_weight: float = pack.get_total_weight()
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	var pulled_quality: int = 0
	for quality_key: Variant in weights:
		cumulative += weights[quality_key]
		if roll <= cumulative:
			pulled_quality = quality_key as int
			break

	var pool: Array[String] = pack.item_pool_ids
	var pulled_item_id: String = pool[randi() % pool.size()] if not pool.is_empty() else "unknown_item"
	var item_type: String = "rod"
	if pulled_item_id.begins_with("hook"):
		item_type = "hook"
	elif pulled_item_id.begins_with("lure"):
		item_type = "lure"
	elif pulled_item_id.begins_with("bait"):
		item_type = "bait"

	EquipmentManager.add_item(pulled_item_id, item_type, pulled_quality)

	SignalBus.tackle_box_pull_started.emit(pack_id)
	state_machine.push_state(UIStateMachine.State.TACKLE_BOX_REVEAL, {"item_id": pulled_item_id, "quality": pulled_quality})


func _find_pack_by_id(pack_id: String) -> TackleBoxPackDefinition:
	var pack_paths: Array[String] = [
		"res://data/gacha/basic_tackle_box.tres",
		"res://data/gacha/premium_tackle_box.tres",
		"res://data/gacha/legendary_tackle_box.tres",
	]
	for path: String in pack_paths:
		if not ResourceLoader.exists(path):
			continue
		var pack: TackleBoxPackDefinition = load(path) as TackleBoxPackDefinition
		if pack and pack.id == pack_id:
			return pack
	return null


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
