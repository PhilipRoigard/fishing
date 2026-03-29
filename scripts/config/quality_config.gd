class_name QualityConfig
extends Resource

@export var base_stat_multiplier: float = 1.4
@export var base_level_cost: int = 100
@export var level_cost_exponent: float = 1.0544

@export var level_caps: Dictionary = {
	Enums.ItemQuality.COMMON: 15,
	Enums.ItemQuality.UNCOMMON: 35,
	Enums.ItemQuality.RARE: 60,
	Enums.ItemQuality.EPIC: 90,
	Enums.ItemQuality.LEGENDARY: 120,
}


func get_level_cap(quality: Enums.ItemQuality) -> int:
	return level_caps.get(quality, 15)


func get_level_up_cost(quality: Enums.ItemQuality, current_level: int) -> int:
	var quality_mult: float = Enums.QUALITY_MULTIPLIERS.get(quality, 1.0)
	return int(base_level_cost * quality_mult * pow(level_cost_exponent, current_level - 1))


func get_stat_multiplier(quality: Enums.ItemQuality) -> float:
	return Enums.QUALITY_MULTIPLIERS.get(quality, 1.0)
