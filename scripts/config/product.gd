class_name Product
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var type: String = ""
@export var category: String = ""
@export var coin_amount: int = 0
@export var gem_amount: int = 0
@export var store_price_usd: float = 0.99
@export var is_consumable: bool = true
@export var grants_premium: bool = false
@export var icon: Texture2D
