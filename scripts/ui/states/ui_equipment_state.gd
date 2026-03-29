extends UIStateNode

const QUALITY_BG_COLORS: Dictionary = {
	Enums.ItemQuality.COMMON: Color(0.45, 0.45, 0.45),
	Enums.ItemQuality.UNCOMMON: Color(0.3, 0.65, 0.15),
	Enums.ItemQuality.RARE: Color(0.2, 0.45, 0.85),
	Enums.ItemQuality.EPIC: Color(0.6, 0.25, 0.8),
	Enums.ItemQuality.LEGENDARY: Color(0.85, 0.7, 0.1),
}

const SLOT_NAMES: Array[String] = ["Rod", "Hook", "Lure", "Bait"]
const SLOT_TYPES: Array[Enums.EquipmentSlot] = [
	Enums.EquipmentSlot.ROD,
	Enums.EquipmentSlot.HOOK,
	Enums.EquipmentSlot.LURE,
	Enums.EquipmentSlot.BAIT,
]

const FILTER_LABELS: Array[String] = ["All", "Rod", "Hk", "Lr", "Bt", "Shop"]
const FILTER_TYPES: Array[String] = ["", "rod", "hook", "lure", "bait", "shop"]
const SHOP_FILTER_INDEX: int = 5

var _bait_worm_texture: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_shrimp_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_squid_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")
var _rod_sheet_texture: Texture2D = preload("res://assets/sprites/character/fishing_rod_sheet.png")
var _folley_sheet_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")

var grid: GridContainer
var filter_container: HBoxContainer
var active_filter: int = 0
var slot_containers: Array[PanelContainer] = []
var bottom_bar: HBoxContainer
var active_tab: int = 0


class ShopItem:
	var item_id: String
	var equipment_type: String
	var display_name: String
	var cost_coins: int
	var required_level: int
	var quality: int

	func _init(
		p_item_id: String = "",
		p_type: String = "",
		p_name: String = "",
		p_cost: int = 0,
		p_level: int = 1,
		p_quality: int = 0
	) -> void:
		item_id = p_item_id
		equipment_type = p_type
		display_name = p_name
		cost_coins = p_cost
		required_level = p_level
		quality = p_quality


var shop_items: Array[ShopItem] = []


func _init() -> void:
	super()
	_build_shop_items()


func _build_shop_items() -> void:
	shop_items.clear()
	shop_items.append(ShopItem.new("bronze_rod", "rod", "Bronze Rod", 300, 2, Enums.ItemQuality.UNCOMMON))
	shop_items.append(ShopItem.new("barbed_hook", "hook", "Barbed Hook", 200, 2, Enums.ItemQuality.UNCOMMON))
	shop_items.append(ShopItem.new("shiny_lure", "lure", "Shiny Lure", 500, 4, Enums.ItemQuality.RARE))
	shop_items.append(ShopItem.new("silver_rod", "rod", "Silver Rod", 800, 4, Enums.ItemQuality.RARE))
	shop_items.append(ShopItem.new("titanium_hook", "hook", "Titanium Hook", 600, 6, Enums.ItemQuality.EPIC))
	shop_items.append(ShopItem.new("golden_lure", "lure", "Golden Lure", 1000, 6, Enums.ItemQuality.EPIC))
	shop_items.append(ShopItem.new("gold_rod", "rod", "Gold Rod", 2000, 8, Enums.ItemQuality.LEGENDARY))


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_all()


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
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 8)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 8)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	_build_currency_bar(vbox)

	_build_equipment_slots(vbox)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	filter_container = HBoxContainer.new()
	filter_container.add_theme_constant_override("separation", 2)
	vbox.add_child(filter_container)

	for i: int in FILTER_LABELS.size():
		var btn: Button = Button.new()
		btn.text = FILTER_LABELS[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 28)
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(_on_filter_pressed.bind(i))
		filter_container.add_child(btn)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid_margin: MarginContainer = MarginContainer.new()
	grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_margin.add_theme_constant_override("margin_left", 2)
	grid_margin.add_theme_constant_override("margin_right", 2)
	scroll.add_child(grid_margin)

	grid = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid_margin.add_child(grid)

	_build_bottom_bar(vbox)


func _build_currency_bar(parent: VBoxContainer) -> void:
	var currency_hbox: HBoxContainer = HBoxContainer.new()
	currency_hbox.add_theme_constant_override("separation", 8)
	parent.add_child(currency_hbox)

	var back_btn: Button = Button.new()
	back_btn.text = "<"
	back_btn.custom_minimum_size = Vector2(32, 32)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_back)
	currency_hbox.add_child(back_btn)

	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	currency_hbox.add_child(spacer)

	var coin_label: Label = Label.new()
	coin_label.text = "Coins: " + str(CurrencyManager.coins)
	coin_label.add_theme_font_size_override("font_size", 12)
	coin_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	currency_hbox.add_child(coin_label)

	var gem_label: Label = Label.new()
	gem_label.text = "Gems: " + str(CurrencyManager.gems)
	gem_label.add_theme_font_size_override("font_size", 12)
	gem_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	currency_hbox.add_child(gem_label)


func _build_equipment_slots(parent: VBoxContainer) -> void:
	var slots_hbox: HBoxContainer = HBoxContainer.new()
	slots_hbox.add_theme_constant_override("separation", 6)
	slots_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(slots_hbox)

	slot_containers.clear()
	for i: int in SLOT_NAMES.size():
		var slot_panel: PanelContainer = _create_equipment_slot(SLOT_NAMES[i], SLOT_TYPES[i])
		slots_hbox.add_child(slot_panel)
		slot_containers.append(slot_panel)


func _create_equipment_slot(slot_name: String, slot_type: Enums.EquipmentSlot) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 95)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.15)
	style.border_color = Color(0.25, 0.25, 0.3)
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.content_margin_left = 4
	style.content_margin_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var inner_vbox: VBoxContainer = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 2)
	inner_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(inner_vbox)

	var slot_label: Label = Label.new()
	slot_label.text = slot_name
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_label.add_theme_font_size_override("font_size", 10)
	slot_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	inner_vbox.add_child(slot_label)

	var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot_type)

	if equipped:
		var quality_color: Color = Enums.QUALITY_COLORS.get(equipped.quality, Color.WHITE)
		var quality_bg: Color = QUALITY_BG_COLORS.get(equipped.quality, Color(0.15, 0.15, 0.15))
		style.border_color = quality_color
		style.border_width_bottom = 2
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.bg_color = quality_bg.darkened(0.3)

		var icon_container: CenterContainer = CenterContainer.new()
		icon_container.custom_minimum_size = Vector2(56, 56)
		inner_vbox.add_child(icon_container)

		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = Vector2(52, 52)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.texture = _get_item_icon(equipped.item_id, equipped.equipment_type)
		icon_container.add_child(icon)

		var level_label: Label = Label.new()
		level_label.text = "Lv." + str(equipped.level)
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.add_theme_font_size_override("font_size", 9)
		level_label.add_theme_color_override("font_color", quality_color)
		inner_vbox.add_child(level_label)
	else:
		var empty_label: Label = Label.new()
		empty_label.text = "Empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 11)
		empty_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
		empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		inner_vbox.add_child(empty_label)

	return panel


func _build_bottom_bar(parent: VBoxContainer) -> void:
	var bottom_hbox: HBoxContainer = HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 8)
	parent.add_child(bottom_hbox)
	bottom_bar = bottom_hbox

	var equip_tab_btn: Button = Button.new()
	equip_tab_btn.text = "Equipment"
	equip_tab_btn.custom_minimum_size = Vector2(0, 40)
	equip_tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if active_tab == 0:
		var active_style: StyleBoxFlat = StyleBoxFlat.new()
		active_style.bg_color = Color(0.15, 0.25, 0.4)
		active_style.corner_radius_top_left = 4
		active_style.corner_radius_top_right = 4
		active_style.corner_radius_bottom_left = 4
		active_style.corner_radius_bottom_right = 4
		equip_tab_btn.add_theme_stylebox_override("normal", active_style)
	equip_tab_btn.pressed.connect(_on_tab_pressed.bind(0))
	bottom_hbox.add_child(equip_tab_btn)

	var merge_tab_btn: Button = Button.new()
	merge_tab_btn.text = "Merge"
	merge_tab_btn.custom_minimum_size = Vector2(0, 40)
	merge_tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if active_tab == 1:
		var active_style: StyleBoxFlat = StyleBoxFlat.new()
		active_style.bg_color = Color(0.15, 0.25, 0.4)
		active_style.corner_radius_top_left = 4
		active_style.corner_radius_top_right = 4
		active_style.corner_radius_bottom_left = 4
		active_style.corner_radius_bottom_right = 4
		merge_tab_btn.add_theme_stylebox_override("normal", active_style)
	merge_tab_btn.pressed.connect(_on_tab_pressed.bind(1))
	bottom_hbox.add_child(merge_tab_btn)


func _refresh_all() -> void:
	_refresh_grid()
	_update_filter_buttons()
	if bottom_bar:
		var is_shop: bool = FILTER_TYPES[active_filter] == "shop"
		bottom_bar.visible = not is_shop


func _update_filter_buttons() -> void:
	if not filter_container:
		return
	for i: int in filter_container.get_child_count():
		var btn: Button = filter_container.get_child(i) as Button
		if not btn:
			continue
		if i == active_filter:
			var active_style: StyleBoxFlat = StyleBoxFlat.new()
			active_style.bg_color = Color(0.2, 0.35, 0.5)
			active_style.corner_radius_top_left = 4
			active_style.corner_radius_top_right = 4
			active_style.corner_radius_bottom_left = 4
			active_style.corner_radius_bottom_right = 4
			btn.add_theme_stylebox_override("normal", active_style)
		else:
			btn.remove_theme_stylebox_override("normal")


func _refresh_grid() -> void:
	for child: Node in grid.get_children():
		child.queue_free()

	var filter_type: String = FILTER_TYPES[active_filter]

	if filter_type == "shop":
		_populate_shop_grid()
		return

	var items: Array[EquipmentManager.EquipmentEntry] = []
	items.assign(EquipmentManager.inventory)

	if filter_type != "":
		var filtered: Array[EquipmentManager.EquipmentEntry] = []
		filtered.assign(items.filter(func(e: EquipmentManager.EquipmentEntry) -> bool: return e.equipment_type == filter_type))
		items = filtered

	items.sort_custom(_sort_equipment)

	for entry: EquipmentManager.EquipmentEntry in items:
		var cell: Control = _create_item_card(entry)
		grid.add_child(cell)


func _populate_shop_grid() -> void:
	var player_level: int = ProgressManager.get_current_level()
	for shop_item: ShopItem in shop_items:
		var cell: PanelContainer = _create_shop_card(shop_item, player_level)
		grid.add_child(cell)


func _create_shop_card(shop_item: ShopItem, player_level: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(100, 110)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var meets_level: bool = player_level >= shop_item.required_level
	var can_afford: bool = CurrencyManager.can_afford_coins(shop_item.cost_coins)

	var quality_bg: Color = QUALITY_BG_COLORS.get(shop_item.quality, Color(0.3, 0.3, 0.3))
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = quality_bg
	style.border_color = quality_bg.lightened(0.3)
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.content_margin_left = 6
	style.content_margin_right = 6
	panel.add_theme_stylebox_override("panel", style)

	var card_vbox: VBoxContainer = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 2)
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(card_vbox)

	var icon_center: CenterContainer = CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(64, 64)
	card_vbox.add_child(icon_center)

	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.texture = _get_item_icon(shop_item.item_id, shop_item.equipment_type)
	icon_center.add_child(icon)

	var name_label: Label = Label.new()
	name_label.text = shop_item.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	card_vbox.add_child(name_label)

	var buy_btn: Button = Button.new()
	if not meets_level:
		buy_btn.text = "Lv." + str(shop_item.required_level) + " | " + str(shop_item.cost_coins)
		buy_btn.disabled = true
	elif not can_afford:
		buy_btn.text = str(shop_item.cost_coins) + " coins"
		buy_btn.disabled = true
	else:
		buy_btn.text = "Buy " + str(shop_item.cost_coins)
	buy_btn.custom_minimum_size = Vector2(80, 26)
	buy_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buy_btn.add_theme_font_size_override("font_size", 10)
	buy_btn.pressed.connect(_on_buy_pressed.bind(shop_item))
	card_vbox.add_child(buy_btn)

	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	return panel


func _on_shop_card_pressed(shop_item: ShopItem) -> void:
	HapticManager.light_tap()
	state_machine.show_tooltip(shop_item.display_name + " (" + Enums.QUALITY_NAMES.get(shop_item.quality, "Common") + ")\n\nType: " + shop_item.equipment_type.capitalize() + "\nCost: " + str(shop_item.cost_coins) + " coins\nRequires: Lv." + str(shop_item.required_level))


func _on_buy_pressed(shop_item: ShopItem) -> void:
	HapticManager.medium_tap()

	if not CurrencyManager.can_afford_coins(shop_item.cost_coins):
		SignalBus.show_notification.emit("Not enough coins!", Color.RED)
		return

	var player_level: int = ProgressManager.get_current_level()
	if player_level < shop_item.required_level:
		SignalBus.show_notification.emit("Requires Lv." + str(shop_item.required_level), Color.RED)
		return

	CurrencyManager.spend_coins(shop_item.cost_coins)
	EquipmentManager.add_item(shop_item.item_id, shop_item.equipment_type, 0)
	SignalBus.show_notification.emit("Purchased " + shop_item.display_name + "!", Color(0.2, 0.8, 0.2))
	_refresh_all()


func _sort_equipment(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool:
	var a_equipped: bool = _is_item_equipped(a.uuid)
	var b_equipped: bool = _is_item_equipped(b.uuid)
	if a_equipped != b_equipped:
		return a_equipped
	if a.quality != b.quality:
		return a.quality > b.quality
	return a.level > b.level


func _create_item_card(entry: EquipmentManager.EquipmentEntry) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(100, 110)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var quality_bg: Color = QUALITY_BG_COLORS.get(entry.quality, Color(0.2, 0.2, 0.2))
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var is_equipped: bool = _is_item_equipped(entry.uuid)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = quality_bg
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.content_margin_left = 6
	style.content_margin_right = 6

	if is_equipped:
		style.border_color = quality_color
		style.border_width_bottom = 2
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
	else:
		style.border_color = quality_bg.lightened(0.2)
		style.border_width_bottom = 1
		style.border_width_top = 1
		style.border_width_left = 1
		style.border_width_right = 1

	panel.add_theme_stylebox_override("panel", style)

	var card_vbox: VBoxContainer = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 2)
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(card_vbox)

	var icon_center: CenterContainer = CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(64, 64)
	card_vbox.add_child(icon_center)

	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.texture = _get_item_icon(entry.item_id, entry.equipment_type)
	icon_center.add_child(icon)

	var display_name: String = _get_display_name_for_entry(entry)
	var name_label: Label = Label.new()
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.custom_minimum_size = Vector2(0, 16)
	card_vbox.add_child(name_label)

	var bottom_row: HBoxContainer = HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_END
	card_vbox.add_child(bottom_row)

	if is_equipped:
		var equipped_badge: Label = Label.new()
		equipped_badge.text = "EQ"
		equipped_badge.add_theme_font_size_override("font_size", 9)
		equipped_badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		equipped_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bottom_row.add_child(equipped_badge)

	var level_badge: Label = Label.new()
	level_badge.text = "Lv." + str(entry.level)
	level_badge.add_theme_font_size_override("font_size", 10)
	level_badge.add_theme_color_override("font_color", quality_color)
	level_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if not is_equipped:
		level_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(level_badge)

	var click_btn: Button = Button.new()
	click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_btn.flat = true
	click_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var transparent_style: StyleBoxEmpty = StyleBoxEmpty.new()
	click_btn.add_theme_stylebox_override("normal", transparent_style)
	click_btn.add_theme_stylebox_override("hover", transparent_style)
	click_btn.add_theme_stylebox_override("pressed", transparent_style)
	click_btn.add_theme_stylebox_override("focus", transparent_style)
	click_btn.pressed.connect(_on_item_pressed.bind(entry.uuid))
	panel.add_child(click_btn)

	return panel


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_sheet_texture
			match item_id:
				"bronze_rod":
					atlas.region = Rect2(65, 2, 15, 15)
				"silver_rod":
					atlas.region = Rect2(81, 2, 15, 15)
				"gold_rod":
					atlas.region = Rect2(81, 2, 15, 15)
				_:
					atlas.region = Rect2(49, 2, 15, 14)
			return atlas
		"bait":
			match item_id:
				"worm", "worm_bait":
					return _bait_worm_texture
				"shrimp", "shrimp_bait":
					return _bait_shrimp_texture
				"squid", "squid_bait":
					return _bait_squid_texture
				"golden_bait":
					return _bait_squid_texture
				_:
					return _bait_green_texture
		"hook":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_sheet_texture
			match item_id:
				"barbed_hook":
					atlas.region = Rect2(17, 1, 14, 16)
				"titanium_hook":
					atlas.region = Rect2(33, 1, 14, 16)
				_:
					atlas.region = Rect2(1, 0, 14, 17)
			return atlas
		"lure":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_sheet_texture
			match item_id:
				"shiny_lure":
					atlas.region = Rect2(113, 1, 15, 16)
				"golden_lure":
					atlas.region = Rect2(128, 1, 15, 16)
				_:
					atlas.region = Rect2(97, 3, 13, 13)
			return atlas
	return _bait_green_texture



func _get_display_name_for_entry(entry: EquipmentManager.EquipmentEntry) -> String:
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


func _is_item_equipped(uuid: String) -> bool:
	for slot: Enums.EquipmentSlot in SLOT_TYPES:
		var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot)
		if equipped and equipped.uuid == uuid:
			return true
	return false


func _on_filter_pressed(index: int) -> void:
	active_filter = index
	HapticManager.light_tap()
	_refresh_all()


func _on_tab_pressed(tab: int) -> void:
	HapticManager.light_tap()
	active_tab = tab
	_clear_children()
	_build_layout()
	_refresh_all()


func _on_item_pressed(uuid: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"uuid": uuid})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
