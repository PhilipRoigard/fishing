class_name RodData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export_group("Stats")
@export var cast_depth_range: float = 500.0
@export var reel_speed: float = 1.0
@export var tension_resistance: float = 1.0

@export_group("Leveling")
@export var cast_depth_per_level: float = 25.0
@export var reel_speed_per_level: float = 0.02
@export var tension_resistance_per_level: float = 0.015
