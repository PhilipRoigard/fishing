class_name RewardCalculator
extends RefCounted


static func calculate_coin_reward(fish: FishData, rod_quality_bonus: float = 1.0) -> int:
	if not fish:
		return 0

	var reward_config: RewardConfig = _get_reward_config()
	var rarity_multiplier: float = 1.0
	if reward_config:
		rarity_multiplier = reward_config.get_sell_multiplier(fish.rarity)

	var base_value: float = float(fish.sell_value_coins)
	var final_value: float = base_value * rarity_multiplier * rod_quality_bonus

	return maxi(1, roundi(final_value))


static func calculate_xp_reward(fish: FishData) -> int:
	if not fish:
		return 0

	var reward_config: RewardConfig = _get_reward_config()
	if reward_config:
		return reward_config.get_xp_for_rarity(fish.rarity)

	match fish.rarity:
		Enums.Rarity.COMMON:
			return 10
		Enums.Rarity.UNCOMMON:
			return 25
		Enums.Rarity.RARE:
			return 50
		Enums.Rarity.LEGENDARY:
			return 150
	return 10


static func _get_reward_config() -> RewardConfig:
	if GameResources.config and GameResources.config.reward_config:
		return GameResources.config.reward_config
	return null
