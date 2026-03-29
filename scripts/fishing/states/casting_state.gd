extends BaseState

const SplashEffectScript: GDScript = preload("res://scripts/environment/splash_effect.gd")

var cast_strength: float = 0.0
var is_charging: bool = false
var fishing_config: FishingConfig
var hook_node: Area2D
var rod_tip_position: Vector2 = Vector2(180, 70)
var is_dropping_hook: bool = false
var arc_elapsed: float = 0.0
var arc_duration: float = 0.7
var arc_start: Vector2 = Vector2.ZERO
var arc_end: Vector2 = Vector2.ZERO
var arc_active: bool = false
var pending_depth: float = 0.0

const OCEAN_START_Y: float = 90.0
const ARC_HEIGHT: float = -60.0
const ARC_HORIZONTAL_RANGE: float = 40.0


func enter(_meta: Dictionary = {}) -> void:
	cast_strength = 0.0
	is_charging = true
	is_dropping_hook = false
	arc_active = false
	if GameResources.config:
		fishing_config = GameResources.config.fishing_config

	_find_hook_node()
	_find_rod_tip()

	SignalBus.fishing_state_changed.emit(Enums.FishingState.CASTING)
	SignalBus.cast_strength_changed.emit(0.0)
	SignalBus.cast_input_ended.connect(_on_cast_input_ended)


func exit() -> void:
	if SignalBus.cast_input_ended.is_connected(_on_cast_input_ended):
		SignalBus.cast_input_ended.disconnect(_on_cast_input_ended)
	arc_active = false


func update(delta: float) -> void:
	if is_charging and fishing_config:
		cast_strength = minf(cast_strength + delta / fishing_config.charge_duration, 1.0)
		SignalBus.cast_strength_changed.emit(cast_strength)

	if arc_active and hook_node:
		arc_elapsed += delta
		var t: float = minf(arc_elapsed / arc_duration, 1.0)

		var pos: Vector2 = _evaluate_arc(t)
		hook_node.position = pos
		SignalBus.hook_position_changed.emit(hook_node.global_position)

		if t >= 1.0:
			arc_active = false
			_spawn_landing_splash()
			state_machine.change_state(&"waiting", {"depth": pending_depth})


func _on_cast_input_ended() -> void:
	if not is_charging or is_dropping_hook:
		return
	is_charging = false

	if not fishing_config:
		return

	var depth: float = fishing_config.min_cast_depth + cast_strength * (fishing_config.max_cast_depth_base - fishing_config.min_cast_depth)
	SignalBus.cast_started.emit(cast_strength)
	SignalBus.cast_landed.emit(depth)

	_animate_hook_arc(depth)


func _animate_hook_arc(depth: float) -> void:
	is_dropping_hook = true
	pending_depth = depth

	if not hook_node:
		state_machine.change_state(&"waiting", {"depth": depth})
		return

	var target_y: float = OCEAN_START_Y + depth * 0.5
	arc_start = Vector2(rod_tip_position.x, rod_tip_position.y)
	arc_end = Vector2(rod_tip_position.x + ARC_HORIZONTAL_RANGE * cast_strength, target_y)

	hook_node.position = arc_start
	SignalBus.hook_position_changed.emit(hook_node.global_position)

	arc_duration = lerpf(0.6, 0.8, cast_strength)
	arc_elapsed = 0.0
	arc_active = true


func _evaluate_arc(t: float) -> Vector2:
	var ease_t: float = t * t * (3.0 - 2.0 * t)
	var linear_pos: Vector2 = arc_start.lerp(arc_end, ease_t)
	var arc_offset: float = ARC_HEIGHT * sin(t * PI) * cast_strength
	return Vector2(linear_pos.x, linear_pos.y + arc_offset)


func _spawn_landing_splash() -> void:
	if not hook_node:
		return
	var fishing_level: Node = _get_fishing_level()
	if not fishing_level:
		return
	var splash: Node2D = Node2D.new()
	splash.set_script(SplashEffectScript)
	splash.position = hook_node.global_position
	fishing_level.add_child(splash)


func _find_hook_node() -> void:
	var fishing_level: Node = _get_fishing_level()
	if fishing_level:
		hook_node = fishing_level.get_node_or_null("%Hook")


func _find_rod_tip() -> void:
	var fishing_level: Node = _get_fishing_level()
	if fishing_level:
		var fisherman: Node2D = fishing_level.get_node_or_null("%Fisherman")
		if fisherman and fisherman.has_method("get_rod_tip_position"):
			rod_tip_position = fisherman.get_rod_tip_position()


func _get_fishing_level() -> Node:
	if Main.instance:
		return Main.instance.get_node_or_null("FishingLevel")
	return null
