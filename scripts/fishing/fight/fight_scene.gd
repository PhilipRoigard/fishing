extends Control

@onready var fish_sprite: Sprite2D = %FishSprite
@onready var line_visual: Line2D = %LineVisual
@onready var tension_bar: ProgressBar = %TensionBar
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var phase_label: Label = %PhaseLabel
@onready var sub_viewport: SubViewport = %FightViewport

var current_fish_position: float = 0.5
var current_tension: float = 0.0
var current_progress: float = 30.0
var viewport_height: float = 480.0
var fish_target_y: float = 240.0


func _ready() -> void:
	SignalBus.fight_started.connect(_on_fight_started)
	SignalBus.fight_progress_changed.connect(_on_progress_changed)
	SignalBus.fight_tension_changed.connect(_on_tension_changed)
	SignalBus.fight_phase_changed.connect(_on_phase_changed)
	SignalBus.fish_caught.connect(_on_fight_ended)
	SignalBus.fish_escaped.connect(_on_fight_ended)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.consumable_effect_started.connect(_on_effect_started)
	SignalBus.consumable_effect_ended.connect(_on_effect_ended)
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_update_fish_visual(delta)
	_update_line_visual()


func _on_fight_started(fish_id: String) -> void:
	visible = true
	current_fish_position = 0.5
	current_tension = 0.0
	current_progress = 30.0

	if phase_label:
		phase_label.text = ""

	if fish_sprite and Main.instance and Main.instance.database_system:
		var fish: FishData = Main.instance.database_system.get_fish_by_id(fish_id)
		if fish and fish.texture:
			fish_sprite.texture = fish.texture

	if sub_viewport:
		viewport_height = sub_viewport.size.y


func _on_progress_changed(progress: float) -> void:
	current_progress = progress
	if progress_bar:
		progress_bar.value = progress


func _on_tension_changed(tension: float) -> void:
	current_tension = tension
	if tension_bar:
		tension_bar.value = tension
		_update_tension_color()


func _on_phase_changed(phase: Enums.FightPhase) -> void:
	if not phase_label:
		return

	match phase:
		Enums.FightPhase.DESPERATE:
			phase_label.text = "DESPERATE"
			_play_phase_flash()
		Enums.FightPhase.FINAL_STAND:
			phase_label.text = "FINAL STAND"
			_play_phase_flash()


func _on_fight_ended(_fish_id: String) -> void:
	visible = false


func _on_line_snapped() -> void:
	visible = false


func _on_effect_started(effect: Enums.ConsumableEffect) -> void:
	if effect == Enums.ConsumableEffect.STUN and fish_sprite:
		var tween: Tween = create_tween()
		tween.tween_property(fish_sprite, "modulate", Color(0.5, 0.5, 1.0), 0.2)


func _on_effect_ended(effect: Enums.ConsumableEffect) -> void:
	if effect == Enums.ConsumableEffect.STUN and fish_sprite:
		var tween: Tween = create_tween()
		tween.tween_property(fish_sprite, "modulate", Color.WHITE, 0.3)


func set_fish_position(normalized_position: float) -> void:
	current_fish_position = normalized_position


func _update_fish_visual(delta: float) -> void:
	if not fish_sprite:
		return

	var target_y: float = (1.0 - current_fish_position) * viewport_height
	fish_target_y = lerpf(fish_target_y, target_y, delta * 8.0)
	fish_sprite.position.y = fish_target_y


func _update_line_visual() -> void:
	if not line_visual:
		return

	var hook_pos: Vector2 = Vector2(fish_sprite.position.x, 0.0) if fish_sprite else Vector2.ZERO
	var fish_pos: Vector2 = Vector2(fish_sprite.position.x, fish_target_y) if fish_sprite else Vector2.ZERO

	line_visual.clear_points()
	line_visual.add_point(hook_pos)

	var tension_normalized: float = current_tension / 100.0
	if tension_normalized > 0.3:
		var wobble: float = sin(Time.get_ticks_msec() * 0.02) * tension_normalized * 5.0
		var mid_point: Vector2 = (hook_pos + fish_pos) * 0.5 + Vector2(wobble, 0.0)
		line_visual.add_point(mid_point)

	line_visual.add_point(fish_pos)


func _update_tension_color() -> void:
	if not tension_bar:
		return

	var ratio: float = current_tension / 100.0
	if ratio > 0.8:
		tension_bar.modulate = Color(1.0, 0.2, 0.2)
	elif ratio > 0.5:
		tension_bar.modulate = Color(1.0, 0.8, 0.2)
	else:
		tension_bar.modulate = Color.WHITE


func _play_phase_flash() -> void:
	if not phase_label:
		return
	phase_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(phase_label, "modulate:a", 0.0, 1.5)
