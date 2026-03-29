class_name RewardConfig
extends Resource

@export_group("XP Rewards")
@export var xp_per_common_catch: int = 10
@export var xp_per_uncommon_catch: int = 25
@export var xp_per_rare_catch: int = 50
@export var xp_per_legendary_catch: int = 150

@export_group("Sell Value Multipliers")
@export var uncommon_sell_multiplier: float = 1.5
@export var rare_sell_multiplier: float = 2.5
@export var legendary_sell_multiplier: float = 5.0

@export_group("Milestones")
@export var collection_milestone_gem_reward: int = 50
@export var level_up_coin_reward: int = 100

@export_group("Daily Rewards")
@export var daily_login_coins: int = 50
@export var daily_login_gems: int = 5
@export var daily_free_pull: bool = true


func get_xp_for_rarity(rarity: Enums.Rarity) -> int:
	match rarity:
		Enums.Rarity.COMMON:
			return xp_per_common_catch
		Enums.Rarity.UNCOMMON:
			return xp_per_uncommon_catch
		Enums.Rarity.RARE:
			return xp_per_rare_catch
		Enums.Rarity.LEGENDARY:
			return xp_per_legendary_catch
	return xp_per_common_catch


func get_sell_multiplier(rarity: Enums.Rarity) -> float:
	match rarity:
		Enums.Rarity.UNCOMMON:
			return uncommon_sell_multiplier
		Enums.Rarity.RARE:
			return rare_sell_multiplier
		Enums.Rarity.LEGENDARY:
			return legendary_sell_multiplier
	return 1.0
