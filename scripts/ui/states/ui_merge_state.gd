extends UIStateNode

@onready var items_grid: VirtualizedItemGrid = %ItemsGrid
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var selected_slot: ItemCard = %SelectedSlot
@onready var material_slot_1: ItemCard = %MaterialSlot1
@onready var material_slot_2: ItemCard = %MaterialSlot2
@onready var result_slot: ItemCard = %ResultSlot
@onready var info_label: Label = %InfoLabel
@onready var loadout_button: Button = %LoadoutButton
@onready var merge_all_button: Button = %MergeAllButton

var _folley_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
var _bait_worm: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_blue: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_pink: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")

var _selected_uuids: Array[String] = []
var _merge_item_id: String = ""
var _merge_quality: int = -1


func _ready() -> void:
	items_grid.setup(scroll_container, _configure_card)
	if not scroll_container.resized.is_connected(_update_columns):
		scroll_container.resized.connect(_update_columns)


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_clear_selection()
	_populate_grid()
	_update_columns()


func _update_columns() -> void:
	items_grid.update_columns(scroll_container.size.x - 24.0)


func _clear_selection() -> void:
	_selected_uuids.clear()
	_merge_item_id = ""
	_merge_quality = -1
	info_label.text = "Select equipment\nto merge!"
	selected_slot.modulate = Color(1, 1, 1, 0.3)
	material_slot_1.modulate = Color(1, 1, 1, 0.3)
	material_slot_2.modulate = Color(1, 1, 1, 0.3)
	result_slot.modulate = Color(1, 1, 1, 0.3)


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


func _configure_card(card: ItemCard, _index: int, data: Variant) -> void:
	var entry: EquipmentManager.EquipmentEntry = data as EquipmentManager.EquipmentEntry
	if not entry:
		return
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var icon_texture: Texture2D = _get_item_icon(entry.item_id, entry.equipment_type)
	card.set_item_data(entry.item_id, entry.uuid, icon_texture, entry.level, quality_color)

	var is_dimmed: bool = _merge_item_id != "" and (entry.item_id != _merge_item_id or entry.quality != _merge_quality)
	card.set_dimmed(is_dimmed)
	card.set_selected(entry.uuid in _selected_uuids)
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
		_update_preview()
		_update_card_visuals()
		return

	if _merge_item_id == "":
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

	_update_preview()


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


func _update_preview() -> void:
	if _selected_uuids.is_empty() or _merge_item_id == "":
		return

	var icon: Texture2D = _get_item_icon(_merge_item_id, _get_type_for_id(_merge_item_id))
	var quality_color: Color = Enums.QUALITY_COLORS.get(_merge_quality, Color.WHITE)
	var copies: int = _get_copies_required()

	selected_slot.set_item_data(_merge_item_id, "", icon, 0, quality_color)
	selected_slot.level_label.visible = false
	selected_slot.modulate = Color.WHITE

	var merge_cfg: Variant = null
	if GameResources.config:
		merge_cfg = GameResources.config.equipment_merge_config
	var can_merge: bool = merge_cfg != null and merge_cfg.can_merge(_merge_quality)

	if can_merge:
		var req: Variant = merge_cfg.get_requirement_for_quality(_merge_quality)
		var result_color: Color = Enums.QUALITY_COLORS.get(req.to_quality, Color.WHITE)

		material_slot_1.set_item_data(_merge_item_id, "", icon, 0, quality_color)
		material_slot_1.level_label.visible = false
		material_slot_1.modulate = Color.WHITE if _selected_uuids.size() >= 2 else Color(1, 1, 1, 0.3)

		if copies >= 3:
			material_slot_2.visible = true
			material_slot_2.set_item_data(_merge_item_id, "", icon, 0, quality_color)
			material_slot_2.level_label.visible = false
			material_slot_2.modulate = Color.WHITE if _selected_uuids.size() >= 3 else Color(1, 1, 1, 0.3)
		else:
			material_slot_2.visible = false

		result_slot.set_item_data(_merge_item_id, "", icon, 0, result_color)
		result_slot.level_label.visible = false
		result_slot.modulate = Color.WHITE if _selected_uuids.size() >= copies else Color(1, 1, 1, 0.3)

		var quality_names: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
		info_label.text = "%s\n%s > %s\n%d/%d selected" % [
			_get_display_name(_merge_item_id),
			quality_names[mini(_merge_quality, 4)],
			quality_names[mini(req.to_quality, 4)],
			_selected_uuids.size(),
			copies,
		]

		if _selected_uuids.size() >= copies:
			_execute_merge()
	else:
		info_label.text = "Max quality!\nCannot merge further."


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
			var is_dimmed: bool = _merge_item_id != "" and card.item_id != _merge_item_id
			card.set_dimmed(is_dimmed)
			card.set_selected(card.uuid in _selected_uuids)


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
	return _bait_green
