class_name EquipmentStatConfig
extends Resource

@export_group("Cast Depth")
@export var base_cast_depth: int = 100
@export var cast_depth_per_level: int = 10

@export_group("Quality Scaling")
@export var quality_stat_multiplier: float = 1.4

@export_group("Level Caps")
@export var common_level_cap: int = 15
@export var uncommon_level_cap: int = 35
@export var rare_level_cap: int = 60
@export var epic_level_cap: int = 90

@export_group("Level Up Cost")
@export var base_level_cost: int = 100
@export var level_cost_multiplier: float = 1.0544


func get_cast_depth_at_level(level: int, quality: int) -> int:
	var raw: int = base_cast_depth + (level - 1) * cast_depth_per_level
	return int(raw * get_quality_multiplier(quality))


func get_quality_multiplier(quality: int) -> float:
	return pow(quality_stat_multiplier, quality)


func get_level_cap(quality: int) -> int:
	match quality:
		0: return common_level_cap
		1: return uncommon_level_cap
		2: return rare_level_cap
		3: return epic_level_cap
	return common_level_cap


func get_level_up_cost(current_level: int) -> int:
	if current_level < 1:
		return 0
	return int(base_level_cost * pow(level_cost_multiplier, current_level - 1))
