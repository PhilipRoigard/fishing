extends BaseState

var fish_id: String = ""


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")
	var fish_node: Variant = meta.get("fish_node", null)
	if fish_node != null and is_instance_valid(fish_node) and fish_node is SwimmingFish:
		(fish_node as SwimmingFish).catch_fish()

	_grant_rewards()
	_reset_hook_position()

	SignalBus.fish_caught.emit(fish_id)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.SUCCESS)
	HapticManager.success_feedback()


func exit() -> void:
	pass


func _grant_rewards() -> void:
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(fish_id)

	if not fish_data:
		return

	var reward_cfg: RewardConfig = null
	if GameResources.config:
		reward_cfg = GameResources.config.reward_config
	if reward_cfg:
		var base_xp: int = reward_cfg.get_xp_for_rarity(0)
		var xp_bonus_pct: float = _get_rod_perk_value("bonus_xp")
		var xp_amount: int = int(float(base_xp) * (1.0 + xp_bonus_pct / 100.0))
		SignalBus.xp_gained.emit(xp_amount)

	SignalBus.collection_updated.emit(fish_id, 1)


func _get_rod_perk_value(perk_id: String) -> float:
	var rod_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.ROD)
	if not rod_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return 0.0
	var rod_data: RodData = GameResources.config.equipment_catalogue.get_rod_by_id(rod_entry.item_id)
	if not rod_data or rod_data.perk_id != perk_id:
		return 0.0
	var perk_idx: int = mini(rod_entry.quality, rod_data.perk_values.size() - 1)
	return rod_data.perk_values[perk_idx]


func _reset_hook_position() -> void:
	var fishing_level: Node = null
	if Main.instance:
		fishing_level = Main.instance.get_node_or_null("FishingLevel")
	if fishing_level:
		var hook: Area2D = fishing_level.get_node_or_null("%Hook")
		if hook:
			hook.position = Vector2(180, 400)
			SignalBus.hook_position_changed.emit(hook.global_position)
