extends UIStateNode

var selected_uuid: String = ""
var item_name_label: Label
var quality_label: Label
var level_label: Label
var stats_label: Label
var equip_button: Button
var level_up_button: Button
var merge_button: Button


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		selected_uuid = meta.get("uuid", "")
	_build_layout()
	_populate_data()


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
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 20)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 20)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	item_name_label = Label.new()
	item_name_label.text = ""
	item_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(item_name_label)

	quality_label = Label.new()
	quality_label.text = ""
	quality_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(quality_label)

	level_label = Label.new()
	level_label.text = ""
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_label)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	stats_label = Label.new()
	stats_label.text = ""
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stats_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(stats_label)

	var separator2: HSeparator = HSeparator.new()
	vbox.add_child(separator2)

	equip_button = Button.new()
	equip_button.text = "Equip"
	equip_button.custom_minimum_size = Vector2(200, 50)
	equip_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	equip_button.pressed.connect(_on_equip_pressed)
	vbox.add_child(equip_button)

	level_up_button = Button.new()
	level_up_button.text = "Level Up"
	level_up_button.custom_minimum_size = Vector2(200, 50)
	level_up_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	level_up_button.pressed.connect(_on_level_up_pressed)
	vbox.add_child(level_up_button)

	merge_button = Button.new()
	merge_button.text = "Merge"
	merge_button.custom_minimum_size = Vector2(200, 50)
	merge_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	merge_button.pressed.connect(_on_merge_pressed)
	vbox.add_child(merge_button)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _populate_data() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return

	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)

	if item_name_label:
		var display_name: String = _get_display_name(entry)
		item_name_label.text = display_name
		item_name_label.add_theme_color_override("font_color", quality_color)

	var quality_name: String = Enums.QUALITY_NAMES.get(entry.quality, "Common")
	if quality_label:
		quality_label.text = quality_name
		quality_label.add_theme_color_override("font_color", quality_color)

	if level_label:
		level_label.text = "Level " + str(entry.level)

	if stats_label:
		stats_label.text = _get_stats_text(entry)

	var is_equipped: bool = _is_item_equipped(entry)
	if equip_button:
		equip_button.text = "Unequip" if is_equipped else "Equip"

	_update_level_up_cost(entry)


func _update_level_up_cost(entry: EquipmentManager.EquipmentEntry) -> void:
	if not level_up_button:
		return
	var quality_cfg: QualityConfig = null
	if GameResources.config:
		quality_cfg = GameResources.config.quality_config
	if quality_cfg:
		var cap: int = quality_cfg.get_level_cap(entry.quality)
		if entry.level >= cap:
			level_up_button.text = "Max Level"
			level_up_button.disabled = true
		else:
			var cost: int = quality_cfg.get_level_up_cost(entry.quality, entry.level)
			level_up_button.text = "Level Up (" + str(cost) + " coins)"
			level_up_button.disabled = false
	else:
		level_up_button.text = "Level Up"


func _get_display_name(entry: EquipmentManager.EquipmentEntry) -> String:
	if not GameResources.config or not GameResources.config.equipment_catalogue:
		return entry.item_id
	var catalogue: Variant = GameResources.config.equipment_catalogue
	match entry.equipment_type:
		"rod":
			var data: Variant = catalogue.get_rod_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"hook":
			var data: Variant = catalogue.get_hook_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"lure":
			var data: Variant = catalogue.get_lure_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"bait":
			var data: Variant = catalogue.get_bait_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
	return entry.item_id


func _get_stats_text(entry: EquipmentManager.EquipmentEntry) -> String:
	if not GameResources.config or not GameResources.config.equipment_catalogue:
		return ""
	var catalogue: Variant = GameResources.config.equipment_catalogue
	var quality_mult: float = Enums.QUALITY_MULTIPLIERS.get(entry.quality, 1.0)
	match entry.equipment_type:
		"rod":
			var data: Variant = catalogue.get_rod_by_id(entry.item_id)
			if data:
				var depth: float = data.cast_depth_range + (data.cast_depth_per_level * (entry.level - 1) * quality_mult)
				var reel: float = data.reel_speed + (data.reel_speed_per_level * (entry.level - 1) * quality_mult)
				var tension: float = data.tension_resistance + (data.tension_resistance_per_level * (entry.level - 1) * quality_mult)
				return "Cast Depth: " + str(int(depth)) + "m\nReel Speed: " + str(snapped(reel, 0.01)) + "x\nTension Resistance: " + str(snapped(tension, 0.01)) + "x"
		"hook":
			var data: Variant = catalogue.get_hook_by_id(entry.item_id)
			if data:
				var bite: float = data.bite_window_bonus + (data.bite_window_per_level * (entry.level - 1) * quality_mult)
				var catch_rate: float = data.catch_rate_bonus + (data.catch_rate_per_level * (entry.level - 1) * quality_mult)
				return "Bite Window: +" + str(snapped(bite * 100.0, 0.1)) + "%\nCatch Rate: +" + str(snapped(catch_rate * 100.0, 0.1)) + "%"
		"lure":
			var data: Variant = catalogue.get_lure_by_id(entry.item_id)
			if data:
				var rare: float = data.rare_fish_chance_bonus + (data.rare_fish_chance_per_level * (entry.level - 1) * quality_mult)
				var bite_spd: float = data.bite_speed_bonus + (data.bite_speed_per_level * (entry.level - 1) * quality_mult)
				return "Rare Fish Chance: +" + str(snapped(rare * 100.0, 0.1)) + "%\nBite Speed: +" + str(snapped(bite_spd * 100.0, 0.1)) + "%"
	return ""


func _is_item_equipped(entry: EquipmentManager.EquipmentEntry) -> bool:
	var slot: Enums.EquipmentSlot = _get_slot_for_type(entry.equipment_type)
	var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot)
	return equipped != null and equipped.uuid == entry.uuid


func _get_slot_for_type(equipment_type: String) -> Enums.EquipmentSlot:
	match equipment_type:
		"rod":
			return Enums.EquipmentSlot.ROD
		"hook":
			return Enums.EquipmentSlot.HOOK
		"lure":
			return Enums.EquipmentSlot.LURE
	return Enums.EquipmentSlot.ROD


func _on_equip_pressed() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return
	HapticManager.light_tap()
	var slot: Enums.EquipmentSlot = _get_slot_for_type(entry.equipment_type)
	if _is_item_equipped(entry):
		EquipmentManager.unequip(slot)
	else:
		EquipmentManager.equip(slot, entry.uuid)
	_populate_data()


func _on_level_up_pressed() -> void:
	HapticManager.light_tap()
	var success: bool = EquipmentManager.level_up(selected_uuid)
	if success:
		HapticManager.success_feedback()
	_populate_data()


func _on_merge_pressed() -> void:
	HapticManager.light_tap()
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return

	var candidates: Array[String] = []
	for other: EquipmentManager.EquipmentEntry in EquipmentManager.inventory:
		if other.uuid != selected_uuid and other.item_id == entry.item_id and other.quality == entry.quality:
			candidates.append(other.uuid)

	if candidates.is_empty():
		SignalBus.show_notification.emit("No merge candidates available", Color.YELLOW)
		return

	var merge_uuids: Array[String] = [selected_uuid]
	merge_uuids.append_array(candidates)
	var new_uuid: String = EquipmentManager.merge(merge_uuids)
	if new_uuid != "":
		selected_uuid = new_uuid
		HapticManager.success_feedback()
		_populate_data()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
