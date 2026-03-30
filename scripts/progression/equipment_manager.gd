extends Node

const SAVE_PATH: String = "user://equipment_inventory.cfg"
const _FightModifiersScript: GDScript = preload("res://scripts/fishing/fight/fight_modifiers.gd")
const _EnumsScript: GDScript = preload("res://scripts/config/enums.gd")

var inventory: Array = []
var loadout: Dictionary = {}


class EquipmentEntry:
	var uuid: String = ""
	var item_id: String = ""
	var equipment_type: String = ""
	var quality: int = 0
	var level: int = 1


func _ready() -> void:
	_load_data()
	_grant_starter_items()


func _load_data() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	var item_count: int = config.get_value("inventory", "count", 0)
	for i: int in item_count:
		var section: String = "item_" + str(i)
		var entry: EquipmentEntry = EquipmentEntry.new()
		entry.uuid = config.get_value(section, "uuid", "")
		entry.item_id = config.get_value(section, "item_id", "")
		entry.equipment_type = config.get_value(section, "equipment_type", "")
		entry.quality = config.get_value(section, "quality", 0)
		entry.level = config.get_value(section, "level", 1)
		if entry.uuid != "":
			inventory.append(entry)

	for slot_key: String in ["rod", "hook", "lure", "bait"]:
		var uuid: String = config.get_value("loadout", slot_key, "")
		if uuid != "":
			var slot_index: int = _slot_key_to_index(slot_key)
			loadout[slot_index] = uuid


func _save_data() -> void:
	var config: ConfigFile = ConfigFile.new()

	config.set_value("inventory", "count", inventory.size())
	for i: int in inventory.size():
		var entry: EquipmentEntry = inventory[i] as EquipmentEntry
		var section: String = "item_" + str(i)
		config.set_value(section, "uuid", entry.uuid)
		config.set_value(section, "item_id", entry.item_id)
		config.set_value(section, "equipment_type", entry.equipment_type)
		config.set_value(section, "quality", entry.quality)
		config.set_value(section, "level", entry.level)

	for slot_index: int in [0, 1, 2, 3]:
		var slot_key: String = _slot_index_to_key(slot_index)
		var uuid: String = loadout.get(slot_index, "")
		config.set_value("loadout", slot_key, uuid)

	config.save(SAVE_PATH)


func _slot_key_to_index(key: String) -> int:
	match key:
		"rod": return 0
		"hook": return 1
		"lure": return 2
		"bait": return 3
	return -1


func _slot_index_to_key(index: int) -> String:
	match index:
		0: return "rod"
		1: return "hook"
		2: return "lure"
		3: return "bait"
	return ""


func _grant_starter_items() -> void:
	if not inventory.is_empty():
		return

	var rod_uuid: String = add_item("starter_rod", "rod", 0)
	var hook_uuid: String = add_item("basic_hook", "hook", 0)
	var lure_uuid: String = add_item("basic_lure", "lure", 0)

	equip(_EnumsScript.EquipmentSlot.ROD, rod_uuid)
	equip(_EnumsScript.EquipmentSlot.HOOK, hook_uuid)
	equip(_EnumsScript.EquipmentSlot.LURE, lure_uuid)

	add_item("worm", "bait", 0)
	add_item("worm", "bait", 0)
	add_item("worm", "bait", 0)
	add_item("worm", "bait", 0)
	add_item("worm", "bait", 0)


func add_item(item_id: String, equipment_type: String, quality: int = 0) -> String:
	var entry: EquipmentEntry = EquipmentEntry.new()
	entry.uuid = _generate_uuid()
	entry.item_id = item_id
	entry.equipment_type = equipment_type
	entry.quality = quality
	entry.level = 1
	inventory.append(entry)
	SignalBus.equipment_item_acquired.emit(entry.uuid, item_id, quality)
	_save_data()
	return entry.uuid


func remove_item(uuid: String) -> void:
	inventory.assign(inventory.filter(func(e: EquipmentEntry) -> bool: return e.uuid != uuid))
	_save_data()


func get_item(uuid: String) -> EquipmentEntry:
	for entry: EquipmentEntry in inventory:
		if entry.uuid == uuid:
			return entry
	return null


func equip(slot: int, uuid: String) -> void:
	loadout[int(slot)] = uuid
	_save_data()
	SignalBus.equipment_changed.emit(slot)


func unequip(slot: int) -> void:
	loadout.erase(int(slot))
	_save_data()
	SignalBus.equipment_changed.emit(slot)


func get_equipped(slot: int) -> EquipmentEntry:
	var uuid: String = loadout.get(int(slot), "")
	if uuid == "":
		return null
	return get_item(uuid)


func level_up(uuid: String) -> bool:
	var entry: EquipmentEntry = get_item(uuid)
	if not entry:
		return false

	var quality_cfg: Variant = null
	if GameResources.config:
		quality_cfg = GameResources.config.quality_config
	if not quality_cfg:
		return false

	var cap: int = quality_cfg.get_level_cap(entry.quality)
	if entry.level >= cap:
		return false

	var cost: int = quality_cfg.get_level_up_cost(entry.quality, entry.level)
	if not CurrencyManager.can_afford_coins(cost):
		return false

	CurrencyManager.spend_coins(cost)
	entry.level += 1
	_save_data()
	SignalBus.equipment_leveled_up.emit(uuid, entry.level)
	return true


func merge(uuids: Array[String]) -> String:
	if uuids.is_empty():
		return ""

	var first: EquipmentEntry = get_item(uuids[0])
	if not first:
		return ""

	var merge_cfg: Variant = null
	if GameResources.config:
		merge_cfg = GameResources.config.equipment_merge_config
	if not merge_cfg:
		return ""

	var req: Variant = merge_cfg.get_requirement_for_quality(first.quality)
	if not req:
		return ""

	if uuids.size() < req.copies_required:
		return ""

	if not CurrencyManager.can_afford_coins(req.coin_cost):
		return ""

	CurrencyManager.spend_coins(req.coin_cost)

	var best_level: int = 0
	for uuid: String in uuids:
		var entry: EquipmentEntry = get_item(uuid)
		if entry and entry.level > best_level:
			best_level = entry.level

	for uuid: String in uuids:
		remove_item(uuid)

	var new_uuid: String = add_item(first.item_id, first.equipment_type, req.to_quality)
	var new_entry: EquipmentEntry = get_item(new_uuid)
	if new_entry:
		new_entry.level = best_level

	_save_data()
	SignalBus.equipment_merged.emit(new_uuid, first.item_id, first.quality, req.to_quality)
	return new_uuid


func compute_fight_modifiers() -> RefCounted:
	var mods: RefCounted = _FightModifiersScript.new()
	var quality_multipliers: Dictionary = _EnumsScript.QUALITY_MULTIPLIERS
	var rod_slot: int = _EnumsScript.EquipmentSlot.ROD
	var hook_slot: int = _EnumsScript.EquipmentSlot.HOOK

	var rod: EquipmentEntry = get_equipped(rod_slot)
	if rod:
		var quality_mult: float = quality_multipliers.get(rod.quality, 1.0)
		mods.reel_speed = 1.0 + (rod.level * 0.02) * quality_mult
		mods.tension_resistance = 1.0 + (rod.level * 0.015) * quality_mult

	var hook: EquipmentEntry = get_equipped(hook_slot)
	if hook:
		var quality_mult: float = quality_multipliers.get(hook.quality, 1.0)
		mods.catch_bonus = (hook.level * 0.01) * quality_mult

	return mods


func _generate_uuid() -> String:
	return str(randi()) + "_" + str(Time.get_ticks_msec())
