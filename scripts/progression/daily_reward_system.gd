class_name DailyRewardSystem
extends RefCounted

const SAVE_PATH: String = "user://daily_rewards.cfg"
const STREAK_LENGTH: int = 7

var current_streak_day: int = 0
var last_claim_date: String = ""
var has_claimed_today: bool = false


class DailyReward:
	var coins: int = 0
	var gems: int = 0
	var free_pull: bool = false


func _init() -> void:
	_load()
	_check_new_day()


func is_reward_available() -> bool:
	return not has_claimed_today


func get_current_day() -> int:
	return current_streak_day + 1


func get_reward_for_day(day: int) -> DailyReward:
	var reward: DailyReward = DailyReward.new()
	match day:
		1:
			reward.coins = 50
		2:
			reward.coins = 75
		3:
			reward.coins = 100
			reward.gems = 5
		4:
			reward.coins = 150
		5:
			reward.coins = 200
			reward.gems = 10
		6:
			reward.coins = 300
			reward.free_pull = true
		7:
			reward.coins = 500
			reward.gems = 25
	return reward


func claim_daily_reward() -> DailyReward:
	if has_claimed_today:
		return null

	var day: int = get_current_day()
	var reward: DailyReward = get_reward_for_day(day)

	if reward.coins > 0:
		CurrencyManager.add_coins(reward.coins)
	if reward.gems > 0:
		CurrencyManager.add_gems(reward.gems)
	if reward.free_pull:
		SignalBus.daily_free_pull_available.emit()

	has_claimed_today = true
	last_claim_date = _get_today_string()

	current_streak_day += 1
	if current_streak_day >= STREAK_LENGTH:
		current_streak_day = 0

	_save()
	return reward


func _check_new_day() -> void:
	var today: String = _get_today_string()
	if last_claim_date == today:
		has_claimed_today = true
		return

	has_claimed_today = false

	if last_claim_date.is_empty():
		return

	var yesterday: String = _get_yesterday_string()
	if last_claim_date != yesterday:
		current_streak_day = 0
		_save()


func _get_today_string() -> String:
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [datetime["year"], datetime["month"], datetime["day"]]


func _get_yesterday_string() -> String:
	var unix_time: int = int(Time.get_unix_time_from_system()) - 86400
	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	return "%04d-%02d-%02d" % [datetime["year"], datetime["month"], datetime["day"]]


func _save() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("streak", "day", current_streak_day)
	config.set_value("streak", "last_claim_date", last_claim_date)
	config.save(SAVE_PATH)


func _load() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	if err != OK:
		return
	current_streak_day = config.get_value("streak", "day", 0)
	last_claim_date = config.get_value("streak", "last_claim_date", "")
