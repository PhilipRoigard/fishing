class_name HookData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export_group("Stats")
@export var bite_window_bonus: float = 0.0
@export var catch_rate_bonus: float = 0.0

@export_group("Leveling")
@export var bite_window_per_level: float = 0.02
@export var catch_rate_per_level: float = 0.01
