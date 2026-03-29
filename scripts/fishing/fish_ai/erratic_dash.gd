class_name ErraticDash
extends FishFightBehavior

var dashing: bool = false
var dash_direction: float = 1.0
var dash_timer: float = 0.0
var dash_speed: float = 0.0
var pause_timer: float = 0.0
var holding: bool = false
var hold_timer: float = 0.0
var base_speed: float = 0.2


func update(delta: float, current_position: float) -> float:
	var speed: float = base_speed
	if fish_data:
		speed = fish_data.fight_speed / 640.0

	if holding:
		hold_timer -= delta
		if hold_timer <= 0.0:
			holding = false
			_start_dash(speed)
		return current_position

	if not dashing:
		pause_timer -= delta
		if pause_timer <= 0.0:
			if randf() < 0.25:
				holding = true
				hold_timer = randf_range(0.8, 1.5)
				return current_position
			_start_dash(speed)
		return current_position

	dash_timer -= delta
	if dash_timer <= 0.0:
		dashing = false
		pause_timer = randf_range(0.2, 0.6)
		return current_position

	var new_position: float = current_position + dash_direction * dash_speed * get_phase_speed_multiplier() * delta
	return clampf(new_position, 0.0, 1.0)


func _start_dash(speed: float) -> void:
	dashing = true
	dash_direction = 1.0 if randf() > 0.5 else -1.0
	dash_speed = speed * randf_range(1.5, 3.0)
	dash_timer = randf_range(0.15, 0.4)


func is_stopped() -> bool:
	return holding or (not dashing and pause_timer > 0.0)
