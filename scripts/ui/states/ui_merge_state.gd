extends UIStateNode

@onready var items_grid: VirtualizedItemGrid = %ItemsGrid
@onready var items_scroll_container: ScrollContainer = %ItemsScrollContainer
@onready var result_slot: PanelContainer = %ResultSlot
@onready var selected_item_slot: PanelContainer = %SelectedItemSlot
@onready var material_slot_1: PanelContainer = %MaterialSlot1
@onready var material_slot_2: PanelContainer = %MaterialSlot2
@onready var result_texture: TextureRect = %ResultTexture
@onready var selected_texture: TextureRect = %SelectedTexture
@onready var material_1_texture: TextureRect = %Material1Texture
@onready var material_2_texture: TextureRect = %Material2Texture
@onready var stats_label: RichTextLabel = %StatsLabel
@onready var plus_sign: Label = %PlusSign
@onready var loadout_button: Button = %LoadoutButton
@onready var merge_all_button: Button = %MergeAllButton
@onready var empty_label: Label = %EmptyLabel

var _folley_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
var _bait_green: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")

var _selected_uuids: Array[String] = []
var _merge_item_id: String = ""
var _merge_quality: int = -1
var _grid_darkenator: ColorRect


func _ready() -> void:
	items_grid.setup(items_scroll_container, _configure_card)
	if not items_scroll_container.resized.is_connected(_update_columns):
		items_scroll_container.resized.connect(_update_columns)


func enter(_meta: Variant = null) -> void:
	super(_meta)
	items_scroll_container.scroll_vertical = 0
	_clear_selection()
	_update_columns()
	_populate_grid()
	_ensure_grid_darkenator()


func _update_columns() -> void:
	items_grid.update_columns(items_scroll_container.size.x - 24.0)


func _clear_selection() -> void:
	_selected_uuids.clear()
	_merge_item_id = ""
	_merge_quality = -1

	result_texture.texture = null
	selected_texture.texture = null
	material_1_texture.texture = null
	material_2_texture.texture = null

	result_slot.self_modulate = Color.WHITE
	selected_item_slot.self_modulate = Color.WHITE
	material_slot_1.self_modulate = Color.WHITE
	material_slot_2.self_modulate = Color.WHITE
	material_slot_1.modulate = Color.WHITE
	material_slot_2.modulate = Color.WHITE

	stats_label.text = "Select items\nto merge!"
	stats_label.scroll_active = false
	_update_grid_darkenator()


func _populate_grid() -> void:
	var items: Array = []
	for entry: EquipmentManager.EquipmentEntry in EquipmentManager.inventory:
		if entry.equipment_type == "bait":
			continue
		items.append(entry)
	items.sort_custom(func(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool:
		if a.quality != b.quality: return a.quality > b.quality
		if a.item_id != b.item_id: return a.item_id < b.item_id
		return a.level > b.level
	)
	items_grid.set_data(items)
	if empty_label:
		empty_label.visible = items.is_empty()
	_update_grid_darkenator()


func _configure_card(card: ItemCard, _index: int, data: Variant) -> void:
	var entry: EquipmentManager.EquipmentEntry = data as EquipmentManager.EquipmentEntry
	if not entry:
		return
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var icon_texture: Texture2D = _get_item_icon(entry.item_id, entry.equipment_type)
	card.set_item_data(entry.item_id, entry.uuid, icon_texture, entry.level, quality_color, entry.quality)

	var is_selected: bool = entry.uuid in _selected_uuids
	card.set_dimmed(false)
	card.set_selected(is_selected)
	card.z_as_relative = false
	card.z_index = 1 if is_selected else 0
	card.selected.connect(_on_card_selected.bind(entry.uuid))


func _on_card_selected(uuid: String) -> void:
	HapticManager.light_tap()
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(uuid)
	if not entry:
		return

	if uuid in _selected_uuids:
		_selected_uuids.erase(uuid)
		if _selected_uuids.is_empty():
			_clear_selection()
			_populate_grid()
			return
		_update_card_visuals()
		_update_merge_preview()
		return

	if _merge_item_id == "" or entry.item_id != _merge_item_id or entry.quality != _merge_quality:
		_clear_selection()
		_merge_item_id = entry.item_id
		_merge_quality = entry.quality
		_auto_select(uuid)
		_populate_grid()
	elif entry.item_id == _merge_item_id and entry.quality == _merge_quality:
		var copies: int = _get_copies_required()
		if _selected_uuids.size() < copies:
			_selected_uuids.append(uuid)
		else:
			_selected_uuids[_selected_uuids.size() - 1] = uuid
		_update_card_visuals()

	_update_merge_preview()


func _auto_select(primary_uuid: String) -> void:
	_selected_uuids.clear()
	_selected_uuids.append(primary_uuid)

	var copies: int = _get_copies_required()
	var candidates: Array[EquipmentManager.EquipmentEntry] = []
	for entry: EquipmentManager.EquipmentEntry in EquipmentManager.inventory:
		if entry.item_id == _merge_item_id and entry.quality == _merge_quality and entry.uuid != primary_uuid:
			candidates.append(entry)
	candidates.sort_custom(func(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool: return a.level < b.level)

	for entry: EquipmentManager.EquipmentEntry in candidates:
		if _selected_uuids.size() >= copies:
			break
		_selected_uuids.append(entry.uuid)


func _get_copies_required() -> int:
	var merge_cfg: Variant = null
	if GameResources.config:
		merge_cfg = GameResources.config.equipment_merge_config
	if not merge_cfg:
		return 3
	var req: Variant = merge_cfg.get_requirement_for_quality(_merge_quality)
	if not req:
		return 3
	return req.copies_required


func _update_merge_preview() -> void:
	if _selected_uuids.is_empty() or _merge_item_id == "":
		return

	var icon: Texture2D = _get_item_icon(_merge_item_id, _get_type_for_id(_merge_item_id))
	var quality_color: Color = Enums.QUALITY_COLORS.get(_merge_quality, Color.WHITE)
	var copies: int = _get_copies_required()

	selected_texture.texture = icon
	selected_item_slot.self_modulate = quality_color

	var merge_cfg: Variant = null
	if GameResources.config:
		merge_cfg = GameResources.config.equipment_merge_config
	var can_merge: bool = merge_cfg != null and merge_cfg.can_merge(_merge_quality)

	if can_merge:
		var req: Variant = merge_cfg.get_requirement_for_quality(_merge_quality)
		var result_color: Color = Enums.QUALITY_COLORS.get(req.to_quality, Color.WHITE)

		result_texture.texture = icon
		result_slot.self_modulate = result_color

		var materials_needed: int = copies - 1
		if materials_needed >= 1:
			material_slot_1.visible = true
			material_1_texture.texture = icon
			material_slot_1.self_modulate = quality_color
			material_slot_1.modulate = Color.WHITE if _selected_uuids.size() >= 2 else Color(1, 1, 1, 0.3)
		else:
			material_slot_1.visible = false

		if materials_needed >= 2:
			material_slot_2.visible = true
			material_2_texture.texture = icon
			material_slot_2.self_modulate = quality_color
			material_slot_2.modulate = Color.WHITE if _selected_uuids.size() >= 3 else Color(1, 1, 1, 0.3)
		else:
			material_slot_2.visible = false

		var quality_names: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
		var display_name: String = _get_display_name(_merge_item_id)
		stats_label.text = "[b]%s[/b]\n%s > [color=green]%s[/color]\n%d/%d selected" % [
			display_name,
			quality_names[mini(_merge_quality, 4)],
			quality_names[mini(req.to_quality, 4)],
			_selected_uuids.size(),
			copies,
		]

		if _selected_uuids.size() >= copies:
			_execute_merge()
	else:
		result_texture.texture = icon
		result_slot.self_modulate = quality_color
		material_slot_1.visible = false
		material_slot_2.visible = false
		stats_label.text = "[b]%s[/b]\nMax Quality!" % _get_display_name(_merge_item_id)


func _execute_merge() -> void:
	var uuids: Array[String] = []
	uuids.assign(_selected_uuids)
	var result: String = EquipmentManager.merge(uuids)
	if result != "":
		var merge_cfg: Variant = GameResources.config.equipment_merge_config
		var req: Variant = merge_cfg.get_requirement_for_quality(_merge_quality)
		var quality_names: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
		SignalBus.show_notification.emit("Merged into %s!" % quality_names[mini(req.to_quality, 4)], Enums.QUALITY_COLORS.get(req.to_quality, Color.WHITE))
		_clear_selection()
		_populate_grid()


func _update_card_visuals() -> void:
	for card: ItemCard in items_grid.get_all_active_cards():
		if is_instance_valid(card):
			var is_selected: bool = card.uuid in _selected_uuids
			card.set_dimmed(false)
			card.set_selected(is_selected)
			card.z_as_relative = false
			card.z_index = 1 if is_selected else 0
	_update_grid_darkenator()


func _on_loadout_pressed() -> void:
	HapticManager.light_tap()
	_back()


func _on_merge_all_pressed() -> void:
	HapticManager.light_tap()
	var merge_cfg: Variant = null
	if GameResources.config:
		merge_cfg = GameResources.config.equipment_merge_config
	if not merge_cfg:
		return

	var total_merges: int = 0
	var keep_going: bool = true
	while keep_going:
		keep_going = false
		var groups: Dictionary = {}
		for entry: EquipmentManager.EquipmentEntry in EquipmentManager.inventory:
			if entry.equipment_type == "bait":
				continue
			var key: String = entry.item_id + "_" + str(entry.quality)
			if not groups.has(key):
				groups[key] = []
			groups[key].append(entry)

		for key: String in groups:
			var group: Array = groups[key]
			if group.is_empty():
				continue
			var first: EquipmentManager.EquipmentEntry = group[0]
			var req: Variant = merge_cfg.get_requirement_for_quality(first.quality)
			if not req or group.size() < req.copies_required:
				continue
			group.sort_custom(func(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool: return a.level < b.level)
			var uuids: Array[String] = []
			for i: int in req.copies_required:
				uuids.append(group[i].uuid)
			if EquipmentManager.merge(uuids) != "":
				total_merges += 1
				keep_going = true
				break

	if total_merges > 0:
		SignalBus.show_notification.emit("Merged %d items!" % total_merges, Color(0.3, 1.0, 0.3))
	else:
		SignalBus.show_notification.emit("Nothing to merge", Color(0.7, 0.7, 0.7))

	_clear_selection()
	_populate_grid()


func _get_display_name(item_id: String) -> String:
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: EquipmentCatalogue = GameResources.config.equipment_catalogue
		var rod: Variant = cat.get_rod_by_id(item_id)
		if rod: return rod.display_name
		var hook: Variant = cat.get_hook_by_id(item_id)
		if hook: return hook.display_name
		var lure: Variant = cat.get_lure_by_id(item_id)
		if lure: return lure.display_name
	return item_id


func _get_type_for_id(item_id: String) -> String:
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: EquipmentCatalogue = GameResources.config.equipment_catalogue
		if cat.get_rod_by_id(item_id): return "rod"
		if cat.get_hook_by_id(item_id): return "hook"
		if cat.get_lure_by_id(item_id): return "lure"
	return "rod"


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"bronze_rod": atlas.region = Rect2(65, 2, 15, 15)
				"silver_rod": atlas.region = Rect2(81, 2, 15, 15)
				"gold_rod": atlas.region = Rect2(81, 2, 15, 15)
				"carbon_rod": atlas.region = Rect2(81, 2, 15, 15)
				"whalebone_rod": atlas.region = Rect2(65, 2, 15, 15)
				"tidecaller_rod": atlas.region = Rect2(49, 2, 15, 14)
				_: atlas.region = Rect2(49, 2, 15, 14)
			return atlas
		"hook":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"barbed_hook": atlas.region = Rect2(17, 1, 14, 16)
				"titanium_hook": atlas.region = Rect2(33, 1, 14, 16)
				"circle_hook": atlas.region = Rect2(1, 0, 14, 17)
				"double_hook": atlas.region = Rect2(17, 1, 14, 16)
				"gold_hook": atlas.region = Rect2(33, 1, 14, 16)
				_: atlas.region = Rect2(1, 0, 14, 17)
			return atlas
		"lure":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_texture
			match item_id:
				"shiny_lure": atlas.region = Rect2(113, 1, 15, 16)
				"golden_lure": atlas.region = Rect2(128, 1, 15, 16)
				"crankbait_lure": atlas.region = Rect2(97, 3, 13, 13)
				"feather_lure": atlas.region = Rect2(113, 1, 15, 16)
				"squid_lure": atlas.region = Rect2(128, 1, 15, 16)
				"pearl_lure": atlas.region = Rect2(97, 3, 13, 13)
				_: atlas.region = Rect2(97, 3, 13, 13)
			return atlas
	return _bait_green


func _ensure_grid_darkenator() -> void:
	if _grid_darkenator and is_instance_valid(_grid_darkenator):
		return
	_grid_darkenator = ColorRect.new()
	_grid_darkenator.name = "GridDarkenator"
	_grid_darkenator.color = Color(0.0, 0.0, 0.0, 0.5)
	_grid_darkenator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grid_darkenator.set_anchors_preset(Control.PRESET_FULL_RECT)
	_grid_darkenator.visible = false
	add_child(_grid_darkenator)


func _update_grid_darkenator() -> void:
	if not _grid_darkenator or not is_instance_valid(_grid_darkenator):
		return
	var active: bool = _merge_item_id != ""
	_grid_darkenator.visible = active

	var preview: Control = result_slot.get_parent()
	var header: Control = loadout_button.get_parent().get_parent().get_parent()
	preview.z_as_relative = false
	preview.z_index = 1 if active else 0
	header.z_as_relative = false
	header.z_index = 1 if active else 0
