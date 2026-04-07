extends UIStateNode

const FightProgressBarScript: GDScript = preload("res://scripts/ui/components/fight_progress_bar.gd")
const FightTensionBarScript: GDScript = preload("res://scripts/ui/components/fight_tension_bar.gd")
const VerticalChaseTrackScript: GDScript = preload("res://scripts/ui/components/vertical_chase_track.gd")
const ConsumableSlotScript: GDScript = preload("res://scripts/ui/components/consumable_slot.gd")
const FightEffectsScript: GDScript = preload("res://scripts/ui/components/fight_effects.gd")

var depth_label: Label
var bait_label: Label
var back_button: Button
var cast_power_label: Label
var cast_power_bar: ProgressBar
var bite_flash_label: Label
var bite_tap_label: Label
var screen_flash: ColorRect
var feedback_label: Label

var fight_container: Control
var progress_bar: Control
var tension_bar: Control
var chase_track: Control
var fight_effects: CanvasLayer
var tool_slots: Array[Control] = []

var fish_name_label: Label
var tutorial_label: Label

var is_fighting: bool = false
var bite_flash_tween: Tween
var feedback_tween: Tween
var flash_tween: Tween
var shake_tween: Tween
var bite_color_tween: Tween
var cast_bar_fill_style: StyleBoxFlat
var tension_flash_active: bool = false
var tension_flash_time: float = 0.0
var progress_value_label: Label
var tension_value_label: Label
var cast_depth_preview_label: Label


func enter(_meta: Variant = null) -> void:
	super(_meta)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_fighting = false
	_build_layout()


func focus() -> void:
	super()
	if not is_fighting and Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.fishing_state_machine.change_state(&"idle")


func exit() -> void:
	super()
	is_fighting = false
	_kill_tweens()
	_clear_children()


func _kill_tweens() -> void:
	if bite_flash_tween and bite_flash_tween.is_valid():
		bite_flash_tween.kill()
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
	if bite_color_tween and bite_color_tween.is_valid():
		bite_color_tween.kill()


func _setup_connections() -> void:
	SignalBus.fight_started.connect(_on_fight_started)
	SignalBus.fight_progress_changed.connect(_on_fight_progress_changed)
	SignalBus.fight_tension_changed.connect(_on_fight_tension_changed)
	SignalBus.fish_caught.connect(_on_fish_caught)
	SignalBus.fish_escaped.connect(_on_fish_escaped)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.cast_landed.connect(_on_cast_landed)
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	SignalBus.cast_strength_changed.connect(_on_cast_strength_changed)
	SignalBus.bite_occurred.connect(_on_bite_occurred)


func _cleanup_connections() -> void:
	if SignalBus.fight_started.is_connected(_on_fight_started):
		SignalBus.fight_started.disconnect(_on_fight_started)
	if SignalBus.fight_progress_changed.is_connected(_on_fight_progress_changed):
		SignalBus.fight_progress_changed.disconnect(_on_fight_progress_changed)
	if SignalBus.fight_tension_changed.is_connected(_on_fight_tension_changed):
		SignalBus.fight_tension_changed.disconnect(_on_fight_tension_changed)
	if SignalBus.fish_caught.is_connected(_on_fish_caught):
		SignalBus.fish_caught.disconnect(_on_fish_caught)
	if SignalBus.fish_escaped.is_connected(_on_fish_escaped):
		SignalBus.fish_escaped.disconnect(_on_fish_escaped)
	if SignalBus.line_snapped.is_connected(_on_line_snapped):
		SignalBus.line_snapped.disconnect(_on_line_snapped)
	if SignalBus.cast_landed.is_connected(_on_cast_landed):
		SignalBus.cast_landed.disconnect(_on_cast_landed)
	if SignalBus.fishing_state_changed.is_connected(_on_fishing_state_changed):
		SignalBus.fishing_state_changed.disconnect(_on_fishing_state_changed)
	if SignalBus.cast_strength_changed.is_connected(_on_cast_strength_changed):
		SignalBus.cast_strength_changed.disconnect(_on_cast_strength_changed)
	if SignalBus.bite_occurred.is_connected(_on_bite_occurred):
		SignalBus.bite_occurred.disconnect(_on_bite_occurred)


func _build_layout() -> void:
	var back_button: Button = Button.new()
	back_button.text = "<"
	back_button.custom_minimum_size = Vector2(36, 36)
	back_button.position = Vector2(8, 8)
	back_button.pressed.connect(_on_return_pressed)
	back_button.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(back_button)

	depth_label = Label.new()
	depth_label.text = "Hold to cast!"
	depth_label.position = Vector2(50, 10)
	depth_label.add_theme_font_size_override("font_size", 14)
	depth_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(depth_label)

	cast_power_label = Label.new()
	cast_power_label.text = ""
	cast_power_label.position = Vector2(50, 30)
	cast_power_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	cast_power_label.add_theme_font_size_override("font_size", 12)
	add_child(cast_power_label)

	bait_label = Label.new()
	bait_label.text = ""
	bait_label.position = Vector2(50, 48)
	bait_label.add_theme_font_size_override("font_size", 10)
	add_child(bait_label)

	cast_power_bar = ProgressBar.new()
	cast_power_bar.custom_minimum_size = Vector2(0, 18)
	cast_power_bar.max_value = 1.0
	cast_power_bar.value = 0.0
	cast_power_bar.visible = false
	cast_power_bar.show_percentage = false
	cast_bar_fill_style = StyleBoxFlat.new()
	cast_bar_fill_style.bg_color = Color(0.2, 0.6, 1.0)
	cast_bar_fill_style.corner_radius_top_left = 4
	cast_bar_fill_style.corner_radius_top_right = 4
	cast_bar_fill_style.corner_radius_bottom_left = 4
	cast_bar_fill_style.corner_radius_bottom_right = 4
	cast_power_bar.add_theme_stylebox_override("fill", cast_bar_fill_style)
	var bar_bg: StyleBoxFlat = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bar_bg.corner_radius_top_left = 4
	bar_bg.corner_radius_top_right = 4
	bar_bg.corner_radius_bottom_left = 4
	bar_bg.corner_radius_bottom_right = 4
	cast_power_bar.add_theme_stylebox_override("background", bar_bg)
	cast_power_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	cast_power_bar.offset_top = 66
	cast_power_bar.offset_bottom = 84
	cast_power_bar.offset_left = 50
	cast_power_bar.offset_right = -16
	add_child(cast_power_bar)

	cast_depth_preview_label = Label.new()
	cast_depth_preview_label.text = ""
	cast_depth_preview_label.add_theme_font_size_override("font_size", 11)
	cast_depth_preview_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	cast_depth_preview_label.visible = false
	cast_depth_preview_label.position = Vector2(50, 86)
	add_child(cast_depth_preview_label)

	screen_flash = ColorRect.new()
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_flash)

	var bite_container: VBoxContainer = VBoxContainer.new()
	bite_container.set_anchors_preset(Control.PRESET_CENTER)
	bite_container.offset_left = -150
	bite_container.offset_right = 150
	bite_container.offset_top = -70
	bite_container.offset_bottom = 70
	bite_container.alignment = BoxContainer.ALIGNMENT_CENTER
	bite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bite_container)

	bite_flash_label = Label.new()
	bite_flash_label.text = "BITE!"
	bite_flash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bite_flash_label.add_theme_font_size_override("font_size", 64)
	bite_flash_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	bite_flash_label.visible = false
	bite_flash_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bite_container.add_child(bite_flash_label)

	bite_tap_label = Label.new()
	bite_tap_label.text = "TAP!"
	bite_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bite_tap_label.add_theme_font_size_override("font_size", 32)
	bite_tap_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	bite_tap_label.visible = false
	bite_tap_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bite_container.add_child(bite_tap_label)

	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.set_anchors_preset(Control.PRESET_CENTER)
	feedback_label.offset_left = -150
	feedback_label.offset_right = 150
	feedback_label.offset_top = -40
	feedback_label.offset_bottom = 40
	feedback_label.add_theme_font_size_override("font_size", 48)
	feedback_label.visible = false
	feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(feedback_label)

	tutorial_label = Label.new()
	tutorial_label.text = ""
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_label.offset_left = -160
	tutorial_label.offset_right = 160
	tutorial_label.offset_top = 60
	tutorial_label.offset_bottom = 100
	tutorial_label.add_theme_font_size_override("font_size", 18)
	tutorial_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.9))
	tutorial_label.visible = false
	tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tutorial_label)

	fight_container = Control.new()
	fight_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	fight_container.visible = false
	fight_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fight_container)

	fish_name_label = Label.new()
	fish_name_label.text = ""
	fish_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fish_name_label.add_theme_font_size_override("font_size", 16)
	fish_name_label.visible = false
	fish_name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fish_name_label.offset_top = 70
	fish_name_label.offset_bottom = 90
	fight_container.add_child(fish_name_label)

	chase_track = VerticalChaseTrackScript.new()
	chase_track.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	chase_track.offset_left = -70
	chase_track.offset_top = 90
	chase_track.offset_bottom = -10
	chase_track.offset_right = -10
	fight_container.add_child(chase_track)

	var bars_panel: VBoxContainer = VBoxContainer.new()
	bars_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bars_panel.offset_top = -120
	bars_panel.offset_bottom = -10
	bars_panel.offset_left = 12
	bars_panel.offset_right = -80
	bars_panel.add_theme_constant_override("separation", 4)
	bars_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fight_container.add_child(bars_panel)

	var progress_header: HBoxContainer = HBoxContainer.new()
	bars_panel.add_child(progress_header)
	var progress_label: Label = Label.new()
	progress_label.text = "Progress"
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_header.add_child(progress_label)
	progress_value_label = Label.new()
	progress_value_label.text = "30%"
	progress_value_label.add_theme_font_size_override("font_size", 12)
	progress_value_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	progress_header.add_child(progress_value_label)

	progress_bar = FightProgressBarScript.new()
	progress_bar.custom_minimum_size = Vector2(0, 14)
	bars_panel.add_child(progress_bar)

	var tension_header: HBoxContainer = HBoxContainer.new()
	bars_panel.add_child(tension_header)
	var tension_label: Label = Label.new()
	tension_label.text = "Tension"
	tension_label.add_theme_font_size_override("font_size", 12)
	tension_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tension_header.add_child(tension_label)
	tension_value_label = Label.new()
	tension_value_label.text = "0%"
	tension_value_label.add_theme_font_size_override("font_size", 12)
	tension_value_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	tension_header.add_child(tension_value_label)

	tension_bar = FightTensionBarScript.new()
	tension_bar.custom_minimum_size = Vector2(0, 14)
	bars_panel.add_child(tension_bar)

	var tools_row: HBoxContainer = HBoxContainer.new()
	tools_row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	tools_row.offset_top = -190
	tools_row.offset_bottom = -130
	tools_row.offset_left = 12
	tools_row.offset_right = -80
	tools_row.add_theme_constant_override("separation", 6)
	tools_row.alignment = BoxContainer.ALIGNMENT_CENTER
	fight_container.add_child(tools_row)

	tool_slots.clear()
	var tool_configs: Array[Dictionary] = [
		{"effect": Enums.ConsumableEffect.STUN, "count": 3, "label": "STUN", "color": Color(0.4, 0.8, 1.0)},
		{"effect": Enums.ConsumableEffect.RESTRICT_RANGE, "count": 2, "label": "ANCHOR", "color": Color(0.2, 0.9, 0.6)},
		{"effect": Enums.ConsumableEffect.LINE_SURGE, "count": 1, "label": "SURGE", "color": Color(1.0, 0.9, 0.2)},
		{"effect": Enums.ConsumableEffect.SLACK_RELEASE, "count": 3, "label": "SLACK", "color": Color(0.5, 0.7, 1.0)},
	]

	for cfg: Dictionary in tool_configs:
		var slot: Control = _create_tool_slot(cfg)
		slot.effect_type = cfg["effect"]
		slot.remaining_count = cfg["count"]
		tools_row.add_child(slot)
		slot.setup(cfg["effect"], cfg["count"])
		_style_tool_slot(slot, cfg["color"], cfg["label"])
		tool_slots.append(slot)

	fight_effects = FightEffectsScript.new()
	add_child(fight_effects)



func _create_tool_slot(cfg: Dictionary) -> Control:
	var slot: Control = ConsumableSlotScript.new()
	slot.slot_size = 56.0
	slot.cooldown_duration = 3.0
	slot.consumable_used.connect(_on_tool_used)
	return slot


func _style_tool_slot(slot: Control, color: Color, label_text: String) -> void:
	var slot_label: Label = Label.new()
	slot_label.text = label_text
	slot_label.add_theme_font_size_override("font_size", 9)
	slot_label.add_theme_color_override("font_color", color)
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	slot_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot_label.offset_top = 2
	slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(slot_label)

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(color.r, color.g, color.b, 0.15)
	bg_style.border_color = Color(color.r, color.g, color.b, 0.4)
	bg_style.set_border_width_all(2)
	bg_style.set_corner_radius_all(6)
	if slot.touch_button:
		slot.touch_button.add_theme_stylebox_override("normal", bg_style)
		var hover_style: StyleBoxFlat = bg_style.duplicate()
		hover_style.bg_color = Color(color.r, color.g, color.b, 0.3)
		slot.touch_button.add_theme_stylebox_override("hover", hover_style)
		var pressed_style: StyleBoxFlat = bg_style.duplicate()
		pressed_style.bg_color = Color(color.r, color.g, color.b, 0.5)
		slot.touch_button.add_theme_stylebox_override("pressed", pressed_style)


func _on_tool_used(effect: Enums.ConsumableEffect) -> void:
	var duration: float = 0.0
	if GameResources.config and GameResources.config.fishing_config:
		var fc: FishingConfig = GameResources.config.fishing_config
		match effect:
			Enums.ConsumableEffect.STUN:
				duration = fc.stun_lure_duration
			Enums.ConsumableEffect.RESTRICT_RANGE:
				duration = fc.depth_anchor_duration
			Enums.ConsumableEffect.WIDEN_BRACKET:
				duration = fc.net_drag_duration
			Enums.ConsumableEffect.LINE_SURGE:
				duration = 0.0
			Enums.ConsumableEffect.SLACK_RELEASE:
				duration = 0.0
	SignalBus.consumable_used.emit(effect, duration)


func _on_cast_strength_changed(strength: float) -> void:
	if cast_power_bar:
		cast_power_bar.value = strength
		cast_power_bar.visible = strength > 0.0
	if cast_bar_fill_style and strength > 0.0:
		var bar_color: Color
		if strength < 0.5:
			bar_color = Color(0.2, 0.6, 1.0).lerp(Color(1.0, 0.7, 0.1), strength * 2.0)
		else:
			bar_color = Color(1.0, 0.7, 0.1).lerp(Color(0.9, 0.2, 0.1), (strength - 0.5) * 2.0)
		var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.008) * 0.08 * strength
		bar_color = bar_color.lightened(0.1 * (pulse - 1.0) * 10.0)
		cast_bar_fill_style.bg_color = bar_color
	if cast_power_label and strength > 0.0:
		cast_power_label.text = "Power: " + str(int(strength * 100)) + "%"
	if cast_depth_preview_label:
		if strength > 0.0:
			var min_depth: float = 50.0
			var max_depth: float = 500.0
			if GameResources.config and GameResources.config.fishing_config:
				min_depth = GameResources.config.fishing_config.min_cast_depth
				max_depth = GameResources.config.fishing_config.max_cast_depth_base
			var preview_depth: int = int(min_depth + strength * (max_depth - min_depth))
			var zone_name: String = _get_depth_zone_name(strength)
			cast_depth_preview_label.text = "~" + str(preview_depth) + "m (" + zone_name + ")"
			cast_depth_preview_label.visible = true
		else:
			cast_depth_preview_label.visible = false


func _on_cast_landed(depth: float) -> void:
	if depth_label:
		depth_label.text = "Depth: " + str(int(depth)) + "m"
	if cast_power_label:
		cast_power_label.text = ""
	if cast_power_bar:
		cast_power_bar.visible = false
	if cast_depth_preview_label:
		cast_depth_preview_label.visible = false


func _on_fishing_state_changed(state: int) -> void:
	match state:
		Enums.FishingState.IDLE:
			if depth_label:
				depth_label.text = "Hold to cast!"
			if cast_power_label:
				cast_power_label.text = ""
			if cast_power_bar:
				cast_power_bar.visible = false
			if cast_depth_preview_label:
				cast_depth_preview_label.visible = false
			if bite_flash_label:
				bite_flash_label.visible = false
			if bite_tap_label:
				bite_tap_label.visible = false
			if fish_name_label:
				fish_name_label.visible = false
			_show_tutorial_hint("Hold anywhere to charge your cast!")
		Enums.FishingState.CASTING:
			if depth_label:
				depth_label.text = "Charging cast..."
		Enums.FishingState.WAITING:
			if cast_power_label:
				cast_power_label.text = "Waiting for bite..."
			if bite_flash_label:
				bite_flash_label.visible = false
			if bite_tap_label:
				bite_tap_label.visible = false
			_show_tutorial_hint("Wait for a fish to bite...")
		Enums.FishingState.REELING_IN:
			_hide_fight_ui()


func _on_bite_occurred(_fish_id: String) -> void:
	if bite_flash_label:
		bite_flash_label.visible = true
		bite_flash_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		bite_flash_label.scale = Vector2.ONE

	if bite_tap_label:
		bite_tap_label.visible = true
		bite_tap_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if bite_flash_tween and bite_flash_tween.is_valid():
		bite_flash_tween.kill()
	bite_flash_tween = create_tween()
	bite_flash_tween.tween_property(bite_flash_label, "scale", Vector2(1.3, 1.3), 0.15)
	bite_flash_tween.tween_property(bite_flash_label, "scale", Vector2.ONE, 0.15)
	bite_flash_tween.tween_interval(1.7)
	bite_flash_tween.tween_callback(func() -> void:
		if bite_flash_label:
			bite_flash_label.visible = false
		if bite_tap_label:
			bite_tap_label.visible = false
	)

	if bite_color_tween and bite_color_tween.is_valid():
		bite_color_tween.kill()
	bite_color_tween = create_tween().set_loops(10)
	bite_color_tween.tween_property(bite_flash_label, "theme_override_colors/font_color", Color(1.0, 0.3, 0.1), 0.1)
	bite_color_tween.tween_property(bite_flash_label, "theme_override_colors/font_color", Color(1.0, 1.0, 0.0), 0.1)

	_flash_screen(Color(1.0, 1.0, 1.0, 0.6), 0.1)

	if cast_power_label:
		cast_power_label.text = "TAP NOW!"
	_show_tutorial_hint("TAP to hook the fish!")


func _flash_screen(color: Color, duration: float) -> void:
	if not screen_flash:
		return
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	screen_flash.color = color
	flash_tween = create_tween()
	flash_tween.tween_property(screen_flash, "color:a", 0.0, duration)


func _show_feedback(text: String, color: Color, duration: float) -> void:
	if not feedback_label:
		return
	if feedback_tween and feedback_tween.is_valid():
		feedback_tween.kill()
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	feedback_label.scale = Vector2.ONE
	feedback_label.visible = true
	feedback_tween = create_tween()
	feedback_tween.tween_property(feedback_label, "scale", Vector2(1.2, 1.2), 0.1)
	feedback_tween.tween_property(feedback_label, "scale", Vector2.ONE, 0.1)
	feedback_tween.tween_interval(maxf(duration - 1.2, 0.0))
	feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 1.0)
	feedback_tween.tween_callback(func() -> void:
		if feedback_label:
			feedback_label.visible = false
	)


func _shake_ui(duration: float, intensity: float) -> void:
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
	var original_position: Vector2 = position
	var steps: int = int(duration / 0.03)
	shake_tween = create_tween()
	for i: int in steps:
		var offset: Vector2 = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(self, "position", original_position + offset, 0.03)
	shake_tween.tween_property(self, "position", original_position, 0.03)


func _on_fight_started(fish_id: String) -> void:
	is_fighting = true
	if bite_flash_label:
		bite_flash_label.visible = false
	if bite_tap_label:
		bite_tap_label.visible = false
	if bite_color_tween and bite_color_tween.is_valid():
		bite_color_tween.kill()
	if fight_container:
		fight_container.visible = true
	if back_button:
		back_button.visible = false
	if cast_power_label:
		cast_power_label.text = ""
	_show_fish_name(fish_id)
	_show_tutorial_hint("Hold to raise the bar, release to let it fall!")


func _get_rarity_color(rarity: int) -> Color:
	match rarity:
		Enums.Rarity.COMMON:
			return Color(0.8, 0.8, 0.8)
		Enums.Rarity.UNCOMMON:
			return Color(0.2, 0.9, 0.3)
		Enums.Rarity.RARE:
			return Color(0.3, 0.5, 1.0)
		Enums.Rarity.LEGENDARY:
			return Color(1.0, 0.7, 0.1)
	return Color.WHITE


func _show_fish_name(fish_id: String) -> void:
	if not fish_name_label:
		return
	var fish_name: String = fish_id
	var rarity_color: Color = Color.WHITE
	if Main.instance and Main.instance.database_system:
		var fd: Variant = Main.instance.database_system.get_fish_by_id(fish_id)
		if fd:
			fish_name = fd.display_name
	fish_name_label.text = "Fighting: " + fish_name
	fish_name_label.add_theme_color_override("font_color", rarity_color)
	fish_name_label.visible = true


func _is_first_session() -> bool:
	if Main.instance and Main.instance.player_state_system:
		var state: Variant = Main.instance.player_state_system.get_state()
		if state and state.total_fish_caught == 0:
			return true
	return false


func _get_depth_zone_name(strength: float) -> String:
	if strength < 0.33:
		return "Shallow"
	elif strength < 0.66:
		return "Ocean"
	return "Deep"


func _show_tutorial_hint(hint_text: String) -> void:
	if not tutorial_label:
		return
	if not _is_first_session():
		tutorial_label.visible = false
		return
	tutorial_label.text = hint_text
	tutorial_label.visible = true


func _on_fight_progress_changed(progress: float) -> void:
	if progress_bar and progress_bar.has_method("set_progress"):
		progress_bar.set_progress(progress / 100.0)
	if progress_value_label:
		progress_value_label.text = str(int(progress)) + "%"


func _on_fight_tension_changed(tension: float) -> void:
	var tension_cap: float = 100.0
	if GameResources.config and GameResources.config.fishing_config:
		tension_cap = GameResources.config.fishing_config.tension_snap_threshold
	var tension_pct: float = tension / tension_cap
	if tension_bar and tension_bar.has_method("set_tension"):
		tension_bar.set_tension(tension_pct)
	if tension_value_label:
		tension_value_label.text = str(int(tension_pct * 100.0)) + "%"
		if tension_pct >= 0.8:
			var flash: float = abs(sin(Time.get_ticks_msec() * 0.01))
			tension_value_label.add_theme_color_override("font_color", Color(1.0, flash * 0.3, flash * 0.1))
		elif tension_pct >= 0.5:
			tension_value_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1))
		else:
			tension_value_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))


func _on_fish_caught(fish_id: String) -> void:
	is_fighting = false
	_hide_fight_ui()
	HapticManager.success_feedback()
	_show_feedback("CAUGHT!", Color(0.2, 1.0, 0.2), 1.5)
	_flash_screen(Color(0.2, 1.0, 0.2, 0.4), 0.3)
	_shake_ui(0.3, 4.0)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		await tree.create_timer(1.0).timeout
	var caught_quality: int = 0
	if Main.instance and Main.instance.player_state_system:
		var pstate: PlayerState = Main.instance.player_state_system.get_state()
		if pstate and pstate.equipped_bait_id.begins_with("bait_q"):
			var bait_q: int = pstate.equipped_bait_id.substr(6).to_int()
			caught_quality = bait_q
			var remaining: int = pstate.bait_inventory.get(bait_q, 0) - 1
			if remaining <= 0:
				pstate.bait_inventory.erase(bait_q)
				pstate.equipped_bait_id = ""
			else:
				pstate.bait_inventory[bait_q] = remaining
			SignalBus.save_requested.emit()

	var double_catch_pct: float = _get_hook_perk_value("double_catch")
	var is_double_catch: bool = double_catch_pct > 0.0 and randf() * 100.0 < double_catch_pct
	if is_double_catch:
		SignalBus.fish_caught.emit(fish_id)
		_show_feedback("DOUBLE CATCH!", Color(1.0, 0.84, 0.0), 1.5)
		if tree:
			await tree.create_timer(0.5).timeout

	state_machine.push_state(UIStateMachine.State.CATCH_RESULT, {"fish_id": fish_id, "caught_quality": caught_quality})


func _on_fish_escaped(_fish_id: String) -> void:
	is_fighting = false
	_hide_fight_ui()
	HapticManager.fail_feedback()
	_show_feedback("ESCAPED!", Color(1.0, 0.3, 0.2), 2.0)
	if depth_label:
		depth_label.text = "Fish escaped! Hold to cast again."


func _on_line_snapped() -> void:
	is_fighting = false
	_hide_fight_ui()
	HapticManager.fail_feedback()
	_show_feedback("LINE SNAPPED!", Color(1.0, 0.2, 0.2), 2.0)
	_shake_ui(0.3, 6.0)
	if depth_label:
		depth_label.text = "Line snapped! Hold to cast again."


func _hide_fight_ui() -> void:
	if fight_container:
		fight_container.visible = false
	if back_button:
		back_button.visible = true
	if cast_power_label:
		cast_power_label.text = ""
	if cast_power_bar:
		cast_power_bar.visible = false
	if cast_depth_preview_label:
		cast_depth_preview_label.visible = false
	if bite_flash_label:
		bite_flash_label.visible = false
	if bite_tap_label:
		bite_tap_label.visible = false
	if fish_name_label:
		fish_name_label.visible = false
	if tutorial_label:
		tutorial_label.visible = false


func _on_return_pressed() -> void:
	HapticManager.light_tap()
	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.stop_fishing()
	SignalBus.fishing_session_ended.emit()
	SignalBus.game_mode_changed.emit(Enums.GameMode.WHARF_HUB)
	state_machine.change_state(UIStateMachine.State.WHARF_HUB)


func _get_hook_perk_value(perk_id: String) -> float:
	var hook_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.HOOK)
	if not hook_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return 0.0
	var hook_data: HookData = GameResources.config.equipment_catalogue.get_hook_by_id(hook_entry.item_id)
	if not hook_data or hook_data.perk_id != perk_id:
		return 0.0
	var perk_idx: int = mini(hook_entry.quality, hook_data.perk_values.size() - 1)
	return hook_data.perk_values[perk_idx]


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
