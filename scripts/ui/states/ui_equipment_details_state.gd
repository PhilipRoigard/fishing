extends UIStateNode

var _folley_texture: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
var _bait_worm: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_blue: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_pink: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")
var _bait_green: Texture2D = preload("res://assets/sprites/items/Bait_01_green.png")

@onready var background: ColorRect = %Background
@onready var equipment_name_label: Label = %EquipmentName
@onready var level_label: Label = %LevelLabel
@onready var stats_label: Label = %StatsLabel
@onready var quality_label: Label = %QualityLabel
@onready var item_card: ItemCard = %ItemCard
@onready var equip_button: Button = %EquipButton
@onready var level_up_button: Button = %LevelUpButton
@onready var buttons: Control = %Buttons

var selected_uuid: String = ""
var _bait_quality: int = -1

var _bait_textures: Dictionary = {
	1: preload("res://assets/sprites/items/Bait_01.png"),
	2: preload("res://assets/sprites/items/Bait_01_blue.png"),
	3: preload("res://assets/sprites/items/Bait_01_pink.png"),
	4: preload("res://assets/sprites/items/Bait_01_green.png"),
}
const _QUALITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]


func _ready() -> void:
	if background and not background.gui_input.is_connected(_on_background_input):
		background.gui_input.connect(_on_background_input)


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_back()


func enter(meta: Variant = null) -> void:
	super(meta)
	_bait_quality = -1
	selected_uuid = ""
	if meta is Dictionary:
		selected_uuid = meta.get("uuid", "")
		_bait_quality = meta.get("bait_quality", -1)
	if _bait_quality >= 0:
		_populate_bait_data()
	else:
		_populate_data()


func _populate_data() -> void:
	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return

	var display_name: String = _get_display_name(entry)
	var quality_name: String = Enums.QUALITY_NAMES.get(entry.quality, "Common")
	var quality_color: Color = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)

	equipment_name_label.text = display_name
	var icon_texture: Texture2D = _get_item_icon(entry.item_id, entry.equipment_type)
	item_card.set_item_data(entry.item_id, entry.uuid, icon_texture, entry.level, quality_color)
	item_card.level_label.visible = false
	quality_label.text = quality_name

	var stat_cfg: EquipmentStatConfig = null
	if GameResources.config:
		stat_cfg = GameResources.config.equipment_stat_config

	var cap: int = 15
	if stat_cfg:
		cap = stat_cfg.get_level_cap(entry.quality)
	level_label.text = "Lv. %d/%d" % [entry.level, cap]

	var is_equipped: bool = _is_item_equipped(entry.uuid)
	if is_equipped:
		equip_button.text = "Equipped"
		equip_button.disabled = true
	else:
		equip_button.text = "Equip"
		equip_button.disabled = false

	if stat_cfg:
		var cost: int = stat_cfg.get_level_up_cost(entry.level)
		if entry.level >= cap:
			level_up_button.text = "Max Level"
			level_up_button.disabled = true
		else:
			level_up_button.text = "Level Up  " + str(cost)
			level_up_button.disabled = not CurrencyManager.can_afford_coins(cost)

	var stats_text: String = ""
	if stat_cfg:
		var depth: int = stat_cfg.get_cast_depth_at_level(entry.level, entry.quality)
		stats_text = "Cast Depth: %dm" % depth

	var cat: Variant = null
	if GameResources.config:
		cat = GameResources.config.equipment_catalogue
	if cat:
		var rod: Variant = cat.get_rod_by_id(entry.item_id)
		var hook: Variant = cat.get_hook_by_id(entry.item_id)
		var lure: Variant = cat.get_lure_by_id(entry.item_id)
		if rod and rod.perk_id != "none" and rod.perk_values.size() > 0:
			var perk_idx: int = mini(entry.quality, rod.perk_values.size() - 1)
			var perk_val: float = rod.perk_values[perk_idx]
			stats_text += "\n" + rod.perk_name + ": " + rod.perk_description % int(perk_val)
		elif hook:
			stats_text += "\nBite: +%ss\nCatch: +%d%%" % [str(snapped(hook.bite_window_bonus, 0.1)), int(hook.catch_rate_bonus * 100)]
		elif lure:
			stats_text += "\nRare: +%d%%" % int(lure.rare_fish_chance_bonus * 100)

	stats_label.text = stats_text


func _populate_bait_data() -> void:
	var quality_color: Color = Enums.QUALITY_COLORS.get(_bait_quality, Color.WHITE)
	var quality_name: String = _QUALITY_NAMES[_bait_quality] if _bait_quality < _QUALITY_NAMES.size() else "Unknown"

	equipment_name_label.text = quality_name + " Bait"
	var bait_tex: Texture2D = _bait_textures.get(_bait_quality, _bait_textures[1])
	item_card.set_item_data("bait", "", bait_tex, 0, quality_color)
	item_card.level_label.visible = false
	level_label.text = ""

	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()

	var count: int = state.bait_inventory.get(_bait_quality, 0) if state else 0
	stats_label.text = "Quantity: x%d" % count
	quality_label.text = "Catch %s quality fish" % quality_name

	var bait_key: String = "bait_q" + str(_bait_quality)
	var is_equipped: bool = state != null and state.equipped_bait_id == bait_key
	equip_button.text = "Unequip" if is_equipped else "Equip"
	level_up_button.visible = false


func _on_equip_pressed() -> void:
	if _bait_quality >= 0:
		_equip_bait()
		return

	var entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_item(selected_uuid)
	if not entry:
		return
	var slot: int = _get_slot_for_type(entry.equipment_type)
	if slot < 0:
		return
	if _is_item_equipped(entry.uuid):
		return
	EquipmentManager.equip(slot, entry.uuid)
	_back()


func _equip_bait() -> void:
	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()
	if not state:
		return

	var bait_key: String = "bait_q" + str(_bait_quality)
	if state.equipped_bait_id == bait_key:
		state.equipped_bait_id = ""
	else:
		state.equipped_bait_id = bait_key
	_back()


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
