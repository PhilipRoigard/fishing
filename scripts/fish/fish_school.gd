class_name FishSchool
extends Node2D

var fish_data: FishData
var school_config: SchoolConfig
var members: Array[SwimmingFish] = []

var _path: PackedVector2Array = PackedVector2Array()
var _current_waypoint_index: int = 0

var _offscreen_timer: float = 0.0
var _camera: Camera2D = null
var _viewport_size: Vector2 = Vector2.ZERO

signal school_empty
signal school_despawn


func setup(p_fish_data: FishData, p_school_config: SchoolConfig, p_path: PackedVector2Array) -> void:
	fish_data = p_fish_data
	school_config = p_school_config
	_path = p_path
	_current_waypoint_index = 0
	_offscreen_timer = 0.0

	if _path.size() > 0:
		global_position = _path[0]


func _ready() -> void:
	_viewport_size = get_viewport_rect().size
	_camera = _find_camera()


func _find_camera() -> Camera2D:
	var cameras: Array[Node] = get_tree().get_nodes_in_group("fishing_camera")
	if cameras.size() > 0:
		return cameras[0] as Camera2D
	return null


func _process(delta: float) -> void:
	if members.is_empty():
		return

	_advance_path(delta)
	_update_offscreen_timer(delta)


func _advance_path(_delta: float) -> void:
	if _path.is_empty() or _current_waypoint_index >= _path.size():
		return

	var target: Vector2 = _path[_current_waypoint_index]
	var direction: Vector2 = target - global_position
	var distance: float = direction.length()

	var speed: float = fish_data.swim_speed if fish_data else 50.0
	if distance > school_config.waypoint_reach_distance:
		global_position += direction.normalized() * speed * _delta
	else:
		_current_waypoint_index += 1
		if _current_waypoint_index >= _path.size():
			school_despawn.emit()


func get_current_target() -> Vector2:
	return global_position


func _update_offscreen_timer(delta: float) -> void:
	if _is_any_member_onscreen():
		_offscreen_timer = 0.0
	else:
		_offscreen_timer += delta
		if _offscreen_timer >= school_config.offscreen_despawn_time:
			school_despawn.emit()


func _is_any_member_onscreen() -> bool:
	var camera_rect: Rect2 = _get_camera_rect()
	if camera_rect.size == Vector2.ZERO:
		return true

	for member: SwimmingFish in members:
		if is_instance_valid(member) and not member.is_caught:
			if camera_rect.has_point(member.global_position):
				return true
	return false


func _get_camera_rect() -> Rect2:
	if not _camera:
		_camera = _find_camera()
	if not _camera:
		return Rect2()

	var cam_pos: Vector2 = _camera.global_position
	var zoom: Vector2 = _camera.zoom
	var half_size: Vector2 = _viewport_size / (2.0 * zoom)
	return Rect2(cam_pos - half_size, half_size * 2.0)


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
