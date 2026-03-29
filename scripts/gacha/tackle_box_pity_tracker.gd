class_name TackleBoxPityTracker
extends RefCounted

const SAVE_PATH: String = "user://tackle_box_pity.cfg"

var _pull_counts: Dictionary = {}


func _init() -> void:
	_load()


func get_pull_count(pack_id: String) -> int:
	if _pull_counts.has(pack_id):
		return _pull_counts[pack_id]
	return 0


func check_pity(pack_id: String, threshold: int) -> bool:
	return get_pull_count(pack_id) >= threshold


func record_pull(pack_id: String) -> void:
	if not _pull_counts.has(pack_id):
		_pull_counts[pack_id] = 0
	_pull_counts[pack_id] += 1
	_save()


func reset(pack_id: String) -> void:
	_pull_counts[pack_id] = 0
	_save()


func _save() -> void:
	var config: ConfigFile = ConfigFile.new()
	for pack_id: String in _pull_counts:
		config.set_value("pity", pack_id, _pull_counts[pack_id])
	config.save(SAVE_PATH)


func _load() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	if err != OK:
		return
	for pack_id: String in config.get_section_keys("pity"):
		_pull_counts[pack_id] = config.get_value("pity", pack_id, 0)
