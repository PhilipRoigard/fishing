class_name StateMachine
extends Node

signal state_changed(new_state: StringName)

var current_state: BaseState
var states: Dictionary = {}


func add_state(state_name: StringName, state: BaseState) -> void:
	states[state_name] = state
	state.state_machine = self
	add_child(state)


func change_state(new_state_name: StringName, meta: Dictionary = {}) -> void:
	if new_state_name not in states:
		push_error("StateMachine: State '%s' not found" % new_state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[new_state_name]
	current_state.enter(meta)
	state_changed.emit(new_state_name)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
