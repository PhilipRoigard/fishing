class_name PlayerState
extends Resource

@export var coins: int = 0
@export var gems: int = 0
@export var fisherman_level: int = 1
@export var fisherman_xp: int = 0
@export var total_fish_caught: int = 0
@export var collection_log: Dictionary = {}
@export var collection_best_quality: Dictionary = {}
@export var equipped_rod_uuid: String = ""
@export var equipped_hook_uuid: String = ""
@export var equipped_lure_uuid: String = ""
@export var equipped_bait_id: String = ""
@export var kept_fish: Dictionary = {}
@export var bait_inventory: Dictionary = {}
@export var max_depth_unlocked: float = 500.0
@export var onboarding_complete: bool = false
@export var daily_login_streak: int = 0
@export var last_login_date: String = ""
