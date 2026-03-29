extends Node

var current_fishing_state: int = 0
var is_in_fishing_game: bool = false


func _ready() -> void:
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	SignalBus.game_mode_changed.connect(_on_game_mode_changed)


func _input(event: InputEvent) -> void:
	if not is_in_fishing_game:
		return

	if event is InputEventScreenTouch:
		_handle_press(event.pressed)
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_handle_press(mb.pressed)


func _handle_press(pressed: bool) -> void:
	match current_fishing_state:
		Enums.FishingState.IDLE:
			if pressed:
				SignalBus.cast_input_started.emit()
		Enums.FishingState.CASTING:
			if not pressed:
				SignalBus.cast_input_ended.emit()
		Enums.FishingState.WAITING:
			pass
		Enums.FishingState.BITE_ALERT:
			if pressed:
				SignalBus.reel_input_started.emit()
		Enums.FishingState.FIGHTING:
			if pressed:
				SignalBus.reel_input_started.emit()
			else:
				SignalBus.reel_input_ended.emit()


func _on_fishing_state_changed(state: int) -> void:
	current_fishing_state = state


func _on_game_mode_changed(mode: int) -> void:
	is_in_fishing_game = (mode == Enums.GameMode.FISHING_SESSION)
