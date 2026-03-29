class_name FishDatabase
extends Resource

@export var fish: Array[FishData] = []


func get_fish_by_id(fish_id: String) -> FishData:
	for f: FishData in fish:
		if f.id == fish_id:
			return f
	return null


func get_fish_for_biome(biome_flag: int) -> Array[FishData]:
	var result: Array[FishData] = []
	result.assign(fish.filter(func(f: FishData) -> bool: return f.biome_flags & biome_flag != 0))
	return result


func get_fish_in_depth_range(min_d: float, max_d: float) -> Array[FishData]:
	var result: Array[FishData] = []
	result.assign(fish.filter(func(f: FishData) -> bool: return f.min_depth <= max_d and f.max_depth >= min_d))
	return result


func get_random_fish_for_depth(depth: float, bait_id: String = "") -> FishData:
	var eligible: Array[FishData] = []
	eligible.assign(fish.filter(func(f: FishData) -> bool:
		if depth < f.min_depth or depth > f.max_depth:
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
