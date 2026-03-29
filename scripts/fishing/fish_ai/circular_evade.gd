class_name CircularEvade
extends FishFightBehavior

var elapsed_time: float = 0.0
var base_amplitude: float = 0.15
var frequency: float = 1.8
var base_speed: float = 0.12
var center_offset: float = 0.5


func update(delta: float, _current_position: float) -> float:
	elapsed_time += delta

	var phase_amp_scale: float = 1.0
	match current_phase:
		Enums.FightPhase.DESPERATE:
			phase_amp_scale = 1.4
		Enums.FightPhase.FINAL_STAND:
			phase_amp_scale = 1.8

	var amplitude: float = base_amplitude * phase_amp_scale
	var drift_speed: float = base_speed * get_phase_speed_multiplier()

	if fish_data:
		amplitude *= (0.8 + fish_data.fight_erratic * 0.5)
		drift_speed = fish_data.fight_speed / 640.0 * 0.6

	center_offset += sin(elapsed_time * 0.3) * drift_speed * delta
	center_offset = clampf(center_offset, 0.2, 0.8)

	var sine_value: float = sin(elapsed_time * frequency * TAU) * amplitude
	var new_position: float = center_offset + sine_value

	return clampf(new_position, 0.0, 1.0)


func is_stopped() -> bool:
	return false
