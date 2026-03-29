extends Node

const SAVE_PATH: String = "user://player_state.tres"

var player_state: PlayerState


func _ready() -> void:
	_load_state()
	SignalBus.save_requested.connect(_save_state)


func _load_state() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		player_state = load(SAVE_PATH)
	else:
		player_state = PlayerState.new()
	SignalBus.load_completed.emit()


func _save_state() -> void:
	ResourceSaver.save(player_state, SAVE_PATH)
	SignalBus.save_completed.emit()


func get_state() -> PlayerState:
	return player_state
