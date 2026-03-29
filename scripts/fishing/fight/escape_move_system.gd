class_name EscapeMoveSystem
extends RefCounted

signal line_jerk_triggered
signal deep_dive_triggered
signal surface_breach_triggered

enum EscapeMove { LINE_JERK, DEEP_DIVE, SURFACE_BREACH }

class EscapeMoveCooldown:
	var move_type: EscapeMove
	var cooldown_remaining: float = 0.0

var available_moves: Array[EscapeMoveCooldown] = []
var fish_rarity: Enums.Rarity = Enums.Rarity.COMMON
var tension_ref: float = 0.0
var fish_position_ref: float = 0.5
var active_breach: bool = false
var breach_drop_timer: float = 0.0


func setup(rarity: Enums.Rarity) -> void:
	fish_rarity = rarity
	available_moves.clear()

	if rarity == Enums.Rarity.RARE or rarity == Enums.Rarity.LEGENDARY:
		_add_move(EscapeMove.LINE_JERK)
		_add_move(EscapeMove.DEEP_DIVE)

	if rarity == Enums.Rarity.LEGENDARY:
		_add_move(EscapeMove.SURFACE_BREACH)


func update(delta: float, current_tension: float, current_fish_position: float) -> Dictionary:
	tension_ref = current_tension
	fish_position_ref = current_fish_position
	var result: Dictionary = {"tension_delta": 0.0, "fish_position": current_fish_position}

	for move_cooldown: EscapeMoveCooldown in available_moves:
		if move_cooldown.cooldown_remaining > 0.0:
			move_cooldown.cooldown_remaining -= delta

	if active_breach:
		breach_drop_timer -= delta
		if breach_drop_timer <= 0.0:
			active_breach = false
			result["fish_position"] = randf_range(0.2, 0.7)
		else:
			result["fish_position"] = 1.0
		return result

	var triggered_move: EscapeMoveCooldown = _try_trigger_move()
	if triggered_move:
		match triggered_move.move_type:
			EscapeMove.LINE_JERK:
				result["tension_delta"] = 30.0
				line_jerk_triggered.emit()
			EscapeMove.DEEP_DIVE:
				result["fish_position"] = 0.0
				deep_dive_triggered.emit()
			EscapeMove.SURFACE_BREACH:
				active_breach = true
				breach_drop_timer = randf_range(0.4, 0.8)
				result["fish_position"] = 1.0
				surface_breach_triggered.emit()

	return result


func _add_move(move_type: EscapeMove) -> void:
	var cooldown: EscapeMoveCooldown = EscapeMoveCooldown.new()
	cooldown.move_type = move_type
	cooldown.cooldown_remaining = randf_range(5.0, 8.0)
	available_moves.append(cooldown)


func _try_trigger_move() -> EscapeMoveCooldown:
	var ready_moves: Array[EscapeMoveCooldown] = []
	for move_cooldown: EscapeMoveCooldown in available_moves:
		if move_cooldown.cooldown_remaining <= 0.0:
			ready_moves.append(move_cooldown)

	if ready_moves.is_empty():
		return null

	var trigger_chance: float = 0.02
	if randf() > trigger_chance:
		return null

	var chosen: EscapeMoveCooldown = ready_moves[randi() % ready_moves.size()]
	chosen.cooldown_remaining = randf_range(10.0, 15.0)
	return chosen
