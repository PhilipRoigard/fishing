class_name ConsumableData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var effect_type: Enums.ConsumableEffect = Enums.ConsumableEffect.STUN
@export var duration: float = 0.0
@export var magnitude: float = 1.0
@export var rarity: Enums.ItemQuality = Enums.ItemQuality.COMMON
@export var icon: Texture2D
@export var max_stack: int = 10
