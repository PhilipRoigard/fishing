class_name DepthZoneEntry
extends Resource

@export var zone_name: String = ""
@export var zone_type: Enums.DepthZone = Enums.DepthZone.SHALLOWS
@export var min_depth: float = 0.0
@export var max_depth: float = 500.0
@export var background_color_top: Color = Color(0.2, 0.6, 0.9)
@export var background_color_bottom: Color = Color(0.1, 0.4, 0.7)
@export var ambient_particle_density: float = 1.0
