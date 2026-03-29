extends Node2D

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_position: Vector2
var continuous_shake: float = 0.0


func _ready() -> void:
	original_position = position
	SignalBus.fight_tension_changed.connect(_on_tension_changed)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.fish_caught.connect(_on_fish_caught)
	SignalBus.bite_occurred.connect(_on_bite_occurred)


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


func _on_tension_changed(tension: float) -> void:
	if tension > 70.0:
		continuous_shake = remap(tension, 70.0, 100.0, 0.5, 2.0)
	else:
		continuous_shake = 0.0


func _on_line_snapped() -> void:
	shake(8.0, 0.4)
	continuous_shake = 0.0


func _on_fish_caught(_fish_id: String) -> void:
	shake(4.0, 0.3)
	continuous_shake = 0.0


func _on_bite_occurred(_fish_id: String) -> void:
	shake(3.0, 0.2)
