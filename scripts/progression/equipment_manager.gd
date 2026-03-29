extends Node

const SAVE_PATH: String = "user://equipment_inventory.tres"
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
	_load_inventory()
	_grant_starter_items()


func _load_inventory() -> void:
	pass


func _grant_starter_items() -> void:
	if not inventory.is_empty():
		return

	var rod_uuid: String = add_item("starter_rod", "rod", 0)
	var hook_uuid: String = add_item("basic_hook", "hook", 0)
	var lure_uuid: String = add_item("basic_lure", "lure", 0)

	equip(_EnumsScript.EquipmentSlot.ROD, rod_uuid)
	equip(_EnumsScript.EquipmentSlot.HOOK, hook_uuid)
	equip(_EnumsScript.EquipmentSlot.LURE, lure_uuid)

	add_item("worm_bait", "bait", 0)
	add_item("worm_bait", "bait", 0)
	add_item("worm_bait", "bait", 0)
	add_item("worm_bait", "bait", 0)
	add_item("worm_bait", "bait", 0)


func add_item(item_id: String, equipment_type: String, quality: int = 0) -> String:
	var entry: EquipmentEntry = EquipmentEntry.new()
	entry.uuid = _generate_uuid()
	entry.item_id = item_id
	entry.equipment_type = equipment_type
	entry.quality = quality
	entry.level = 1
	inventory.append(entry)
	SignalBus.equipment_item_acquired.emit(entry.uuid, item_id, quality)
	return entry.uuid


func remove_item(uuid: String) -> void:
	inventory.assign(inventory.filter(func(e: EquipmentEntry) -> bool: return e.uuid != uuid))


func get_item(uuid: String) -> EquipmentEntry:
	for entry: EquipmentEntry in inventory:
		if entry.uuid == uuid:
			return entry
	return null


func equip(slot: int, uuid: String) -> void:
	loadout[slot] = uuid
	SignalBus.equipment_changed.emit(slot)


func unequip(slot: int) -> void:
	loadout.erase(slot)
	SignalBus.equipment_changed.emit(slot)


func get_equipped(slot: int) -> EquipmentEntry:
	var uuid: String = loadout.get(slot, "")
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
