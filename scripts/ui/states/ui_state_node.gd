class_name UIStateNode
extends Control

var ui_manager: Node
var state_machine: UIStateMachine


func _init():
	visible = false


func initialize(_ui_manager: Node, _state_machine: UIStateMachine) -> void:
	ui_manager = _ui_manager
	state_machine = _state_machine


func enter(_meta: Variant = null) -> void:
	visible = true
	_setup_connections()


func focus() -> void:
	var parent: Node = get_parent()
	parent.move_child.call_deferred(self, parent.get_child_count() - 1)
	if ui_manager:
		ui_manager.raise_overlays()


func unfocus() -> void:
	pass


func exit() -> void:
	visible = false
	_cleanup_connections()


func _setup_connections() -> void:
	pass


func _cleanup_connections() -> void:
	pass


func _back() -> void:
	if state_machine._get_active_state_node() == self:
		state_machine.pop_state()
