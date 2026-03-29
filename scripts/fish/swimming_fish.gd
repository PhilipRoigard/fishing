class_name SwimmingFish
extends Node2D

@export var fish_data: FishData
@export var spawn_config: SpawnConfig

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_area: Area2D = $Area2D

var velocity: Vector2 = Vector2.ZERO
var is_caught: bool = false

var school: Node = null
var school_config: SchoolConfig

var is_scattering: bool = false
var _scatter_timer: float = 0.0
var _scatter_velocity: Vector2 = Vector2.ZERO

var _sine_offset: float = 0.0
var _sine_time: float = 0.0
var _local_offset: Vector2 = Vector2.ZERO

const SINE_AMPLITUDE: float = 15.0
const SINE_PERIOD: float = 3.0
const SEPARATION_RADIUS: float = 25.0
const SEPARATION_STRENGTH: float = 30.0

signal fish_despawned(fish: SwimmingFish)


func _ready() -> void:
	_sine_offset = randf() * TAU
	rotation = 0.0
	if fish_data:
		_apply_fish_data()


func _apply_fish_data() -> void:
	if fish_data.texture and sprite:
		sprite.texture = fish_data.texture
	elif sprite and not sprite.texture:
		setup_sprite_from_atlas(fish_data)


func setup_sprite_from_atlas(data: FishData) -> void:
	if not data or not sprite:
		return
	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = preload("res://assets/sprites/fish/FishGame_Fish_Sprite_Sheet.png")
	var frame_idx: int = data.id.hash() % 256
	if frame_idx < 0:
		frame_idx = -frame_idx
	var col: int = frame_idx % 16
	var row: int = frame_idx / 16
	atlas_tex.region = Rect2(col * 16, row * 16, 16, 16)
	sprite.texture = atlas_tex


func _physics_process(delta: float) -> void:
	if is_caught:
		return

	rotation = 0.0

	if is_scattering:
		_scatter_timer -= delta
		if _scatter_timer <= 0.0:
			is_scattering = false
		position += _scatter_velocity * delta
		_update_facing()
		return

	var swim_speed: float = fish_data.swim_speed if fish_data else 50.0
	var horizontal_direction: float = 1.0 if velocity.x >= 0.0 else -1.0

	_sine_time += delta
	var sine_y: float = sin((_sine_time / SINE_PERIOD) * TAU + _sine_offset) * SINE_AMPLITUDE

	var separation: Vector2 = _calculate_separation()

	var move_delta: Vector2 = Vector2.ZERO
	move_delta.x = horizontal_direction * swim_speed * delta
	move_delta.y = (sine_y - position.y + _local_offset.y) * delta * 2.0
	move_delta += separation * delta

	position += move_delta
	velocity = move_delta / delta

	_update_facing()


func _calculate_separation() -> Vector2:
	if not school:
		return Vector2.ZERO

	var push: Vector2 = Vector2.ZERO
	for member: SwimmingFish in school.members:
		if member == self or not is_instance_valid(member) or member.is_caught:
			continue
		var diff: Vector2 = position - member.position
		var dist: float = diff.length()
		if dist < SEPARATION_RADIUS and dist > 0.0:
			push += diff.normalized() * (SEPARATION_RADIUS - dist) / SEPARATION_RADIUS * SEPARATION_STRENGTH
	return push


func _update_facing() -> void:
	if not sprite:
		return
	if velocity.x < 0.0:
		sprite.flip_h = true
	elif velocity.x > 0.0:
		sprite.flip_h = false


func scatter(away_from: Vector2) -> void:
	if not school_config:
		return
	is_scattering = true
	_scatter_timer = school_config.scatter_duration
	var away_dir: Vector2 = global_position - away_from
	if away_dir.length_squared() < 1.0:
		away_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	var scatter_speed: float = fish_data.swim_speed * school_config.scatter_speed_multiplier if fish_data else 100.0
	_scatter_velocity = away_dir.normalized() * scatter_speed


func catch_fish() -> FishData:
	if is_caught:
		return null

	is_caught = true

	if school and fish_data and fish_data.scatter_on_catch:
		school.on_member_caught(self)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

	return fish_data


func set_fish_data(data: FishData) -> void:
	fish_data = data
	if is_inside_tree():
		_apply_fish_data()
