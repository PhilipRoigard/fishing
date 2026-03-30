extends BaseState

var target_depth: float = 0.0
var fishing_config: FishingConfig
var hook_node: Area2D
var check_timer: float = 0.0
var attract_timer: float = 0.0
var total_wait_time: float = 0.0
var has_attracted: bool = false
var force_bite_timer: float = 0.0



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

	if not has_attracted and total_wait_time >= fishing_config.attract_delay:
		has_attracted = true
		_attract_nearby_fish()

	if total_wait_time >= fishing_config.force_attract_time and int(total_wait_time * 2) % 3 == 0:
		_force_attract_fish()

	if check_timer >= fishing_config.bite_check_interval:
		check_timer = 0.0
		var nibbling_fish: SwimmingFish = _find_nibbling_fish()
		if nibbling_fish:
			var bite_chance: float = _get_bite_chance()
			if randf() < bite_chance:
				nibbling_fish.velocity = Vector2.ZERO
				nibbling_fish._is_curious = false
				_trigger_bite_from_fish(nibbling_fish)
				return



func _find_hook() -> void:
	if Main.instance:
		hook_node = Main.instance.get_node_or_null("FishingLevel/HookLayer/Hook") as Area2D


func _find_nibbling_fish() -> SwimmingFish:
	if not hook_node:
		return null

	var hook_pos: Vector2 = hook_node.global_position
	var fish_layer: Node = _get_fish_layer()
	if not fish_layer:
		return null

	var closest_fish: SwimmingFish = null
	var bite_radius: float = _get_bite_radius()
	var closest_dist: float = bite_radius

	for school: Node in fish_layer.get_children():
		for fish_node: Node in school.get_children():
			if not (fish_node is SwimmingFish):
				continue
			var fish: SwimmingFish = fish_node as SwimmingFish
			if fish.is_caught or not fish._is_curious:
				continue
			var dist: float = fish.global_position.distance_to(hook_pos)
			if dist < closest_dist:
				closest_dist = dist
				closest_fish = fish

	return closest_fish


func _get_lure_perk() -> Dictionary:
	var lure_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.LURE)
	if not lure_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return {"id": "none", "value": 0.0}
	var lure_data: LureData = GameResources.config.equipment_catalogue.get_lure_by_id(lure_entry.item_id)
	if not lure_data or lure_data.perk_id == "none":
		return {"id": "none", "value": 0.0}
	var perk_idx: int = mini(lure_entry.quality, lure_data.perk_values.size() - 1)
	return {"id": lure_data.perk_id, "value": lure_data.perk_values[perk_idx]}


func _get_bite_radius() -> float:
	var radius: float = fishing_config.base_bite_radius
	var perk: Dictionary = _get_lure_perk()
	if perk["id"] == "bite_radius":
		radius *= 1.0 + perk["value"] / 100.0
	return radius


func _get_bite_chance() -> float:
	var chance: float = fishing_config.base_bite_chance

	var hook_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.HOOK)
	if hook_entry:
		var stat_cfg: EquipmentStatConfig = GameResources.config.equipment_stat_config if GameResources.config else null
		if stat_cfg:
			chance += stat_cfg.get_bite_bonus_at_level(hook_entry.level, hook_entry.quality) / 100.0

		var hook_perk: Dictionary = _get_hook_perk()
		if hook_perk["id"] == "bite_chance":
			chance += hook_perk["value"] / 100.0

	var lure_perk: Dictionary = _get_lure_perk()
	if lure_perk["id"] == "bite_chance":
		chance += lure_perk["value"] / 100.0

	return clampf(chance, 0.05, 0.95)


func _get_hook_perk() -> Dictionary:
	var hook_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.HOOK)
	if not hook_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return {"id": "none", "value": 0.0}
	var hook_data: HookData = GameResources.config.equipment_catalogue.get_hook_by_id(hook_entry.item_id)
	if not hook_data or hook_data.perk_id == "none":
		return {"id": "none", "value": 0.0}
	var perk_idx: int = mini(hook_entry.quality, hook_data.perk_values.size() - 1)
	return {"id": hook_data.perk_id, "value": hook_data.perk_values[perk_idx]}


func _get_attract_range() -> float:
	var attract: float = fishing_config.base_attract_range
	var perk: Dictionary = _get_lure_perk()
	if perk["id"] == "attract_range":
		attract *= 1.0 + perk["value"] / 100.0
	return attract


func _get_curiosity_multiplier() -> float:
	var perk: Dictionary = _get_lure_perk()
	if perk["id"] == "curiosity_duration":
		return 1.0 + perk["value"] / 100.0
	return 1.0


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
			var attract_range: float = _get_attract_range()
			if dist < attract_range:
				fish._is_curious = true
				fish._curiosity_target = hook_pos + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
				fish._curiosity_timer = randf_range(6.0, 12.0) * _get_curiosity_multiplier()
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
