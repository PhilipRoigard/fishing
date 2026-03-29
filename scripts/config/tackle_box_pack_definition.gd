class_name TackleBoxPackDefinition
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var gem_cost: int = 100
@export var items_per_pull: int = 1
@export var daily_limit: int = 10
@export var item_pool_ids: Array[String] = []

@export_group("Quality Weights")
@export var common_weight: float = 60.0
@export var uncommon_weight: float = 25.0
@export var rare_weight: float = 10.0
@export var epic_weight: float = 4.0
@export var legendary_weight: float = 1.0

@export_group("Pity")
@export var pity_threshold: int = 30
@export var pity_minimum_quality: Enums.ItemQuality = Enums.ItemQuality.RARE


func get_quality_weights() -> Dictionary:
	return {
		Enums.ItemQuality.COMMON: common_weight,
		Enums.ItemQuality.UNCOMMON: uncommon_weight,
		Enums.ItemQuality.RARE: rare_weight,
		Enums.ItemQuality.EPIC: epic_weight,
		Enums.ItemQuality.LEGENDARY: legendary_weight,
	}


func get_total_weight() -> float:
	return common_weight + uncommon_weight + rare_weight + epic_weight + legendary_weight
