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
var _base_y: float = 0.0
var _swim_direction: float = 1.0
var _speed_variation: float = 1.0

var _is_curious: bool = false
var _curiosity_target: Vector2 = Vector2.ZERO
var _curiosity_timer: float = 0.0
var _nibble_timer: float = 0.0

var _direction_change_timer: float = 0.0
var _direction_change_interval: float = 0.0
var _vertical_wander_target: float = 0.0
var _vertical_wander_timer: float = 0.0

const SINE_AMPLITUDE: float = 8.0
const SINE_PERIOD: float = 2.5
const SEPARATION_RADIUS: float = 25.0
const SEPARATION_STRENGTH: float = 30.0
const CURIOSITY_RANGE: float = 180.0
const CURIOSITY_SPEED_MULT: float = 0.8
const CURIOSITY_CHANCE: float = 0.08
const NIBBLE_DISTANCE: float = 20.0

signal fish_despawned(fish: SwimmingFish)


func _ready() -> void:
	_sine_offset = randf() * TAU
	_base_y = position.y
	rotation = 0.0
	_speed_variation = randf_range(0.8, 1.2)
	_direction_change_interval = randf_range(3.0, 8.0)
	_direction_change_timer = _direction_change_interval
	_vertical_wander_target = _base_y
	_vertical_wander_timer = randf_range(2.0, 5.0)
	if velocity.x < 0.0:
		_swim_direction = -1.0
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
	var frame_idx: int = abs(data.id.hash()) % 256
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
			_is_curious = false
		position += _scatter_velocity * delta
		_update_facing()
		return

	var swim_speed: float = (fish_data.swim_speed if fish_data else 50.0) * _speed_variation

	_sine_time += delta
	_direction_change_timer -= delta
	_vertical_wander_timer -= delta

	if _direction_change_timer <= 0.0:
		_direction_change_timer = randf_range(3.0, 8.0)
		if randf() < 0.15:
			_swim_direction = -_swim_direction

	if _vertical_wander_timer <= 0.0:
		_vertical_wander_timer = randf_range(2.0, 5.0)
		_vertical_wander_target = _base_y + randf_range(-30.0, 30.0)

	_check_curiosity(delta)

	var move_delta: Vector2 = Vector2.ZERO

	if _is_curious:
		var to_target: Vector2 = _curiosity_target - global_position
		var dist: float = to_target.length()

		if dist < NIBBLE_DISTANCE:
			_nibble_timer -= delta
			if _nibble_timer <= 0.0:
				_nibble_timer = randf_range(0.5, 1.5)
				move_delta = Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)) * delta
		else:
			var approach_speed: float = swim_speed * CURIOSITY_SPEED_MULT
			move_delta = to_target.normalized() * approach_speed * delta

		_curiosity_timer -= delta
		if _curiosity_timer <= 0.0:
			_is_curious = false
	else:
		var sine_y: float = sin((_sine_time / SINE_PERIOD) * TAU + _sine_offset) * SINE_AMPLITUDE
		var target_y: float = lerpf(position.y, _vertical_wander_target + sine_y, delta * 1.5)
		move_delta.x = _swim_direction * swim_speed * delta
		move_delta.y = (target_y - position.y)

	var separation: Vector2 = _calculate_separation()
	move_delta += separation * delta

	position += move_delta
	velocity = move_delta / maxf(delta, 0.001)

	_update_facing()


func _check_curiosity(delta: float) -> void:
	if _is_curious:
		return

	var hook: Node2D = _find_hook()
	if not hook:
		return

	var dist: float = global_position.distance_to(hook.global_position)
	if dist > CURIOSITY_RANGE:
		return

	if randf() < CURIOSITY_CHANCE * delta:
		_is_curious = true
		_curiosity_target = hook.global_position + Vector2(randf_range(-15.0, 15.0), randf_range(-15.0, 15.0))
		_curiosity_timer = randf_range(3.0, 8.0)
		_nibble_timer = randf_range(0.5, 1.5)


func _find_hook() -> Node2D:
	if Main.instance:
		var hook: Node = Main.instance.get_node_or_null("FishingLevel/HookLayer/Hook")
		if hook is Node2D:
			return hook as Node2D
	return null


func _calculate_separation() -> Vector2:
	if not school:
		return Vector2.ZERO

	var push: Vector2 = Vector2.ZERO
	for child: Node in school.get_children():
		if child == self or not (child is SwimmingFish):
			continue
		var member: SwimmingFish = child as SwimmingFish
		if not is_instance_valid(member) or member.is_caught:
			continue
		var diff: Vector2 = position - member.position
		var dist: float = diff.length()
		if dist < SEPARATION_RADIUS and dist > 0.0:
			push += diff.normalized() * (SEPARATION_RADIUS - dist) / SEPARATION_RADIUS * SEPARATION_STRENGTH
	return push


func _update_facing() -> void:
	if not sprite:
		return
	if velocity.x < -1.0:
		sprite.flip_h = true
	elif velocity.x > 1.0:
		sprite.flip_h = false


func scatter(away_from: Vector2) -> void:
	if not school_config:
		return
	is_scattering = true
	_is_curious = false
	_scatter_timer = school_config.scatter_duration
	var away_dir: Vector2 = global_position - away_from
	if away_dir.length_squared() < 1.0:
		away_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	var scatter_speed: float = (fish_data.swim_speed if fish_data else 100.0) * school_config.scatter_speed_multiplier
	_scatter_velocity = away_dir.normalized() * scatter_speed


func catch_fish() -> FishData:
	if is_caught:
		return null

	is_caught = true
	_is_curious = false

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
