class_name Main
extends Node

static var instance: Main

var game_mode_state_machine: StateMachine
var fishing_system: Node
var fish_spawner_system: Node
var database_system: Node
var player_state_system: Node
var input_system: Node
var ui_manager: Node


func _init():
	instance = self


func _ready():
	_initialize_systems()
	_emit_initial_state.call_deferred()


func _initialize_systems() -> void:
	database_system = preload("res://scripts/systems/database_system.gd").new()
	database_system.name = "DatabaseSystem"
	add_child(database_system)

	player_state_system = preload("res://scripts/systems/player_state_system.gd").new()
	player_state_system.name = "PlayerStateSystem"
	add_child(player_state_system)

	input_system = preload("res://scripts/systems/input_system.gd").new()
	input_system.name = "InputSystem"
	add_child(input_system)

	fishing_system = preload("res://scripts/systems/fishing_system.gd").new()
	fishing_system.name = "FishingSystem"
	add_child(fishing_system)

	fish_spawner_system = preload("res://scripts/systems/fish_spawner_system.gd").new()
	fish_spawner_system.name = "FishSpawnerSystem"
	add_child(fish_spawner_system)

	game_mode_state_machine = StateMachine.new()
	game_mode_state_machine.name = "GameModeStateMachine"
	add_child(game_mode_state_machine)

	var fishing_level: Node2D = preload("res://scenes/fishing/fishing_level.tscn").instantiate()
	fishing_level.name = "FishingLevel"
	add_child(fishing_level)

	var ui_scene: PackedScene = preload("res://scenes/ui/ui.tscn")
	ui_manager = ui_scene.instantiate()
	add_child(ui_manager)


func _emit_initial_state() -> void:
	SignalBus.game_mode_changed.emit(Enums.GameMode.MAIN_MENU)
