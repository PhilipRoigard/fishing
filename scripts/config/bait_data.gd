class_name BaitData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export_group("Stats")
@export var attraction_modifier: float = 1.0
@export var rarity_weight_bonus: float = 0.0
@export var required_for_fish_ids: Array[String] = []

@export_group("Economy")
@export var craft_cost_coins: int = 50
@export var is_consumable: bool = true
