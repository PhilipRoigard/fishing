class_name UIStateMachine
extends Node

signal state_changed(new_state: State)

enum State {
	LOADING,
	MAIN_MENU,
	WHARF_HUB,
	FISHING_GAME,
	CATCH_RESULT,
	EQUIPMENT,
	EQUIPMENT_DETAILS,
	COLLECTION_LOG,
	FISH_DETAILS,
	STORE,
	TACKLE_BOX,
	TACKLE_BOX_REVEAL,
	SETTINGS,
	PAUSE,
	YES_NO_POPUP,
	TOOLTIP,
	PURCHASING,
	CONSENT,
	BAIT_CRAFT,
}

var active_states: Array[UIStateNode] = []
var states: Dictionary = {}
var ui_manager: Node


func _init(_ui_manager: Node = null):
	ui_manager = _ui_manager


func add_state(state: State, state_node: UIStateNode) -> void:
	states[state] = state_node
	state_node.initialize(ui_manager, self)


func change_state(state: State, meta: Variant = null) -> void:
	if state not in states:
		push_error("UIStateMachine: State not found: %s" % state)
		return

	while not active_states.is_empty():
		_get_active_state_node().unfocus()
		_get_active_state_node().exit()
		active_states.pop_back()

	active_states.push_back(states[state])
	_get_active_state_node().enter(meta)
	_get_active_state_node().focus()
	state_changed.emit(state)


func push_state(state: State, meta: Variant = null) -> void:
	if active_states.is_empty():
		push_error("UIStateMachine: Can't push state when no active states exist. Use change_state instead.")
		return

	if state not in states:
		push_error("UIStateMachine: State not found: %s" % state)
		return

	_get_active_state_node().unfocus()
	active_states.push_back(states[state])
	_get_active_state_node().enter(meta)
	_get_active_state_node().focus()
	state_changed.emit(state)


func pop_state() -> void:
	if active_states.size() <= 1:
		push_error("UIStateMachine: Can't pop last state")
		return

	_get_active_state_node().unfocus()
	_get_active_state_node().exit()
	active_states.pop_back()
	_get_active_state_node().focus()
	state_changed.emit(_get_active_state())


func replace_top_state(state: State, meta: Variant = null) -> void:
	if active_states.size() <= 1:
		push_state(state, meta)
		return

	if state not in states:
		push_error("UIStateMachine: State not found: %s" % state)
		return

	_get_active_state_node().unfocus()
	_get_active_state_node().exit()
	active_states.pop_back()
	active_states.push_back(states[state])
	_get_active_state_node().enter(meta)
	_get_active_state_node().focus()
	state_changed.emit(state)


func _get_active_state() -> State:
	for state_key: State in states:
		if states[state_key] == _get_active_state_node():
			return state_key
	return State.MAIN_MENU


func _get_active_state_node() -> UIStateNode:
	return active_states.back()


func is_state_active(state: State) -> bool:
	return states.get(state) in active_states


func show_yes_no_popup(
		description: String,
		yes_text: String,
		no_text: String,
		yes_func: Callable = func(): pass,
		no_func: Callable = func(): pass) -> void:
	var meta: Dictionary = {
		"desc": description,
		"yes_text": yes_text,
		"no_text": no_text,
		"yes_func": yes_func,
		"no_func": no_func,
	}
	push_state(State.YES_NO_POPUP, meta)


func show_tooltip(text: String = "", scene_path: String = "") -> void:
	var meta: Dictionary = {}
	if text != "":
		meta["text"] = text
	if scene_path != "":
		meta["tooltip_scene"] = scene_path
	push_state(State.TOOLTIP, meta)
