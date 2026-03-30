class_name LureData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

@export_group("Perk")
@export var perk_name: String = ""
@export var perk_description: String = ""
@export var perk_id: String = "none"
@export var perk_values: Array[float] = [0.0, 0.0, 0.0, 0.0]
