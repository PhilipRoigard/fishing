extends Node

var fishing_state_machine: StateMachine
var fishing_config: FishingConfig


func _ready() -> void:
	if GameResources.config:
		fishing_config = GameResources.config.fishing_config

	fishing_state_machine = StateMachine.new()
	fishing_state_machine.name = "FishingStateMachine"
	add_child(fishing_state_machine)

	_setup_states()


func _setup_states() -> void:
	var idle_state: BaseState = preload("res://scripts/fishing/states/idle_state.gd").new()
	idle_state.name = "IdleState"
	fishing_state_machine.add_state(&"idle", idle_state)

	var casting_state: BaseState = preload("res://scripts/fishing/states/casting_state.gd").new()
	casting_state.name = "CastingState"
	fishing_state_machine.add_state(&"casting", casting_state)

	var waiting_state: BaseState = preload("res://scripts/fishing/states/waiting_state.gd").new()
	waiting_state.name = "WaitingState"
	fishing_state_machine.add_state(&"waiting", waiting_state)

	var bite_alert_state: BaseState = preload("res://scripts/fishing/states/bite_alert_state.gd").new()
	bite_alert_state.name = "BiteAlertState"
	fishing_state_machine.add_state(&"bite_alert", bite_alert_state)

	var fighting_state: BaseState = preload("res://scripts/fishing/states/fighting_state.gd").new()
	fighting_state.name = "FightingState"
	fishing_state_machine.add_state(&"fighting", fighting_state)

	var success_state: BaseState = preload("res://scripts/fishing/states/success_state.gd").new()
	success_state.name = "SuccessState"
	fishing_state_machine.add_state(&"success", success_state)

	var fail_state: BaseState = preload("res://scripts/fishing/states/fail_state.gd").new()
	fail_state.name = "FailState"
	fishing_state_machine.add_state(&"fail", fail_state)

	fishing_state_machine.change_state(&"idle")


func start_fishing() -> void:
	fishing_state_machine.change_state(&"idle")
	SignalBus.game_mode_changed.emit(Enums.GameMode.FISHING_SESSION)
	SignalBus.fishing_session_started.emit()


func stop_fishing() -> void:
	fishing_state_machine.change_state(&"idle")
	SignalBus.game_mode_changed.emit(Enums.GameMode.WHARF_HUB)
	SignalBus.fishing_session_ended.emit()
