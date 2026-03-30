extends UIStateNode

var _folley_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
var _bait_worm: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_blue: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_pink: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")

var selected_uuid: String = ""
var item_name_label: Label
var stats_label: Label
var equip_button: Button
var level_up_button: Button
var icon_rect: TextureRect


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
	var dimmer: ColorRect = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.6)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var dismiss_btn: Button = Button.new()
	dismiss_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	dismiss_btn.modulate = Color(1, 1, 1, 0)
	dismiss_btn.pressed.connect(_back)
	add_child(dismiss_btn)

	var popup: PanelContainer = PanelContainer.new()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.offset_left = -150
	popup.offset_right = 150
	popup.offset_top = -95
	popup.offset_bottom = 95
	popup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var popup_style: StyleBoxFlat = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.9, 0.88, 0.82)
	popup_style.corner_radius_top_left = 8
	popup_style.corner_radius_top_right = 8
	popup_style.corner_radius_bottom_left = 8
	popup_style.corner_radius_bottom_right = 8
	popup_style.border_width_bottom = 3
	popup_style.border_width_top = 3
	popup_style.border_width_left = 3
	popup_style.border_width_right = 3
	popup_style.border_color = Color(0.3, 0.3, 0.3)
	popup_style.content_margin_top = 12
	popup_style.content_margin_bottom = 12
	popup_style.content_margin_left = 12
	popup_style.content_margin_right = 12
	popup.add_theme_stylebox_override("panel", popup_style)
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	popup.add_child(vbox)

	var header_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(header_row)
	var header_spacer: Control = Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_spacer)
	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(28, 28)
	close_btn.add_theme_font_size_override("font_size", 14)
	var close_style: StyleBoxFlat = StyleBoxFlat.new()
	close_style.bg_color = Color(0.7, 0.2, 0.15)
	close_style.corner_radius_top_left = 4
	close_style.corner_radius_top_right = 4
	close_style.corner_radius_bottom_left = 4
	close_style.corner_radius_bottom_right = 4
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_color_override("font_color", Color.WHITE)
	close_btn.pressed.connect(_back)
	header_row.add_child(close_btn)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)

	var icon_panel: PanelContainer = PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(80, 80)
	var icon_bg: StyleBoxFlat = StyleBoxFlat.new()
	icon_bg.bg_color = Color(0.3, 0.5, 0.8)
	icon_bg.corner_radius_top_left = 6
	icon_bg.corner_radius_top_right = 6
	icon_bg.corner_radius_bottom_left = 6
	icon_bg.corner_radius_bottom_right = 6
	icon_bg.content_margin_top = 8
	icon_bg.content_margin_bottom = 8
	icon_bg.content_margin_left = 8
	icon_bg.content_margin_right = 8
	icon_panel.add_theme_stylebox_override("panel", icon_bg)
	top_row.add_child(icon_panel)

	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(64, 64)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_panel.add_child(icon_rect)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	top_row.add_child(info_vbox)

	item_name_label = Label.new()
	item_name_label.text = ""
	item_name_label.add_theme_font_size_override("font_size", 16)
	item_name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	info_vbox.add_child(item_name_label)

	stats_label = Label.new()
	stats_label.text = ""
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25))
	info_vbox.add_child(stats_label)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	equip_button = Button.new()
	equip_button.text = "Equip"
	equip_button.custom_minimum_size = Vector2(0, 36)
	equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var equip_style: StyleBoxFlat = StyleBoxFlat.new()
	equip_style.bg_color = Color(0.7, 0.2, 0.2)
	equip_style.corner_radius_top_left = 4
	equip_style.corner_radius_top_right = 4
	equip_style.corner_radius_bottom_left = 4
	equip_style.corner_radius_bottom_right = 4
	equip_button.add_theme_stylebox_override("normal", equip_style)
	equip_button.add_theme_color_override("font_color", Color.WHITE)
	equip_button.pressed.connect(_on_equip_pressed)
	btn_row.add_child(equip_button)

	level_up_button = Button.new()
	level_up_button.text = "Level Up"
	level_up_button.custom_minimum_size = Vector2(0, 36)
	level_up_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var level_style: StyleBoxFlat = StyleBoxFlat.new()
	level_style.bg_color = Color(0.4, 0.4, 0.4)
	level_style.corner_radius_top_left = 4
	level_style.corner_radius_top_right = 4
	level_style.corner_radius_bottom_left = 4
	level_style.corner_radius_bottom_right = 4
	level_up_button.add_theme_stylebox_override("normal", level_style)
	level_up_button.add_theme_color_override("font_color", Color.WHITE)
	level_up_button.pressed.connect(_on_level_up_pressed)
	btn_row.add_child(level_up_button)


func _populate_data() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return

	var display_name: String = _get_display_name(entry)
	var quality_name: String = Enums.QUALITY_NAMES.get(entry.quality, "Common")
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.GRAY)

	item_name_label.text = display_name + " Lv." + str(entry.level) + "\n" + quality_name
	item_name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))

	icon_rect.texture = _get_item_icon(entry.item_id, entry.equipment_type)

	var is_equipped: bool = _is_item_equipped(entry.uuid)
	equip_button.text = "Unequip" if is_equipped else "Equip"

	var quality_cfg: Variant = null
	if GameResources.config:
		quality_cfg = GameResources.config.quality_config
	if quality_cfg:
		var cost: int = quality_cfg.get_level_up_cost(entry.quality, entry.level)
		var cap: int = quality_cfg.get_level_cap(entry.quality)
		if entry.level >= cap:
			level_up_button.text = "Max Level"
			level_up_button.disabled = true
		else:
			level_up_button.text = "Level Up  " + str(cost)
			level_up_button.disabled = not CurrencyManager.can_afford_coins(cost)

	var stats_text: String = ""
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: Variant = GameResources.config.equipment_catalogue
		var quality_mult: float = Enums.QUALITY_MULTIPLIERS.get(entry.quality, 1.0)
		match entry.equipment_type:
			"rod":
				var rod: Variant = cat.get_rod_by_id(entry.item_id)
				if rod:
					var depth: float = rod.cast_depth_range + rod.cast_depth_per_level * entry.level * quality_mult
					var reel: float = rod.reel_speed + rod.reel_speed_per_level * entry.level * quality_mult
					stats_text = "Cast: " + str(int(depth)) + "m\nReel: " + str(snapped(reel, 0.1)) + "x"
			"hook":
				var hook: Variant = cat.get_hook_by_id(entry.item_id)
				if hook:
					stats_text = "Bite Window: +" + str(snapped(hook.bite_window_bonus, 0.1)) + "s\nCatch: +" + str(int(hook.catch_rate_bonus * 100)) + "%"
			"lure":
				var lure: Variant = cat.get_lure_by_id(entry.item_id)
				if lure:
					stats_text = "Rare Chance: +" + str(int(lure.rare_fish_chance_bonus * 100)) + "%"
	stats_label.text = stats_text


func _on_equip_pressed() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return
	var slot: int = _get_slot_for_type(entry.equipment_type)
	if slot < 0:
		return
	if _is_item_equipped(entry.uuid):
		EquipmentManager.unequip(slot)
	else:
		EquipmentManager.equip(slot, entry.uuid)
	_populate_data()


func _on_level_up_pressed() -> void:
	if EquipmentManager.level_up(selected_uuid):
		_populate_data()


func _get_slot_for_type(equipment_type: String) -> int:
	match equipment_type:
		"rod": return Enums.EquipmentSlot.ROD
		"hook": return Enums.EquipmentSlot.HOOK
		"lure": return Enums.EquipmentSlot.LURE
		"bait": return Enums.EquipmentSlot.BAIT
	return -1


func _is_item_equipped(uuid: String) -> bool:
	for slot: Enums.EquipmentSlot in [Enums.EquipmentSlot.ROD, Enums.EquipmentSlot.HOOK, Enums.EquipmentSlot.LURE, Enums.EquipmentSlot.BAIT]:
		var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot)
		if equipped and equipped.uuid == uuid:
			return true
	return false


func _get_display_name(entry: EquipmentManager.EquipmentEntry) -> String:
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: Variant = GameResources.config.equipment_catalogue
		var data: Variant = null
		match entry.equipment_type:
			"rod": data = cat.get_rod_by_id(entry.item_id)
			"hook": data = cat.get_hook_by_id(entry.item_id)
			"lure": data = cat.get_lure_by_id(entry.item_id)
			"bait": data = cat.get_bait_by_id(entry.item_id)
		if data and data.display_name != "":
			return data.display_name
	return entry.item_id


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"bronze_rod": atlas.region = Rect2(65, 2, 15, 15)
				"silver_rod": atlas.region = Rect2(81, 2, 15, 15)
				"gold_rod": atlas.region = Rect2(81, 2, 15, 15)
				_: atlas.region = Rect2(49, 2, 15, 14)
			return atlas
		"hook":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"barbed_hook": atlas.region = Rect2(17, 1, 14, 16)
				"titanium_hook": atlas.region = Rect2(33, 1, 14, 16)
				_: atlas.region = Rect2(1, 0, 14, 17)
			return atlas
		"lure":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"shiny_lure": atlas.region = Rect2(113, 1, 15, 16)
				"golden_lure": atlas.region = Rect2(128, 1, 15, 16)
				_: atlas.region = Rect2(97, 3, 13, 13)
			return atlas
		"bait":
			match item_id:
				"worm": return _bait_worm
				"shrimp": return _bait_blue
				"squid_bait": return _bait_pink
				_: return _bait_green
	return _bait_green


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
