class_name FishPoolSelector
extends RefCounted

var _fish_database: FishDatabase


func _init(fish_database: FishDatabase) -> void:
	_fish_database = fish_database


func select_fish(min_depth: float, max_depth: float, bait_id: String = "") -> FishData:
	if not _fish_database:
		return null

	var eligible: Array[FishData] = []
	eligible.assign(_fish_database.fish.filter(func(f: FishData) -> bool:
		if f.min_depth > max_depth or f.max_depth < min_depth:
			return false
		if f.bait_requirement_id != "" and f.bait_requirement_id != bait_id:
			return false
		return true
	))

	if eligible.is_empty():
		return null

	return _weighted_random_select(eligible)


func _weighted_random_select(candidates: Array[FishData]) -> FishData:
	var total_weight: float = 0.0
	for f: FishData in candidates:
		total_weight += f.spawn_weight

	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for f: FishData in candidates:
		cumulative += f.spawn_weight
		if roll <= cumulative:
			return f

	return candidates.back()
