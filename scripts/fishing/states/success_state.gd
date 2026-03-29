extends BaseState

var fish_id: String = ""


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")

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

	CurrencyManager.add_coins(fish_data.sell_value_coins)

	var reward_cfg: RewardConfig = null
	if GameResources.config:
		reward_cfg = GameResources.config.reward_config
	if reward_cfg:
		var xp_amount: int = reward_cfg.get_xp_for_rarity(fish_data.rarity)
		SignalBus.xp_gained.emit(xp_amount)

	SignalBus.collection_updated.emit(fish_id, 1)


func _reset_hook_position() -> void:
	var fishing_level: Node = null
	if Main.instance:
		fishing_level = Main.instance.get_node_or_null("FishingLevel")
	if fishing_level:
		var hook: Area2D = fishing_level.get_node_or_null("%Hook")
		if hook:
			hook.position = Vector2(180, 400)
			SignalBus.hook_position_changed.emit(hook.global_position)
