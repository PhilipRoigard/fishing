class_name EquipmentCatalogue
extends Resource

@export var rods: Array[RodData] = []
@export var hooks: Array[HookData] = []
@export var lures: Array[LureData] = []
@export var baits: Array[BaitData] = []
@export var consumables: Array[ConsumableData] = []


func get_rod_by_id(id: String) -> RodData:
	for rod: RodData in rods:
		if rod.id == id:
			return rod
	return null


func get_hook_by_id(id: String) -> HookData:
	for hook: HookData in hooks:
		if hook.id == id:
			return hook
	return null


func get_lure_by_id(id: String) -> LureData:
	for lure: LureData in lures:
		if lure.id == id:
			return lure
	return null


func get_bait_by_id(id: String) -> BaitData:
	for bait: BaitData in baits:
		if bait.id == id:
			return bait
	return null


func get_consumable_by_id(id: String) -> ConsumableData:
	for consumable: ConsumableData in consumables:
		if consumable.id == id:
			return consumable
	return null
