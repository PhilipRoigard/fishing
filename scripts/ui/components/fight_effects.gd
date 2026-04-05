extends Control

const StunShader: Shader = preload("res://shaders/stun_freeze.gdshader")
const EnergyBurstShader: Shader = preload("res://shaders/energy_burst.gdshader")
const AnchorPulseShader: Shader = preload("res://shaders/depth_anchor_pulse.gdshader")

var screen_overlay: ColorRect
var stun_overlay: ColorRect
var anchor_overlay: ColorRect
var burst_overlay: ColorRect
var effect_label: Label
var active_tweens: Array[Tween] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

	screen_overlay = ColorRect.new()
	screen_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	screen_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_overlay)

	stun_overlay = ColorRect.new()
	stun_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	stun_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stun_overlay.material = ShaderMaterial.new()
	stun_overlay.material.shader = StunShader
	stun_overlay.material.set_shader_parameter("intensity", 0.0)
	stun_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	stun_overlay.visible = false
	add_child(stun_overlay)

	anchor_overlay = ColorRect.new()
	anchor_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	anchor_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_overlay.material = ShaderMaterial.new()
	anchor_overlay.material.shader = AnchorPulseShader
	anchor_overlay.material.set_shader_parameter("intensity", 0.0)
	anchor_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	anchor_overlay.visible = false
	add_child(anchor_overlay)

	burst_overlay = ColorRect.new()
	burst_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	burst_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burst_overlay.material = ShaderMaterial.new()
	burst_overlay.material.shader = EnergyBurstShader
	burst_overlay.material.set_shader_parameter("intensity", 0.0)
	burst_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	burst_overlay.visible = false
	add_child(burst_overlay)

	effect_label = Label.new()
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.set_anchors_preset(Control.PRESET_CENTER)
	effect_label.offset_left = -150
	effect_label.offset_right = 150
	effect_label.offset_top = -30
	effect_label.offset_bottom = 30
	effect_label.add_theme_font_size_override("font_size", 28)
	effect_label.visible = false
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(effect_label)

	SignalBus.consumable_effect_started.connect(_on_effect_started)
	SignalBus.consumable_effect_ended.connect(_on_effect_ended)


func _exit_tree() -> void:
	if SignalBus.consumable_effect_started.is_connected(_on_effect_started):
		SignalBus.consumable_effect_started.disconnect(_on_effect_started)
	if SignalBus.consumable_effect_ended.is_connected(_on_effect_ended):
		SignalBus.consumable_effect_ended.disconnect(_on_effect_ended)
	_kill_tweens()


func _kill_tweens() -> void:
	for tw: Tween in active_tweens:
		if tw and tw.is_valid():
			tw.kill()
	active_tweens.clear()


func _on_effect_started(effect: int) -> void:
	match effect:
		Enums.ConsumableEffect.STUN:
			_play_stun_effect()
		Enums.ConsumableEffect.RESTRICT_RANGE:
			_play_anchor_effect()
		Enums.ConsumableEffect.LINE_SURGE:
			_play_surge_effect()
		Enums.ConsumableEffect.SLACK_RELEASE:
			_play_slack_effect()
		Enums.ConsumableEffect.WIDEN_BRACKET:
			_play_widen_effect()


func _on_effect_ended(effect: int) -> void:
	match effect:
		Enums.ConsumableEffect.STUN:
			_end_stun_effect()
		Enums.ConsumableEffect.RESTRICT_RANGE:
			_end_anchor_effect()
		Enums.ConsumableEffect.WIDEN_BRACKET:
			_end_widen_effect()


func _play_stun_effect() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("STUNNED!", Color(0.4, 0.8, 1.0))
	_flash_screen(Color(0.3, 0.6, 1.0, 0.4), 0.15)

	stun_overlay.visible = true
	stun_overlay.color = Color(0.6, 0.85, 1.0, 0.15)
	var mat: ShaderMaterial = stun_overlay.material as ShaderMaterial
	var tw: Tween = create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 0.0, 0.8, 0.2)
	active_tweens.append(tw)


func _end_stun_effect() -> void:
	var mat: ShaderMaterial = stun_overlay.material as ShaderMaterial
	var tw: Tween = create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 0.8, 0.0, 0.3)
	tw.tween_callback(func() -> void: stun_overlay.visible = false)
	active_tweens.append(tw)


func _play_anchor_effect() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("ANCHORED!", Color(0.2, 0.9, 0.6))
	_flash_screen(Color(0.1, 0.8, 0.5, 0.3), 0.15)

	anchor_overlay.visible = true
	anchor_overlay.color = Color(0.2, 1.0, 0.7, 0.1)
	var mat: ShaderMaterial = anchor_overlay.material as ShaderMaterial
	var tw: Tween = create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 0.0, 0.7, 0.2)
	active_tweens.append(tw)


func _end_anchor_effect() -> void:
	var mat: ShaderMaterial = anchor_overlay.material as ShaderMaterial
	var tw: Tween = create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 0.7, 0.0, 0.4)
	tw.tween_callback(func() -> void: anchor_overlay.visible = false)
	active_tweens.append(tw)


func _play_surge_effect() -> void:
	HapticManager.heavy_tap()
	_show_effect_text("SURGE!", Color(1.0, 0.9, 0.2))
	_flash_screen(Color(1.0, 0.85, 0.1, 0.5), 0.1)
	_shake(0.3, 8.0)

	burst_overlay.visible = true
	burst_overlay.color = Color(1.0, 0.9, 0.3, 0.2)
	var mat: ShaderMaterial = burst_overlay.material as ShaderMaterial
	var tw: Tween = create_tween()
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 0.0, 1.0, 0.1)
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("intensity", v), 1.0, 0.0, 0.4)
	tw.tween_callback(func() -> void: burst_overlay.visible = false)
	active_tweens.append(tw)


func _play_slack_effect() -> void:
	HapticManager.medium_tap()
	_show_effect_text("SLACK!", Color(0.5, 0.8, 1.0))
	_flash_screen(Color(0.3, 0.5, 0.8, 0.3), 0.2)


func _play_widen_effect() -> void:
	HapticManager.medium_tap()
	_show_effect_text("NET DRAG!", Color(0.3, 1.0, 0.5))
	_flash_screen(Color(0.2, 0.9, 0.4, 0.3), 0.15)


func _end_widen_effect() -> void:
	pass


func _flash_screen(color: Color, duration: float) -> void:
	screen_overlay.color = color
	var tw: Tween = create_tween()
	tw.tween_property(screen_overlay, "color:a", 0.0, duration)
	active_tweens.append(tw)


func _show_effect_text(text: String, color: Color) -> void:
	effect_label.text = text
	effect_label.add_theme_color_override("font_color", color)
	effect_label.visible = true
	effect_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	effect_label.scale = Vector2(0.5, 0.5)
	effect_label.pivot_offset = effect_label.size * 0.5

	var tw: Tween = create_tween()
	tw.tween_property(effect_label, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT)
	tw.tween_property(effect_label, "scale", Vector2.ONE, 0.1)
	tw.tween_interval(0.6)
	tw.tween_property(effect_label, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func() -> void: effect_label.visible = false)
	active_tweens.append(tw)


func _shake(duration: float, intensity: float) -> void:
	var original_pos: Vector2 = position
	var steps: int = int(duration / 0.03)
	var tw: Tween = create_tween()
	for i: int in steps:
		var offset: Vector2 = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tw.tween_property(self, "position", original_pos + offset, 0.03)
	tw.tween_property(self, "position", original_pos, 0.03)
	active_tweens.append(tw)
