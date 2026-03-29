class_name DiveAndSurge
extends FishFightBehavior

enum MoveState { DIVING, PAUSING, SURGING, IDLE }

var move_state: MoveState = MoveState.IDLE
var state_timer: float = 0.0
var idle_timer: float = 2.0
var base_speed: float = 0.25


func update(delta: float, current_position: float) -> float:
	var speed: float = base_speed
	if fish_data:
		speed = fish_data.fight_speed / 640.0

	match move_state:
		MoveState.IDLE:
			idle_timer -= delta
			if idle_timer <= 0.0:
				move_state = MoveState.DIVING
				state_timer = randf_range(0.8, 1.5)
			return current_position

		MoveState.DIVING:
			state_timer -= delta
			if state_timer <= 0.0 or current_position <= 0.02:
				move_state = MoveState.PAUSING
				state_timer = randf_range(0.5, 1.0)
				return current_position
			var dive_speed: float = speed * 2.5 * get_phase_speed_multiplier()
			return clampf(current_position - dive_speed * delta, 0.0, 1.0)

		MoveState.PAUSING:
			state_timer -= delta
			if state_timer <= 0.0:
				move_state = MoveState.SURGING
				state_timer = randf_range(0.6, 1.2)
			return current_position

		MoveState.SURGING:
			state_timer -= delta
			if state_timer <= 0.0 or current_position >= 0.98:
				move_state = MoveState.IDLE
				idle_timer = randf_range(1.5, 3.0)
				return current_position
			var surge_speed: float = speed * 2.0 * get_phase_speed_multiplier()
			return clampf(current_position + surge_speed * delta, 0.0, 1.0)

	return current_position


func is_stopped() -> bool:
	return move_state == MoveState.PAUSING or move_state == MoveState.IDLE
