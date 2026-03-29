extends Node

var fish_database: FishDatabase


func _ready() -> void:
	if GameResources.config and GameResources.config.fish_database:
		fish_database = GameResources.config.fish_database


func get_fish_by_id(fish_id: String) -> FishData:
	if fish_database:
		return fish_database.get_fish_by_id(fish_id)
	return null


func get_fish_for_depth(depth: float, bait_id: String = "") -> FishData:
	if fish_database:
		return fish_database.get_random_fish_for_depth(depth, bait_id)
	return null
