extends UIStateNode


const _empty_slot_style: StyleBox = preload("res://resources/ui/Style Boxes/StyleBoxFlat/empty_slot.tres")
const _item_card_scene: PackedScene = preload("res://scenes/ui/components/item_card.tscn")

const SLOT_NAMES: Array[String] = ["Rod", "Hook", "Lure", "Bait"]
const SLOT_TYPES: Array[Enums.EquipmentSlot] = [
	Enums.EquipmentSlot.ROD,
	Enums.EquipmentSlot.HOOK,
	Enums.EquipmentSlot.LURE,
	Enums.EquipmentSlot.BAIT,
]

const FILTER_LABELS: Array[String] = ["All", "Rod", "Hook", "Lure", "Bait"]
const FILTER_TYPES: Array[String] = ["", "rod", "hook", "lure", "bait"]

var _bait_worm_texture: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_shrimp_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_squid_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")
var _rod_sheet_texture: Texture2D = preload("res://assets/sprites/character/fishing_rod_sheet.png")
var _folley_sheet_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")

class BaitStack:
	var quality: int
	var count: int
	func _init(p_quality: int = 0, p_count: int = 0) -> void:
		quality = p_quality
		count = p_count

var _bait_textures: Dictionary = {
	1: preload("res://assets/sprites/items/Bait_01.png"),
	2: preload("res://assets/sprites/items/Bait_01_blue.png"),
	3: preload("res://assets/sprites/items/Bait_01_pink.png"),
	4: preload("res://assets/sprites/items/Bait_01_green.png"),
}

var item_grid: VirtualizedItemGrid
var scroll: ScrollContainer
var filter_container: HBoxContainer
var active_filter: int = 0
var slot_containers: Array[PanelContainer] = []


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_all()


func focus() -> void:
	super()
	_clear_children()
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
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 40)
	margin.add_theme_constant_override("margin_bottom", 78)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

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

	scroll = ScrollContainer.new()
	scroll.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	item_grid = VirtualizedItemGrid.new()
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(item_grid)
	item_grid.setup(scroll, _configure_card)
	scroll.resized.connect(func() -> void: item_grid.update_columns(scroll.size.x - 24.0))




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
	var item_card_scene: PackedScene = _item_card_scene

	if slot_type == Enums.EquipmentSlot.BAIT:
		return _create_bait_slot(item_card_scene, slot_name)

	var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot_type)

	if equipped:
		var card: ItemCard = item_card_scene.instantiate() as ItemCard
		var quality_color: Color = Enums.QUALITY_COLORS.get(equipped.quality, Color.WHITE)
		var icon_texture: Texture2D = _get_item_icon(equipped.item_id, equipped.equipment_type)
		var eq_uuid: String = equipped.uuid
		card.ready.connect(func() -> void:
			card.set_item_data(equipped.item_id, eq_uuid, icon_texture, equipped.level, quality_color)
			card.selected.connect(_on_item_pressed.bind(eq_uuid))
		)
		return card

	var empty_card: ItemCard = item_card_scene.instantiate() as ItemCard
	empty_card.ready.connect(func() -> void:
		empty_card.add_theme_stylebox_override("panel", _empty_slot_style)
		empty_card.level_label.text = slot_name
		empty_card.level_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	)
	return empty_card


func _create_bait_slot(item_card_scene: PackedScene, slot_name: String) -> PanelContainer:
	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()

	var equipped_key: String = state.equipped_bait_id if state else ""
	var has_bait: bool = equipped_key.begins_with("bait_q")

	if has_bait:
		var quality: int = equipped_key.substr(6).to_int()
		var count: int = state.bait_inventory.get(quality, 0) if state else 0
		var card: ItemCard = item_card_scene.instantiate() as ItemCard
		var quality_color: Color = Enums.QUALITY_COLORS.get(quality, Color.WHITE)
		var tex: Texture2D = _bait_textures.get(quality, _bait_textures[1])
		var q: int = quality
		card.ready.connect(func() -> void:
			card.set_item_data("bait", "", tex, 0, quality_color)
			card.level_label.text = "x%d" % count
			card.selected.connect(_on_bait_pressed.bind(q))
		)
		return card

	var empty_card: ItemCard = item_card_scene.instantiate() as ItemCard
	empty_card.ready.connect(func() -> void:
		empty_card.add_theme_stylebox_override("panel", _empty_slot_style)
		empty_card.level_label.text = slot_name
		empty_card.level_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	)
	return empty_card



func _refresh_all() -> void:
	_refresh_grid()
	_update_filter_buttons()


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
	var filter_type: String = FILTER_TYPES[active_filter]

	if filter_type == "bait":
		_populate_bait_grid()
		return

	var items: Array[EquipmentManager.EquipmentEntry] = []
	items.assign(EquipmentManager.inventory)

	if filter_type != "":
		var filtered: Array[EquipmentManager.EquipmentEntry] = []
		filtered.assign(items.filter(func(e: EquipmentManager.EquipmentEntry) -> bool: return e.equipment_type == filter_type))
		items = filtered
	else:
		var filtered: Array[EquipmentManager.EquipmentEntry] = []
		filtered.assign(items.filter(func(e: EquipmentManager.EquipmentEntry) -> bool: return e.equipment_type != "bait"))
		items = filtered

	var unequipped: Array[EquipmentManager.EquipmentEntry] = []
	unequipped.assign(items.filter(func(e: EquipmentManager.EquipmentEntry) -> bool: return not _is_item_equipped(e.uuid)))
	unequipped.sort_custom(_sort_equipment)

	var grid_data: Array = []
	grid_data.append_array(unequipped)

	if filter_type == "":
		var state: PlayerState = null
		if Main.instance and Main.instance.player_state_system:
			state = Main.instance.player_state_system.get_state()
		if state:
			for quality: int in [1, 2, 3, 4]:
				var count: int = state.bait_inventory.get(quality, 0)
				if count > 0:
					grid_data.append(BaitStack.new(quality, count))

	item_grid.set_data(grid_data)


func _populate_bait_grid() -> void:
	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()
	if not state:
		item_grid.set_data([])
		return

	var stacks: Array = []
	for quality: int in [1, 2, 3, 4]:
		var count: int = state.bait_inventory.get(quality, 0)
		if count > 0:
			stacks.append(BaitStack.new(quality, count))
	item_grid.set_data(stacks)


func _configure_card(card: ItemCard, _index: int, data: Variant) -> void:
	if data is BaitStack:
		var bait: BaitStack = data as BaitStack
		var quality_color: Color = Enums.QUALITY_COLORS.get(bait.quality, Color.WHITE)
		var tex: Texture2D = _bait_textures.get(bait.quality, _bait_textures[1])
		card.set_item_data("bait", "", tex, 0, quality_color)
		card.level_label.text = "x%d" % bait.count
		card.selected.connect(_on_bait_pressed.bind(bait.quality))
		return

	var entry: EquipmentManager.EquipmentEntry = data as EquipmentManager.EquipmentEntry
	if not entry:
		return
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var icon_texture: Texture2D = _get_item_icon(entry.item_id, entry.equipment_type)
	card.set_item_data(entry.item_id, entry.uuid, icon_texture, entry.level, quality_color)
	card.selected.connect(_on_item_pressed.bind(entry.uuid))



func _sort_equipment(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool:
	var a_equipped: bool = _is_item_equipped(a.uuid)
	var b_equipped: bool = _is_item_equipped(b.uuid)
	if a_equipped != b_equipped:
		return a_equipped
	if a.quality != b.quality:
		return a.quality > b.quality
	return a.level > b.level




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



func _on_item_pressed(uuid: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"uuid": uuid})


func _on_bait_pressed(quality: int) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"bait_quality": quality})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
