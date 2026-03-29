class_name FishFightBehavior
extends RefCounted

var fish_data: FishData
var current_phase: Enums.FightPhase = Enums.FightPhase.NORMAL


func update(_delta: float, _current_position: float) -> float:
	return _current_position


func is_stopped() -> bool:
	return false


func get_phase_speed_multiplier() -> float:
	match current_phase:
		Enums.FightPhase.DESPERATE:
			return 1.5
		Enums.FightPhase.FINAL_STAND:
			return 2.0
	return 1.0
