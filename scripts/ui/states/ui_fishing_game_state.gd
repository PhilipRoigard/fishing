extends UIStateNode

const FightProgressBarScript: GDScript = preload("res://scripts/ui/components/fight_progress_bar.gd")
const FightTensionBarScript: GDScript = preload("res://scripts/ui/components/fight_tension_bar.gd")
const ReelZoneScript: GDScript = preload("res://scripts/ui/components/reel_zone.gd")

var depth_label: Label
var bait_label: Label
var return_button: Button
var cast_power_label: Label
var cast_power_bar: ProgressBar
var bite_flash_label: Label
var bite_tap_label: Label
var screen_flash: ColorRect
var feedback_label: Label

var fight_container: VBoxContainer
var progress_bar: Control
var tension_bar: Control
var reel_zone: Control

var is_fighting: bool = false
var bite_flash_tween: Tween
var feedback_tween: Tween
var flash_tween: Tween
var shake_tween: Tween
var bite_color_tween: Tween


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
	var top_bar: PanelContainer = PanelContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 100
	var top_style: StyleBoxFlat = StyleBoxFlat.new()
	top_style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
	top_bar.add_theme_stylebox_override("panel", top_style)
	top_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(top_bar)

	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_left", 12)
	top_margin.add_theme_constant_override("margin_right", 12)
	top_bar.add_child(top_margin)

	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 8)
	top_margin.add_child(top_hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(info_vbox)

	depth_label = Label.new()
	depth_label.text = "Hold to cast!"
	info_vbox.add_child(depth_label)

	bait_label = Label.new()
	bait_label.text = ""
	bait_label.add_theme_font_size_override("font_size", 12)
	info_vbox.add_child(bait_label)

	cast_power_label = Label.new()
	cast_power_label.text = ""
	cast_power_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	info_vbox.add_child(cast_power_label)

	cast_power_bar = ProgressBar.new()
	cast_power_bar.custom_minimum_size = Vector2(0, 14)
	cast_power_bar.max_value = 1.0
	cast_power_bar.value = 0.0
	cast_power_bar.visible = false
	cast_power_bar.show_percentage = false
	var bar_style: StyleBoxFlat = StyleBoxFlat.new()
	bar_style.bg_color = Color(0.2, 0.6, 1.0)
	bar_style.corner_radius_top_left = 4
	bar_style.corner_radius_top_right = 4
	bar_style.corner_radius_bottom_left = 4
	bar_style.corner_radius_bottom_right = 4
	cast_power_bar.add_theme_stylebox_override("fill", bar_style)
	var bar_bg: StyleBoxFlat = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bar_bg.corner_radius_top_left = 4
	bar_bg.corner_radius_top_right = 4
	bar_bg.corner_radius_bottom_left = 4
	bar_bg.corner_radius_bottom_right = 4
	cast_power_bar.add_theme_stylebox_override("background", bar_bg)
	info_vbox.add_child(cast_power_bar)

	return_button = Button.new()
	return_button.text = "Return"
	return_button.custom_minimum_size = Vector2(100, 44)
	return_button.pressed.connect(_on_return_pressed)
	top_hbox.add_child(return_button)

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

	fight_container = VBoxContainer.new()
	fight_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	fight_container.offset_top = -200
	fight_container.offset_bottom = -10
	fight_container.add_theme_constant_override("separation", 6)
	fight_container.visible = false
	fight_container.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fight_container)

	var progress_label: Label = Label.new()
	progress_label.text = "Progress"
	progress_label.add_theme_font_size_override("font_size", 12)
	fight_container.add_child(progress_label)

	progress_bar = FightProgressBarScript.new()
	progress_bar.custom_minimum_size = Vector2(0, 20)
	fight_container.add_child(progress_bar)

	var tension_label: Label = Label.new()
	tension_label.text = "Tension"
	tension_label.add_theme_font_size_override("font_size", 12)
	fight_container.add_child(tension_label)

	tension_bar = FightTensionBarScript.new()
	tension_bar.custom_minimum_size = Vector2(0, 20)
	fight_container.add_child(tension_bar)

	reel_zone = ReelZoneScript.new()
	reel_zone.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	reel_zone.offset_top = -220
	reel_zone.offset_bottom = 0
	reel_zone.visible = false
	add_child(reel_zone)


func _on_cast_strength_changed(strength: float) -> void:
	if cast_power_bar:
		cast_power_bar.value = strength
		cast_power_bar.visible = strength > 0.0
	if cast_power_label and strength > 0.0:
		cast_power_label.text = "Power: " + str(int(strength * 100)) + "%"


func _on_cast_landed(depth: float) -> void:
	if depth_label:
		depth_label.text = "Depth: " + str(int(depth)) + "m"
	if cast_power_label:
		cast_power_label.text = ""
	if cast_power_bar:
		cast_power_bar.visible = false


func _on_fishing_state_changed(state: int) -> void:
	match state:
		Enums.FishingState.IDLE:
			if depth_label:
				depth_label.text = "Hold to cast!"
			if cast_power_label:
				cast_power_label.text = ""
			if cast_power_bar:
				cast_power_bar.visible = false
			if bite_flash_label:
				bite_flash_label.visible = false
			if bite_tap_label:
				bite_tap_label.visible = false
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


func _on_fight_started(_fish_id: String) -> void:
	is_fighting = true
	if bite_flash_label:
		bite_flash_label.visible = false
	if bite_tap_label:
		bite_tap_label.visible = false
	if bite_color_tween and bite_color_tween.is_valid():
		bite_color_tween.kill()
	if fight_container:
		fight_container.visible = true
	if reel_zone:
		reel_zone.visible = true
	if return_button:
		return_button.visible = false
	if cast_power_label:
		cast_power_label.text = "Hold to reel!"


func _on_fight_progress_changed(progress: float) -> void:
	if progress_bar and progress_bar.has_method("set_progress"):
		progress_bar.set_progress(progress / 100.0)


func _on_fight_tension_changed(tension: float) -> void:
	if tension_bar and tension_bar.has_method("set_tension"):
		var tension_cap: float = 100.0
		if GameResources.config and GameResources.config.fishing_config:
			tension_cap = GameResources.config.fishing_config.tension_snap_threshold
		tension_bar.set_tension(tension / tension_cap)


func _on_fish_caught(fish_id: String) -> void:
	is_fighting = false
	_hide_fight_ui()
	HapticManager.success_feedback()
	_show_feedback("CAUGHT!", Color(0.2, 1.0, 0.2), 1.5)
	_flash_screen(Color(0.2, 1.0, 0.2, 0.4), 0.3)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		await tree.create_timer(1.0).timeout
	state_machine.push_state(UIStateMachine.State.CATCH_RESULT, {"fish_id": fish_id})


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
	if reel_zone:
		reel_zone.visible = false
	if return_button:
		return_button.visible = true
	if cast_power_label:
		cast_power_label.text = ""
	if cast_power_bar:
		cast_power_bar.visible = false
	if bite_flash_label:
		bite_flash_label.visible = false
	if bite_tap_label:
		bite_tap_label.visible = false


func _on_return_pressed() -> void:
	HapticManager.light_tap()
	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.stop_fishing()
	SignalBus.fishing_session_ended.emit()
	SignalBus.game_mode_changed.emit(Enums.GameMode.WHARF_HUB)
	state_machine.change_state(UIStateMachine.State.WHARF_HUB)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
