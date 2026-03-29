extends UIStateNode

const QUALITY_BG_COLORS: Dictionary = {
	Enums.ItemQuality.COMMON: Color(0.3, 0.3, 0.3),
	Enums.ItemQuality.UNCOMMON: Color(0.15, 0.4, 0.15),
	Enums.ItemQuality.RARE: Color(0.15, 0.25, 0.5),
	Enums.ItemQuality.EPIC: Color(0.35, 0.15, 0.45),
	Enums.ItemQuality.LEGENDARY: Color(0.5, 0.4, 0.1),
}

var _bait_worm_texture: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_shrimp_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_squid_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")
var _rod_sheet_texture: Texture2D = preload("res://assets/sprites/character/fishing_rod_sheet.png")

var selected_uuid: String = ""
var item_name_label: Label
var quality_label: Label
var level_label: Label
var stats_label: Label
var equip_button: Button
var level_up_button: Button
var merge_button: Button
var icon_rect: TextureRect
var detail_panel_style: StyleBoxFlat


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
	bg.color = Color(0.02, 0.04, 0.08, 0.95)
	add_child(bg)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 20)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 20)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var detail_panel: PanelContainer = PanelContainer.new()
	detail_panel_style = StyleBoxFlat.new()
	detail_panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	detail_panel_style.corner_radius_top_left = 10
	detail_panel_style.corner_radius_top_right = 10
	detail_panel_style.corner_radius_bottom_left = 10
	detail_panel_style.corner_radius_bottom_right = 10
	detail_panel_style.border_width_bottom = 2
	detail_panel_style.border_width_top = 2
	detail_panel_style.border_width_left = 2
	detail_panel_style.border_width_right = 2
	detail_panel_style.border_color = Color(0.3, 0.3, 0.3)
	detail_panel_style.content_margin_top = 16
	detail_panel_style.content_margin_bottom = 16
	detail_panel_style.content_margin_left = 16
	detail_panel_style.content_margin_right = 16
	detail_panel.add_theme_stylebox_override("panel", detail_panel_style)
	vbox.add_child(detail_panel)

	var panel_vbox: VBoxContainer = VBoxContainer.new()
	panel_vbox.add_theme_constant_override("separation", 8)
	detail_panel.add_child(panel_vbox)

	var icon_center: CenterContainer = CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 72)
	panel_vbox.add_child(icon_center)

	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(64, 64)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_center.add_child(icon_rect)

	item_name_label = Label.new()
	item_name_label.text = ""
	item_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name_label.add_theme_font_size_override("font_size", 22)
	panel_vbox.add_child(item_name_label)

	quality_label = Label.new()
	quality_label.text = ""
	quality_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quality_label.add_theme_font_size_override("font_size", 14)
	panel_vbox.add_child(quality_label)

	level_label = Label.new()
	level_label.text = ""
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 14)
	panel_vbox.add_child(level_label)

	var separator: HSeparator = HSeparator.new()
	panel_vbox.add_child(separator)

	stats_label = Label.new()
	stats_label.text = ""
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	panel_vbox.add_child(stats_label)

	var button_container: VBoxContainer = VBoxContainer.new()
	button_container.add_theme_constant_override("separation", 8)
	vbox.add_child(button_container)

	equip_button = _create_action_button("Equip", Color(0.15, 0.35, 0.15))
	equip_button.pressed.connect(_on_equip_pressed)
	button_container.add_child(equip_button)

	level_up_button = _create_action_button("Level Up", Color(0.15, 0.25, 0.4))
	level_up_button.pressed.connect(_on_level_up_pressed)
	button_container.add_child(level_up_button)

	merge_button = _create_action_button("Merge", Color(0.3, 0.15, 0.35))
	merge_button.pressed.connect(_on_merge_pressed)
	button_container.add_child(merge_button)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var back_button: Button = _create_action_button("Back", Color(0.2, 0.2, 0.25))
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _create_action_button(text: String, bg_color: Color) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 48)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = bg_color
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", btn_style)

	var hover_style: StyleBoxFlat = btn_style.duplicate()
	hover_style.bg_color = bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style: StyleBoxFlat = btn_style.duplicate()
	pressed_style.bg_color = bg_color.darkened(0.15)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	return btn


func _populate_data() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return

	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var quality_bg: Color = QUALITY_BG_COLORS.get(entry.quality, Color(0.2, 0.2, 0.2))

	if detail_panel_style:
		detail_panel_style.bg_color = quality_bg.darkened(0.5)
		detail_panel_style.bg_color.a = 0.85
		detail_panel_style.border_color = quality_color

	if icon_rect:
		icon_rect.texture = _get_item_icon(entry.item_id, entry.equipment_type)

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
		level_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))

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


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _rod_sheet_texture
			atlas.region = Rect2(0, 0, 64, 64)
			return atlas
		"bait":
			match item_id:
				"worm", "worm_bait":
					return _bait_worm_texture
				"shrimp", "shrimp_bait":
					return _bait_shrimp_texture
				"squid", "squid_bait":
					return _bait_squid_texture
				_:
					return _bait_green_texture
		"hook":
			return _create_circle_texture(Color(0.7, 0.7, 0.75), 48)
		"lure":
			return _create_circle_texture(Color(0.3, 0.7, 1.0), 48)
	return _create_circle_texture(Color(0.5, 0.5, 0.5), 48)


func _create_circle_texture(color: Color, tex_size: int) -> ImageTexture:
	var img: Image = Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(tex_size / 2.0, tex_size / 2.0)
	var radius: float = tex_size / 2.0 - 2.0
	for x: int in tex_size:
		for y: int in tex_size:
			var dist: float = Vector2(x, y).distance_to(center)
			if dist <= radius:
				var alpha: float = clampf(1.0 - (dist - radius + 2.0) / 2.0, 0.0, 1.0)
				img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)


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
		"bait":
			return Enums.EquipmentSlot.BAIT
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
