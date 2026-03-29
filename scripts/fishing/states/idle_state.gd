extends BaseState


func enter(_meta: Dictionary = {}) -> void:
	SignalBus.fishing_state_changed.emit(Enums.FishingState.IDLE)
	SignalBus.cast_input_started.connect(_on_cast_input_started)


func exit() -> void:
	if SignalBus.cast_input_started.is_connected(_on_cast_input_started):
		SignalBus.cast_input_started.disconnect(_on_cast_input_started)


func _on_cast_input_started() -> void:
	state_machine.change_state(&"casting")
