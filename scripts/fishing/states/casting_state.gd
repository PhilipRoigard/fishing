extends BaseState

var cast_strength: float = 0.0
var is_charging: bool = false
var fishing_config: FishingConfig
var hook_node: Area2D
var rod_tip_position: Vector2 = Vector2(180, 70)
var is_dropping_hook: bool = false

const HOOK_DROP_DURATION: float = 0.5
const OCEAN_START_Y: float = 90.0


func enter(_meta: Dictionary = {}) -> void:
	cast_strength = 0.0
	is_charging = true
	is_dropping_hook = false
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


func update(delta: float) -> void:
	if is_charging and fishing_config:
		cast_strength = minf(cast_strength + delta / fishing_config.charge_duration, 1.0)
		SignalBus.cast_strength_changed.emit(cast_strength)


func _on_cast_input_ended() -> void:
	if not is_charging or is_dropping_hook:
		return
	is_charging = false

	if not fishing_config:
		return

	var depth: float = fishing_config.min_cast_depth + cast_strength * (fishing_config.max_cast_depth_base - fishing_config.min_cast_depth)
	SignalBus.cast_started.emit(cast_strength)
	SignalBus.cast_landed.emit(depth)

	_animate_hook_drop(depth)


func _animate_hook_drop(depth: float) -> void:
	is_dropping_hook = true

	if not hook_node:
		state_machine.change_state(&"waiting", {"depth": depth})
		return

	var target_y: float = OCEAN_START_Y + depth * 0.5
	var start_pos: Vector2 = Vector2(rod_tip_position.x, rod_tip_position.y)
	var end_pos: Vector2 = Vector2(hook_node.position.x, target_y)

	hook_node.position = start_pos
	SignalBus.hook_position_changed.emit(hook_node.global_position)

	var tween: Tween = hook_node.create_tween()
	tween.tween_property(hook_node, "position", end_pos, HOOK_DROP_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		SignalBus.hook_position_changed.emit(hook_node.global_position)
		state_machine.change_state(&"waiting", {"depth": depth})
	)

	var update_tween: Tween = hook_node.create_tween()
	update_tween.tween_method(func(t: float) -> void:
		SignalBus.hook_position_changed.emit(hook_node.global_position)
	, 0.0, 1.0, HOOK_DROP_DURATION)


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
