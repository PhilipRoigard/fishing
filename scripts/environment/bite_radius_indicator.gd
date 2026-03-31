extends Node2D

var _pulse_time: float = 0.0
var _radius: float = 35.0
var _is_fishing: bool = false

@export var pulse_speed: float = 2.0
@export var base_alpha: float = 0.08
@export var pulse_alpha: float = 0.04
@export var ring_color: Color = Color(1.0, 1.0, 1.0)
@export var ring_width: float = 1.5


func _ready() -> void:
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	visible = false


func _on_fishing_state_changed(state: int) -> void:
	_is_fishing = state == Enums.FishingState.WAITING
	visible = _is_fishing


func _process(delta: float) -> void:
	if not _is_fishing:
		return
	_pulse_time += delta * pulse_speed
	_radius = _get_bite_radius()
	queue_redraw()


func _draw() -> void:
	var pulse: float = (sin(_pulse_time * TAU) + 1.0) * 0.5
	var alpha: float = base_alpha + pulse * pulse_alpha
	var fill_color: Color = Color(ring_color.r, ring_color.g, ring_color.b, alpha)
	draw_circle(Vector2.ZERO, _radius, fill_color)
	var outline_alpha: float = alpha * 3.0
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 48, Color(ring_color.r, ring_color.g, ring_color.b, outline_alpha), ring_width)


func _get_bite_radius() -> float:
	var base: float = 35.0
	if GameResources.config and GameResources.config.fishing_config:
		base = GameResources.config.fishing_config.base_bite_radius

	var lure_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.LURE)
	if lure_entry and GameResources.config and GameResources.config.equipment_catalogue:
		var lure_data: LureData = GameResources.config.equipment_catalogue.get_lure_by_id(lure_entry.item_id)
		if lure_data and lure_data.perk_id == "bite_radius":
			var perk_idx: int = mini(lure_entry.quality, lure_data.perk_values.size() - 1)
			base *= 1.0 + lure_data.perk_values[perk_idx] / 100.0

	return base
