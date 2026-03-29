class_name ActiveEffectManager
extends RefCounted

signal effect_started(effect: Enums.ConsumableEffect)
signal effect_ended(effect: Enums.ConsumableEffect)

class ActiveEffect:
	var effect_type: Enums.ConsumableEffect
	var remaining_duration: float
	var magnitude: float

var active_effects: Array[ActiveEffect] = []


func apply_effect(effect_type: Enums.ConsumableEffect, duration: float, magnitude: float = 1.0) -> void:
	if effect_type == Enums.ConsumableEffect.STUN:
		_remove_effects_of_type(Enums.ConsumableEffect.STUN)

	var new_effect: ActiveEffect = ActiveEffect.new()
	new_effect.effect_type = effect_type
	new_effect.remaining_duration = duration
	new_effect.magnitude = magnitude
	active_effects.append(new_effect)
	effect_started.emit(effect_type)


func update(delta: float) -> void:
	var expired: Array[ActiveEffect] = []
	for eff: ActiveEffect in active_effects:
		eff.remaining_duration -= delta
		if eff.remaining_duration <= 0.0:
			expired.append(eff)

	for eff: ActiveEffect in expired:
		var eff_type: Enums.ConsumableEffect = eff.effect_type
		active_effects.erase(eff)
		if not _has_effect(eff_type):
			effect_ended.emit(eff_type)


func is_stunned() -> bool:
	return _has_effect(Enums.ConsumableEffect.STUN)


func get_decay_multiplier() -> float:
	return _get_multiplicative_value(Enums.ConsumableEffect.REDUCE_DECAY)


func get_gain_multiplier() -> float:
	return _get_multiplicative_value(Enums.ConsumableEffect.INCREASE_PROGRESS_GAIN)


func get_tension_cap_multiplier() -> float:
	return _get_multiplicative_value(Enums.ConsumableEffect.INCREASE_TENSION_CAP)


func clear_all() -> void:
	var types_to_notify: Array[Enums.ConsumableEffect] = []
	for eff: ActiveEffect in active_effects:
		if not types_to_notify.has(eff.effect_type):
			types_to_notify.append(eff.effect_type)
	active_effects.clear()
	for eff_type: Enums.ConsumableEffect in types_to_notify:
		effect_ended.emit(eff_type)


func get_active_effect_types() -> Array[Enums.ConsumableEffect]:
	var types: Array[Enums.ConsumableEffect] = []
	for eff: ActiveEffect in active_effects:
		if not types.has(eff.effect_type):
			types.append(eff.effect_type)
	return types


func _has_effect(effect_type: Enums.ConsumableEffect) -> bool:
	for eff: ActiveEffect in active_effects:
		if eff.effect_type == effect_type and eff.remaining_duration > 0.0:
			return true
	return false


func _get_multiplicative_value(effect_type: Enums.ConsumableEffect) -> float:
	var result: float = 1.0
	for eff: ActiveEffect in active_effects:
		if eff.effect_type == effect_type and eff.remaining_duration > 0.0:
			result *= eff.magnitude
	return result


func _remove_effects_of_type(effect_type: Enums.ConsumableEffect) -> void:
	var to_remove: Array[ActiveEffect] = []
	for eff: ActiveEffect in active_effects:
		if eff.effect_type == effect_type:
			to_remove.append(eff)
	for eff: ActiveEffect in to_remove:
		active_effects.erase(eff)
