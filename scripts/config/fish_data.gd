class_name FishData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var texture: Texture2D
@export var rarity: Enums.Rarity = Enums.Rarity.COMMON
@export var sell_value_coins: int = 10

@export_group("Depth and Spawning")
@export var min_depth: float = 0.0
@export var max_depth: float = 9999.0
@export var biome_flags: int = Enums.BiomeFlag.OCEAN
@export var spawn_weight: float = 1.0
@export var bait_requirement_id: String = ""

@export_group("School Behavior")
@export var min_school_size: int = 1
@export var max_school_size: int = 1
@export var swim_speed: float = 50.0
@export var separation_radius: float = 30.0
@export var scatter_on_catch: bool = true

@export_group("Fight Behavior")
@export var fight_speed: float = 64.0
@export var fight_erratic: float = 0.5
@export var fight_stamina: float = 1.0
@export var tension_generation: float = 1.0
@export var phase_count: int = 1

@export_group("Sprite")
@export var default_orientation: float = 0.0
