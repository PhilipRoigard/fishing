extends Node

var config: Resource


func _ready():
	config = load("res://data/game_resources_config.tres")
	if not config:
		push_error("GameResources: Failed to load game_resources_config.tres")
