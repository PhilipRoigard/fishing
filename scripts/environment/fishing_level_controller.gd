extends Node2D

@onready var camera: Camera2D = $Camera2D

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_position: Vector2
var continuous_shake: float = 0.0
var target_camera_y: float = 0.0
var camera_follow_speed: float = 3.0
var is_reeling_in: bool = false
const SCREEN_HEIGHT: float = 640.0
const CAMERA_BOTTOM_MARGIN: float = 200.0
const CAMERA_TOP_MARGIN: float = 200.0


func _ready() -> void:
	original_position = position
	SignalBus.fight_tension_changed.connect(_on_tension_changed)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.fish_caught.connect(_on_fish_caught)
	SignalBus.bite_occurred.connect(_on_bite_occurred)
	SignalBus.hook_position_changed.connect(_on_hook_position_changed)
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)


func shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_timer = duration


func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		var offset: Vector2 = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position = original_position + offset
	elif continuous_shake > 0.0:
		var offset: Vector2 = Vector2(
			randf_range(-continuous_shake, continuous_shake),
			randf_range(-continuous_shake, continuous_shake)
		)
		position = original_position + offset
	else:
		position = original_position

	if camera:
		var current_y: float = camera.position.y
		camera.position.y = lerpf(current_y, target_camera_y, delta * camera_follow_speed)


func _on_tension_changed(tension: float) -> void:
	if tension > 70.0:
		continuous_shake = remap(tension, 70.0, 100.0, 0.5, 2.0)
	else:
		continuous_shake = 0.0


func _on_line_snapped() -> void:
	shake(8.0, 0.4)
	continuous_shake = 0.0
	reset_camera()


func _on_fish_caught(_fish_id: String) -> void:
	shake(4.0, 0.3)
	continuous_shake = 0.0
	reset_camera()


func _on_bite_occurred(_fish_id: String) -> void:
	shake(3.0, 0.2)


func _on_hook_position_changed(hook_global_pos: Vector2) -> void:
	var hook_y: float = hook_global_pos.y
	var viewport_bottom: float = camera.position.y + SCREEN_HEIGHT
	if hook_y > viewport_bottom - CAMERA_BOTTOM_MARGIN:
		target_camera_y = hook_y - SCREEN_HEIGHT + CAMERA_BOTTOM_MARGIN
	if is_reeling_in:
		var viewport_top: float = camera.position.y
		if hook_y < viewport_top + CAMERA_TOP_MARGIN:
			target_camera_y = hook_y - CAMERA_TOP_MARGIN
	target_camera_y = maxf(target_camera_y, 0.0)


func _on_fishing_state_changed(state: int) -> void:
	is_reeling_in = state == Enums.FishingState.REELING_IN


func reset_camera() -> void:
	target_camera_y = 0.0
	if camera:
		camera.position.y = target_camera_y
