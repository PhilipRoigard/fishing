extends Node

const XP_PER_LEVEL_BASE: int = 100
const XP_LEVEL_EXPONENT: float = 1.3


func _ready() -> void:
	SignalBus.fish_caught.connect(_on_fish_caught)


func _on_fish_caught(fish_id: String) -> void:
	var main_node: Node = _get_main_instance()
	if not main_node or not main_node.database_system:
		return

	var fish_data: Variant = main_node.database_system.get_fish_by_id(fish_id)
	if not fish_data:
		return

	_add_to_collection(fish_id)
	var caught_quality: int = 0
	var state: Variant = main_node.player_state_system.get_state()
	if state and state.equipped_bait_id.begins_with("bait_q"):
		caught_quality = state.equipped_bait_id.substr(6).to_int()
	_grant_xp(caught_quality)


func _add_to_collection(fish_id: String) -> void:
	var main_node: Node = _get_main_instance()
	if not main_node or not main_node.player_state_system:
		return

	var state: Variant = main_node.player_state_system.get_state()
	if not state:
		return

	var count: int = state.collection_log.get(fish_id, 0) + 1
	state.collection_log[fish_id] = count
	state.total_fish_caught += 1

	var cq: int = 0
	if state.equipped_bait_id.begins_with("bait_q"):
		cq = state.equipped_bait_id.substr(6).to_int()
	var best_quality: int = state.collection_best_quality.get(fish_id, -1)
	if cq > best_quality:
		state.collection_best_quality[fish_id] = cq

	SignalBus.collection_updated.emit(fish_id, count)
	SignalBus.save_requested.emit()


func _grant_xp(rarity: int) -> void:
	var reward_cfg: Variant = null
	if GameResources.config:
		reward_cfg = GameResources.config.reward_config
	if not reward_cfg:
		return

	var base_xp: int = reward_cfg.get_xp_for_rarity(rarity)
	var xp_bonus_pct: float = _get_rod_perk_value("bonus_xp")
	var xp_amount: int = int(float(base_xp) * (1.0 + xp_bonus_pct / 100.0))
	var main_node: Node = _get_main_instance()
	if not main_node or not main_node.player_state_system:
		return

	var state: Variant = main_node.player_state_system.get_state()
	if not state:
		return

	state.fisherman_xp += xp_amount
	SignalBus.xp_gained.emit(xp_amount)

	var xp_needed: int = _get_xp_for_level(state.fisherman_level)
	while state.fisherman_xp >= xp_needed:
		state.fisherman_xp -= xp_needed
		state.fisherman_level += 1
		SignalBus.level_up.emit(state.fisherman_level)
		xp_needed = _get_xp_for_level(state.fisherman_level)

	SignalBus.save_requested.emit()


func _get_xp_for_level(level: int) -> int:
	return int(XP_PER_LEVEL_BASE * pow(level, XP_LEVEL_EXPONENT))


func get_current_level() -> int:
	var main_node: Node = _get_main_instance()
	if main_node and main_node.player_state_system:
		var state: Variant = main_node.player_state_system.get_state()
		if state:
			return state.fisherman_level
	return 1


func get_xp_progress() -> float:
	var main_node: Node = _get_main_instance()
	if main_node and main_node.player_state_system:
		var state: Variant = main_node.player_state_system.get_state()
		if state:
			var needed: int = _get_xp_for_level(state.fisherman_level)
			if needed > 0:
				return float(state.fisherman_xp) / float(needed)
	return 0.0


func _get_rod_perk_value(perk_id: String) -> float:
	var rod_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.ROD)
	if not rod_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return 0.0
	var rod_data: RodData = GameResources.config.equipment_catalogue.get_rod_by_id(rod_entry.item_id)
	if not rod_data or rod_data.perk_id != perk_id:
		return 0.0
	var perk_idx: int = mini(rod_entry.quality, rod_data.perk_values.size() - 1)
	return rod_data.perk_values[perk_idx]


func _get_main_instance() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("Main")
