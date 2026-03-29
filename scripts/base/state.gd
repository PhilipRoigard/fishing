class_name BaseState
extends Node

var state_machine: StateMachine


func enter(_meta: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
