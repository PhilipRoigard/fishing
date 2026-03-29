class_name LinearOscillation
extends FishFightBehavior

var direction: float = 1.0
var change_timer: float = 0.0
var change_interval: float = 1.2
var stopped: bool = false
var stop_timer: float = 0.0
var stop_cooldown: float = 0.0
var base_speed: float = 0.15


func update(delta: float, current_position: float) -> float:
	var speed: float = base_speed
	if fish_data:
		speed = fish_data.fight_speed / 640.0

	if stopped:
		stop_timer -= delta
		if stop_timer <= 0.0:
			stopped = false
			stop_cooldown = randf_range(1.0, 3.0)
		return current_position

	change_timer -= delta
	if change_timer <= 0.0:
		direction = -direction
		change_timer = change_interval * randf_range(0.8, 1.2)

		stop_cooldown -= change_interval
		if stop_cooldown <= 0.0 and randf() < 0.4:
			stopped = true
			stop_timer = randf_range(0.3, 0.8)
			return current_position

	var new_position: float = current_position + direction * speed * get_phase_speed_multiplier() * delta
	return clampf(new_position, 0.0, 1.0)


func is_stopped() -> bool:
	return stopped
