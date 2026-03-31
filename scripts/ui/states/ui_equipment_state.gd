extends UIStateNode

const SLOT_TYPES: Array[Enums.EquipmentSlot] = [
	Enums.EquipmentSlot.ROD,
	Enums.EquipmentSlot.HOOK,
	Enums.EquipmentSlot.LURE,
	Enums.EquipmentSlot.BAIT,
]
const SLOT_NAMES: Array[String] = ["Rod", "Hook", "Lure", "Bait"]
const FILTER_TYPES: Array[String] = ["", "rod", "hook", "lure", "bait"]

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
var _folley_sheet_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
var _bait_worm_texture: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_blue_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_pink_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")

@onready var items_grid: VirtualizedItemGrid = %ItemsGrid
@onready var items_scroll_container: ScrollContainer = %ItemsScrollContainer
@onready var cast_depth_label: Label = %CastDepthLabel
@onready var rod_slot: EquipmentSlotComponent = %RodSlot
@onready var hook_slot: EquipmentSlotComponent = %HookSlot
@onready var lure_slot: EquipmentSlotComponent = %LureSlot
@onready var bait_slot: EquipmentSlotComponent = %BaitSlot
@onready var filter_bar: HBoxContainer = %FilterBar
@onready var empty_label: Label = %EmptyLabel
@onready var bottom_spacer: Control = %BottomSpacer
@onready var merge_button: Button = %MergeButton

var _slot_components: Array[EquipmentSlotComponent] = []
var active_filter: int = 0


func _ready() -> void:
	_slot_components = [rod_slot, hook_slot, lure_slot, bait_slot]
	for i: int in _slot_components.size():
		_slot_components[i].setup_slot(SLOT_TYPES[i], SLOT_NAMES[i])
		_slot_components[i].selected.connect(_on_slot_pressed.bind(i))

	items_grid.setup(items_scroll_container, _configure_card)
	if not items_scroll_container.resized.is_connected(_update_grid_columns):
		items_scroll_container.resized.connect(_update_grid_columns)


func enter(_meta: Variant = null) -> void:
	super(_meta)
	items_scroll_container.scroll_vertical = 0
	_populate_equipment_slots()
	_update_stats()
	_update_grid_columns()
	_refresh_grid()
	_update_filter_buttons()


func focus() -> void:
	super()
	_populate_equipment_slots()
	_update_stats()
	_refresh_grid()


func _update_grid_columns() -> void:
	items_grid.update_columns(items_scroll_container.size.x - 24.0)


func _populate_equipment_slots() -> void:
	for i: int in _slot_components.size():
		var slot_type: Enums.EquipmentSlot = SLOT_TYPES[i]
		var component: EquipmentSlotComponent = _slot_components[i]

		if slot_type == Enums.EquipmentSlot.BAIT:
			var state: PlayerState = null
			if Main.instance and Main.instance.player_state_system:
				state = Main.instance.player_state_system.get_state()
			if state and state.equipped_bait_id.begins_with("bait_q"):
				var bait_q: int = state.equipped_bait_id.substr(6).to_int()
				var count: int = state.bait_inventory.get(bait_q, 0)
				var tex: Texture2D = _bait_textures.get(bait_q, _bait_worm_texture)
				component.set_bait_stack(tex, bait_q, count)
			else:
				component.unequip_item()
			continue

		var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot_type)
		if equipped:
			var icon: Texture2D = _get_item_icon(equipped.item_id, equipped.equipment_type)
			component.set_equipped_item(equipped.item_id, equipped.uuid, icon, equipped.level, equipped.quality)
		else:
			component.unequip_item()


func _update_stats() -> void:
	if not cast_depth_label:
		return
	var stat_cfg: EquipmentStatConfig = null
	if GameResources.config:
		stat_cfg = GameResources.config.equipment_stat_config
	if not stat_cfg:
		return
	var rod: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.ROD)
	var total_depth: int = 0
	if rod:
		total_depth = stat_cfg.get_cast_depth_at_level(rod.level, rod.quality)
	cast_depth_label.text = "%dm" % total_depth


func _update_filter_buttons() -> void:
	if not filter_bar:
		return
	for i: int in filter_bar.get_child_count():
		var btn: Button = filter_bar.get_child(i) as Button
		if not btn:
			continue
		if i == active_filter:
			btn.add_theme_stylebox_override("normal", preload("res://resources/ui/Style Boxes/StyleBoxTexture/panels/panel_container_header.tres"))
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
			var equipped_bait_quality: int = -1
			if state.equipped_bait_id.begins_with("bait_q"):
				equipped_bait_quality = state.equipped_bait_id.substr(6).to_int()
			for quality: int in [1, 2, 3, 4]:
				if quality == equipped_bait_quality:
					continue
				var count: int = state.bait_inventory.get(quality, 0)
				if count > 0:
					grid_data.append(BaitStack.new(quality, count))

	items_grid.set_data(grid_data)
	if empty_label:
		empty_label.visible = grid_data.is_empty()


func _populate_bait_grid() -> void:
	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()
	if not state:
		items_grid.set_data([])
		return

	var equipped_bait_quality: int = -1
	if state.equipped_bait_id.begins_with("bait_q"):
		equipped_bait_quality = state.equipped_bait_id.substr(6).to_int()

	var stacks: Array = []
	for quality: int in [1, 2, 3, 4]:
		if quality == equipped_bait_quality:
			continue
		var count: int = state.bait_inventory.get(quality, 0)
		if count > 0:
			stacks.append(BaitStack.new(quality, count))
	items_grid.set_data(stacks)
	if empty_label:
		empty_label.visible = stacks.is_empty()


func _configure_card(card: ItemCard, _index: int, data: Variant) -> void:
	if data is BaitStack:
		var bait: BaitStack = data as BaitStack
		var quality_color: Color = Enums.QUALITY_COLORS.get(bait.quality, Color.WHITE)
		var tex: Texture2D = _bait_textures.get(bait.quality, _bait_worm_texture)
		card.set_item_data("bait", "", tex, 0, quality_color)
		card.level_label.text = "x%d" % bait.count
		card.selected.connect(_on_bait_pressed.bind(bait.quality))
		return

	var entry: EquipmentManager.EquipmentEntry = data as EquipmentManager.EquipmentEntry
	if not entry:
		return
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)
	var icon_texture: Texture2D = _get_item_icon(entry.item_id, entry.equipment_type)
	card.set_item_data(entry.item_id, entry.uuid, icon_texture, entry.level, quality_color, entry.quality)
	card.selected.connect(_on_item_pressed.bind(entry.uuid))


func _sort_equipment(a: EquipmentManager.EquipmentEntry, b: EquipmentManager.EquipmentEntry) -> bool:
	if a.quality != b.quality:
		return a.quality > b.quality
	return a.level > b.level


func _is_item_equipped(uuid: String) -> bool:
	for slot: Enums.EquipmentSlot in SLOT_TYPES:
		if slot == Enums.EquipmentSlot.BAIT:
			continue
		var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot)
		if equipped and equipped.uuid == uuid:
			return true
	return false


func _on_filter_pressed(index: int) -> void:
	active_filter = index
	HapticManager.light_tap()
	_refresh_grid()
	_update_filter_buttons()


func _on_slot_pressed(slot_index: int) -> void:
	HapticManager.light_tap()
	var slot_type: Enums.EquipmentSlot = SLOT_TYPES[slot_index]

	if slot_type == Enums.EquipmentSlot.BAIT:
		var state: PlayerState = null
		if Main.instance and Main.instance.player_state_system:
			state = Main.instance.player_state_system.get_state()
		if state and state.equipped_bait_id.begins_with("bait_q"):
			var bait_q: int = state.equipped_bait_id.substr(6).to_int()
			state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"bait_quality": bait_q})
		return

	var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot_type)
	if equipped:
		state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"uuid": equipped.uuid})


func _on_item_pressed(uuid: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"uuid": uuid})


func _on_bait_pressed(quality: int) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"bait_quality": quality})


func _on_merge_pressed() -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.MERGE)


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _folley_sheet_texture
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
			atlas.atlas = _folley_sheet_texture
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
			atlas.atlas = _folley_sheet_texture
			match item_id:
				"shiny_lure": atlas.region = Rect2(113, 1, 15, 16)
				"golden_lure": atlas.region = Rect2(128, 1, 15, 16)
				"crankbait_lure": atlas.region = Rect2(97, 3, 13, 13)
				"feather_lure": atlas.region = Rect2(113, 1, 15, 16)
				"squid_lure": atlas.region = Rect2(128, 1, 15, 16)
				"pearl_lure": atlas.region = Rect2(97, 3, 13, 13)
				_: atlas.region = Rect2(97, 3, 13, 13)
			return atlas
		"bait":
			match item_id:
				"worm": return _bait_worm_texture
				"shrimp": return _bait_blue_texture
				"squid_bait": return _bait_pink_texture
				_: return _bait_green_texture
	return _bait_green_texture


func _get_display_name_for_entry(entry: EquipmentManager.EquipmentEntry) -> String:
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: EquipmentCatalogue = GameResources.config.equipment_catalogue
		var data: Variant = null
		match entry.equipment_type:
			"rod": data = cat.get_rod_by_id(entry.item_id)
			"hook": data = cat.get_hook_by_id(entry.item_id)
			"lure": data = cat.get_lure_by_id(entry.item_id)
			"bait": data = cat.get_bait_by_id(entry.item_id)
		if data and data.display_name != "":
			return data.display_name
	return entry.item_id
