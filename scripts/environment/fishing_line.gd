extends Line2D

@export var idle_color: Color = Color(0.8, 0.85, 0.9, 0.9)
@export var tension_low_color: Color = Color(0.3, 0.8, 0.3)
@export var tension_mid_color: Color = Color(0.9, 0.8, 0.2)
@export var tension_high_color: Color = Color(0.9, 0.2, 0.2)
@export var wobble_amplitude: float = 3.0
@export var wobble_frequency: float = 8.0
@export var line_segments: int = 12

var rod_tip_position: Vector2 = Vector2.ZERO
var hook_position: Vector2 = Vector2.ZERO
var current_tension: float = 0.0
var is_fighting: bool = false
var elapsed_time: float = 0.0
var line_visible: bool = false
var fisherman_ref: Node2D


func _ready() -> void:
	width = 1.5
	default_color = idle_color
	SignalBus.hook_position_changed.connect(_on_hook_position_changed)
	SignalBus.fight_tension_changed.connect(_on_fight_tension_changed)
	SignalBus.fight_started.connect(_on_fight_started)
	SignalBus.fish_caught.connect(_on_fight_ended)
	SignalBus.fish_escaped.connect(_on_fight_ended)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	visible = false
	_find_fisherman.call_deferred()


func _process(delta: float) -> void:
	if not line_visible:
		return
	elapsed_time += delta
	_update_rod_tip()
	_update_line_points()
	_update_line_color()


func _find_fisherman() -> void:
	if Main.instance:
		var fishing_level: Node = Main.instance.get_node_or_null("FishingLevel")
		if fishing_level:
			fisherman_ref = fishing_level.get_node_or_null("%Fisherman")


func _update_rod_tip() -> void:
	if fisherman_ref and fisherman_ref.has_method("get_rod_tip_position"):
		rod_tip_position = fisherman_ref.get_rod_tip_position()


func set_rod_tip(tip_pos: Vector2) -> void:
	rod_tip_position = tip_pos


func _update_line_points() -> void:
	clear_points()
	for i: int in range(line_segments + 1):
		var t: float = float(i) / float(line_segments)
		var point: Vector2 = rod_tip_position.lerp(hook_position, t)

		var sag: float = sin(t * PI) * 8.0
		point.y += sag

		if is_fighting and i > 0 and i < line_segments:
			var wobble_offset: float = sin(t * wobble_frequency + elapsed_time * 12.0) * wobble_amplitude * current_tension
			point.x += wobble_offset
		add_point(point)


func _update_line_color() -> void:
	if not is_fighting:
		default_color = idle_color
		return
	var line_color: Color
	if current_tension < 0.5:
		line_color = tension_low_color.lerp(tension_mid_color, current_tension * 2.0)
	else:
		line_color = tension_mid_color.lerp(tension_high_color, (current_tension - 0.5) * 2.0)
	default_color = line_color


func _on_hook_position_changed(pos: Vector2) -> void:
	hook_position = pos


func _on_fight_tension_changed(tension: float) -> void:
	current_tension = clampf(tension / 100.0, 0.0, 1.0)


func _on_fight_started(_fish_id: String) -> void:
	is_fighting = true


func _on_fight_ended(_fish_id: String) -> void:
	is_fighting = false
	current_tension = 0.0


func _on_line_snapped() -> void:
	is_fighting = false
	current_tension = 0.0
	line_visible = false
	visible = false


func _on_fishing_state_changed(state: Enums.FishingState) -> void:
	match state:
		Enums.FishingState.CASTING:
			line_visible = false
			visible = false
		Enums.FishingState.WAITING, Enums.FishingState.BITE_ALERT, Enums.FishingState.FIGHTING:
			line_visible = true
			visible = true
		Enums.FishingState.IDLE, Enums.FishingState.SUCCESS, Enums.FishingState.FAIL:
			line_visible = false
			visible = false
			is_fighting = false
			current_tension = 0.0
