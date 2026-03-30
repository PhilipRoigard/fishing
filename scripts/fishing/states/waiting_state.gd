extends BaseState

var target_depth: float = 0.0
var fishing_config: FishingConfig
var hook_node: Area2D
var check_timer: float = 0.0
var attract_timer: float = 0.0
var total_wait_time: float = 0.0
var has_attracted: bool = false
var force_bite_timer: float = 0.0

const BITE_RADIUS: float = 35.0
const CHECK_INTERVAL: float = 0.2
const ATTRACT_DELAY: float = 1.5
const FORCE_ATTRACT_TIME: float = 5.0
const FORCE_BITE_TIME: float = 10.0


func enter(meta: Dictionary = {}) -> void:
	target_depth = meta.get("depth", 100.0)
	if GameResources.config:
		fishing_config = GameResources.config.fishing_config
	check_timer = 0.0
	attract_timer = 0.0
	total_wait_time = 0.0
	has_attracted = false
	force_bite_timer = 0.0
	_find_hook()
	SignalBus.fishing_state_changed.emit(Enums.FishingState.WAITING)


func exit() -> void:
	pass


func update(delta: float) -> void:
	total_wait_time += delta
	check_timer += delta
	force_bite_timer += delta

	if not has_attracted and total_wait_time >= ATTRACT_DELAY:
		has_attracted = true
		_attract_nearby_fish()

	if total_wait_time >= FORCE_ATTRACT_TIME and int(total_wait_time * 2) % 3 == 0:
		_force_attract_fish()

	if check_timer >= CHECK_INTERVAL:
		check_timer = 0.0
		var biting_fish: Node = _find_fish_near_hook()
		if biting_fish:
			_trigger_bite_from_fish(biting_fish)
			return



func _find_hook() -> void:
	if Main.instance:
		hook_node = Main.instance.get_node_or_null("FishingLevel/HookLayer/Hook") as Area2D


func _find_fish_near_hook() -> Node:
	if not hook_node:
		return null

	var hook_pos: Vector2 = hook_node.global_position
	var fish_layer: Node = _get_fish_layer()
	if not fish_layer:
		return null

	var closest_fish: Node = null
	var closest_dist: float = BITE_RADIUS

	for school: Node in fish_layer.get_children():
		for fish_node: Node in school.get_children():
			if not (fish_node is SwimmingFish):
				continue
			var fish: SwimmingFish = fish_node as SwimmingFish
			if fish.is_caught:
				continue
			var dist: float = fish.global_position.distance_to(hook_pos)
			if dist < closest_dist:
				closest_dist = dist
				closest_fish = fish

	return closest_fish


func _trigger_bite_from_fish(fish_node: Node) -> void:
	var fish: SwimmingFish = fish_node as SwimmingFish
	if not fish or not fish.fish_data:
		return
	state_machine.change_state(&"bite_alert", {
		"fish_id": fish.fish_data.id,
		"depth": target_depth,
		"fish_node": fish,
	})


func _trigger_fallback_bite() -> void:
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_for_depth(target_depth)
	if fish_data:
		state_machine.change_state(&"bite_alert", {
			"fish_id": fish_data.id,
			"depth": target_depth,
		})


func _attract_nearby_fish() -> void:
	if not hook_node:
		return
	var hook_pos: Vector2 = hook_node.global_position
	var fish_layer: Node = _get_fish_layer()
	if not fish_layer:
		return

	for school: Node in fish_layer.get_children():
		for fish_node: Node in school.get_children():
			if not (fish_node is SwimmingFish):
				continue
			var fish: SwimmingFish = fish_node as SwimmingFish
			if fish.is_caught or fish._is_curious:
				continue
			var dist: float = fish.global_position.distance_to(hook_pos)
			if dist < 250.0:
				fish._is_curious = true
				fish._curiosity_target = hook_pos + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
				fish._curiosity_timer = randf_range(6.0, 12.0)
				fish._nibble_timer = randf_range(0.3, 1.0)
				return


func _force_attract_fish() -> void:
	if not hook_node:
		return
	var hook_pos: Vector2 = hook_node.global_position
	var fish_layer: Node = _get_fish_layer()
	if not fish_layer:
		return

	var best_fish: SwimmingFish = null
	var best_dist: float = 9999.0

	for school: Node in fish_layer.get_children():
		for fish_node: Node in school.get_children():
			if not (fish_node is SwimmingFish):
				continue
			var fish: SwimmingFish = fish_node as SwimmingFish
			if fish.is_caught:
				continue
			var dist: float = fish.global_position.distance_to(hook_pos)
			if dist < best_dist:
				best_dist = dist
				best_fish = fish

	if best_fish:
		best_fish._is_curious = true
		best_fish._curiosity_target = hook_pos
		best_fish._curiosity_timer = 15.0
		best_fish._nibble_timer = 0.1


func _get_fish_layer() -> Node:
	if Main.instance:
		return Main.instance.get_node_or_null("FishingLevel/FishLayer")
	return null
