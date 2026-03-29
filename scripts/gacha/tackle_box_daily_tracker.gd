class_name TackleBoxDailyTracker
extends RefCounted

const SAVE_PATH: String = "user://tackle_box_daily.cfg"

var _pull_counts: Dictionary = {}
var _last_date: String = ""


func _init() -> void:
	_load()
	_check_date_reset()


func can_pull(pack_id: String, daily_limit: int) -> bool:
	_check_date_reset()
	var current_pulls: int = _get_pull_count(pack_id)
	return current_pulls < daily_limit


func get_remaining_pulls(pack_id: String, daily_limit: int) -> int:
	_check_date_reset()
	var current_pulls: int = _get_pull_count(pack_id)
	return maxi(0, daily_limit - current_pulls)


func record_pull(pack_id: String) -> void:
	_check_date_reset()
	if not _pull_counts.has(pack_id):
		_pull_counts[pack_id] = 0
	_pull_counts[pack_id] += 1
	_save()


func _get_pull_count(pack_id: String) -> int:
	if _pull_counts.has(pack_id):
		return _pull_counts[pack_id]
	return 0


func _check_date_reset() -> void:
	var today: String = _get_today_string()
	if _last_date != today:
		_pull_counts.clear()
		_last_date = today
		_save()


func _get_today_string() -> String:
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [datetime["year"], datetime["month"], datetime["day"]]


func _save() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("daily", "date", _last_date)
	for pack_id: String in _pull_counts:
		config.set_value("pulls", pack_id, _pull_counts[pack_id])
	config.save(SAVE_PATH)


func _load() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	if err != OK:
		return
	_last_date = config.get_value("daily", "date", "")
	if config.has_section("pulls"):
		for pack_id: String in config.get_section_keys("pulls"):
			_pull_counts[pack_id] = config.get_value("pulls", pack_id, 0)
