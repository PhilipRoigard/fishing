extends UIStateNode

var selected_uuid: String = ""
var item_name_label: Label
var quality_label: Label
var level_label: Label
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

	if item_name_label:
		var display_name: String = _get_display_name(entry)
		item_name_label.text = display_name
		item_name_label.modulate = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)

	var quality_name: String = Enums.QUALITY_NAMES.get(entry.quality, "Common")
	if quality_label:
		quality_label.text = quality_name
		quality_label.modulate = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)

	if level_label:
		level_label.text = "Level " + str(entry.level)

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
		var cost: int = quality_cfg.get_level_up_cost(entry.quality, entry.level)
		level_up_button.text = "Level Up (" + str(cost) + " coins)"
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
