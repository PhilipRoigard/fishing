class_name FishSchool
extends Node2D

var fish_data: FishData
var school_config: SchoolConfig
var members: Array[SwimmingFish] = []

var _path: PackedVector2Array = PackedVector2Array()
var _current_waypoint_index: int = 0
var _wander_offset: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0
var _lifetime: float = 0.0

const MAX_LIFETIME: float = 30.0
const SCREEN_MARGIN: float = 60.0

signal school_empty
signal school_despawn


func setup(p_fish_data: FishData, p_school_config: SchoolConfig, p_path: PackedVector2Array) -> void:
	fish_data = p_fish_data
	school_config = p_school_config
	_path = p_path
	_current_waypoint_index = 0
	_wander_timer = randf_range(2.0, 5.0)
	_lifetime = 0.0

	if _path.size() > 0:
		global_position = _path[0]


func _process(delta: float) -> void:
	if members.is_empty():
		return

	_lifetime += delta
	_advance_path(delta)
	_update_wander(delta)

	if _is_fully_offscreen():
		school_despawn.emit()


func _advance_path(delta: float) -> void:
	if _path.is_empty() or _current_waypoint_index >= _path.size():
		return
	if _has_curious_members():
		return

	var target: Vector2 = _path[_current_waypoint_index] + _wander_offset
	var direction: Vector2 = target - global_position
	var distance: float = direction.length()

	var speed: float = fish_data.swim_speed if fish_data else 50.0
	var reach_dist: float = school_config.waypoint_reach_distance if school_config else 24.0

	if distance > reach_dist:
		global_position += direction.normalized() * speed * delta
	else:
		_current_waypoint_index += 1
		if _current_waypoint_index >= _path.size():
			if _has_curious_members():
				_current_waypoint_index = _path.size() - 1
			else:
				school_despawn.emit()


func _update_wander(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_wander_timer = randf_range(3.0, 6.0)
		_wander_offset = Vector2(randf_range(-40.0, 40.0), randf_range(-30.0, 30.0))


func _is_fully_offscreen() -> bool:
	var viewport: Viewport = get_viewport()
	if not viewport:
		return false
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	var view_top: float = -canvas_transform.origin.y - SCREEN_MARGIN
	var view_bottom: float = view_top + viewport.get_visible_rect().size.y + SCREEN_MARGIN * 2.0
	for member: SwimmingFish in members:
		if is_instance_valid(member) and not member.is_caught:
			if member._is_curious:
				return false
			var gp: Vector2 = member.global_position
			if gp.x > -SCREEN_MARGIN and gp.x < 360 + SCREEN_MARGIN and gp.y > view_top and gp.y < view_bottom:
				return false
	return true


func add_member(fish: SwimmingFish) -> void:
	members.append(fish)
	fish.school = self
	fish.school_config = school_config
	fish.tree_exited.connect(_on_member_exited.bind(fish))


func _on_member_exited(fish: SwimmingFish) -> void:
	members.erase(fish)
	if members.is_empty():
		school_empty.emit()


func on_member_caught(caught_fish: SwimmingFish) -> void:
	var catch_pos: Vector2 = caught_fish.global_position

	for member: SwimmingFish in members:
		if member == caught_fish or not is_instance_valid(member) or member.is_caught:
			continue
		member.scatter(catch_pos)

	if fish_data:
		SignalBus.school_member_caught.emit(fish_data, get_member_count())
		SignalBus.school_scattered.emit(catch_pos)


func _has_curious_members() -> bool:
	for member: SwimmingFish in members:
		if is_instance_valid(member) and not member.is_caught and member._is_curious:
			return true
	return false


func get_member_count() -> int:
	var count: int = 0
	for member: SwimmingFish in members:
		if is_instance_valid(member) and not member.is_caught:
			count += 1
	return count


func cleanup() -> void:
	for member: SwimmingFish in members:
		if is_instance_valid(member):
			member.queue_free()
	members.clear()
	queue_free()
