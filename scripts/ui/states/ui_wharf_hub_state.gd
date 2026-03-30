extends UIStateNode

var cast_button: Button
var level_label: Label
var session_catch_label: Label
var best_catch_label: Label
var tab_bar_instance: HBoxContainer
var currency_bar_instance: PanelContainer

var session_fish_count: int = 0
var session_best_fish_id: String = ""
var session_best_rarity: int = -1

const TabBarScene: PackedScene = preload("res://scenes/ui/components/tab_bar.tscn")
const CurrencyBarScript: GDScript = preload("res://scripts/ui/components/currency_bar.gd")


func enter(_meta: Variant = null) -> void:
	super(_meta)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not SignalBus.fish_caught.is_connected(_on_fish_caught):
		SignalBus.fish_caught.connect(_on_fish_caught)
	_build_layout()
	_refresh_display()
	ui_manager.show_tab_bar(true)
	ui_manager.show_currency_bar(true)


func exit() -> void:
	super()
	ui_manager.show_tab_bar(false)
	ui_manager.show_currency_bar(false)
	_clear_children()


func _build_layout() -> void:
	if not currency_bar_instance or not is_instance_valid(currency_bar_instance):
		currency_bar_instance = CurrencyBarScript.new()
		currency_bar_instance.mouse_filter = Control.MOUSE_FILTER_STOP
		ui_manager.set_currency_bar(currency_bar_instance)

	var center_container: VBoxContainer = VBoxContainer.new()
	center_container.set_anchors_preset(Control.PRESET_CENTER)
	center_container.custom_minimum_size = Vector2(280, 200)
	center_container.offset_left = -140
	center_container.offset_right = 140
	center_container.offset_top = -60
	center_container.offset_bottom = 140
	center_container.add_theme_constant_override("separation", 12)
	center_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(center_container)

	level_label = Label.new()
	level_label.text = "Fisherman Lv.1"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	center_container.add_child(level_label)

	var catch_row: HBoxContainer = HBoxContainer.new()
	catch_row.add_theme_constant_override("separation", 16)
	catch_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center_container.add_child(catch_row)

	session_catch_label = Label.new()
	session_catch_label.text = "Today: 0 fish"
	session_catch_label.add_theme_font_size_override("font_size", 12)
	session_catch_label.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
	catch_row.add_child(session_catch_label)

	best_catch_label = Label.new()
	best_catch_label.text = "Best: None yet"
	best_catch_label.add_theme_font_size_override("font_size", 12)
	best_catch_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	catch_row.add_child(best_catch_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 8
	center_container.add_child(spacer)

	cast_button = Button.new()
	cast_button.text = "CAST"
	cast_button.custom_minimum_size = Vector2(220, 64)
	cast_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cast_button.add_theme_font_size_override("font_size", 22)

	var cast_style: StyleBoxFlat = StyleBoxFlat.new()
	cast_style.bg_color = Color(0.45, 0.32, 0.18)
	cast_style.border_color = Color(0.6, 0.45, 0.25)
	cast_style.border_width_top = 2
	cast_style.border_width_bottom = 3
	cast_style.border_width_left = 2
	cast_style.border_width_right = 2
	cast_style.corner_radius_top_left = 10
	cast_style.corner_radius_top_right = 10
	cast_style.corner_radius_bottom_left = 10
	cast_style.corner_radius_bottom_right = 10
	cast_style.content_margin_top = 12
	cast_style.content_margin_bottom = 12
	cast_style.content_margin_left = 24
	cast_style.content_margin_right = 24
	cast_button.add_theme_stylebox_override("normal", cast_style)

	var cast_hover: StyleBoxFlat = cast_style.duplicate()
	cast_hover.bg_color = Color(0.55, 0.4, 0.22)
	cast_button.add_theme_stylebox_override("hover", cast_hover)

	var cast_pressed: StyleBoxFlat = cast_style.duplicate()
	cast_pressed.bg_color = Color(0.35, 0.25, 0.14)
	cast_button.add_theme_stylebox_override("pressed", cast_pressed)

	cast_button.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	cast_button.pressed.connect(_on_cast_pressed)
	center_container.add_child(cast_button)

	var craft_bait_button: Button = Button.new()
	craft_bait_button.text = "Craft Bait"
	craft_bait_button.custom_minimum_size = Vector2(180, 44)
	craft_bait_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	craft_bait_button.add_theme_font_size_override("font_size", 14)

	var craft_style: StyleBoxFlat = StyleBoxFlat.new()
	craft_style.bg_color = Color(0.3, 0.22, 0.13)
	craft_style.border_color = Color(0.45, 0.35, 0.2)
	craft_style.border_width_top = 1
	craft_style.border_width_bottom = 2
	craft_style.border_width_left = 1
	craft_style.border_width_right = 1
	craft_style.corner_radius_top_left = 8
	craft_style.corner_radius_top_right = 8
	craft_style.corner_radius_bottom_left = 8
	craft_style.corner_radius_bottom_right = 8
	craft_style.content_margin_top = 8
	craft_style.content_margin_bottom = 8
	craft_style.content_margin_left = 16
	craft_style.content_margin_right = 16
	craft_bait_button.add_theme_stylebox_override("normal", craft_style)

	var craft_hover: StyleBoxFlat = craft_style.duplicate()
	craft_hover.bg_color = Color(0.38, 0.28, 0.16)
	craft_bait_button.add_theme_stylebox_override("hover", craft_hover)

	var craft_pressed: StyleBoxFlat = craft_style.duplicate()
	craft_pressed.bg_color = Color(0.22, 0.16, 0.1)
	craft_bait_button.add_theme_stylebox_override("pressed", craft_pressed)

	craft_bait_button.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7))
	craft_bait_button.pressed.connect(_on_craft_bait_pressed)
	center_container.add_child(craft_bait_button)

	if not tab_bar_instance or not is_instance_valid(tab_bar_instance):
		tab_bar_instance = TabBarScene.instantiate()
		tab_bar_instance.tab_changed.connect(_on_tab_changed)
		ui_manager.set_tab_bar(tab_bar_instance)


func _refresh_display() -> void:
	var current_level: int = 1
	if ProgressManager:
		current_level = ProgressManager.get_current_level()
	if level_label:
		level_label.text = "Fisherman Lv." + str(current_level)

	if session_catch_label:
		session_catch_label.text = "Today: " + str(session_fish_count) + " fish"

	if best_catch_label:
		if session_best_fish_id != "":
			var best_name: String = session_best_fish_id
			if Main.instance and Main.instance.database_system:
				var fish_data: Variant = Main.instance.database_system.get_fish_by_id(session_best_fish_id)
				if fish_data:
					best_name = fish_data.display_name
			best_catch_label.text = "Best: " + best_name
		else:
			best_catch_label.text = "Best: None yet"


func _on_craft_bait_pressed() -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.BAIT_CRAFT)


func _on_cast_pressed() -> void:
	HapticManager.medium_tap()
	state_machine.change_state(UIStateMachine.State.FISHING_GAME)
	SignalBus.fishing_session_started.emit()
	SignalBus.game_mode_changed.emit(Enums.GameMode.FISHING_SESSION)
	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.start_fishing()


func focus() -> void:
	super()
	if tab_bar_instance and tab_bar_instance.is_inside_tree():
		tab_bar_instance.select_home()
	ui_manager.show_tab_bar(true)
	ui_manager.show_currency_bar(true)


func _on_tab_changed(tab_index: int) -> void:
	HapticManager.light_tap()
	var state: int = tab_bar_instance.TAB_STATES[tab_index]
	if tab_index == 2:
		if state_machine.active_states.size() > 1 and state_machine._get_active_state_node() != self:
			state_machine.pop_state()
		return
	if state < 0:
		return
	var target_state: UIStateMachine.State = state as UIStateMachine.State
	if state_machine.active_states.size() > 1 and state_machine._get_active_state_node() != self:
		state_machine.replace_top_state(target_state)
	else:
		state_machine.push_state(target_state)


func _setup_connections() -> void:
	pass


func _cleanup_connections() -> void:
	pass


func _on_fish_caught(fish_id: String) -> void:
	session_fish_count += 1
	if Main.instance and Main.instance.database_system:
		var fish_data: Variant = Main.instance.database_system.get_fish_by_id(fish_id)
		if fish_data:
			session_best_rarity = maxi(session_best_rarity, 0)
			session_best_fish_id = fish_id
	_refresh_display()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
