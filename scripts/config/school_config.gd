class_name SchoolConfig
extends Resource

@export_group("Boid Weights")
@export var cohesion_weight: float = 1.0
@export var alignment_weight: float = 0.8
@export var separation_weight: float = 1.2

@export_group("Movement")
@export var max_steer_force: float = 150.0
@export var neighbor_radius: float = 80.0
@export var rotation_lerp_speed: float = 8.0
@export var school_spawn_spread: float = 60.0

@export_group("Scatter")
@export var scatter_speed_multiplier: float = 2.5
@export var scatter_duration: float = 1.2

@export_group("Pathfinding")
@export var waypoint_reach_distance: float = 24.0
@export var cell_size: int = 16

@export_group("Despawn")
@export var offscreen_despawn_time: float = 5.0
