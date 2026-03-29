class_name LureData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export_group("Stats")
@export var rare_fish_chance_bonus: float = 0.0
@export var bite_speed_bonus: float = 0.0

@export_group("Leveling")
@export var rare_fish_chance_per_level: float = 0.005
@export var bite_speed_per_level: float = 0.03
