extends UIStateNode

var cast_button: Button
var level_label: Label
var equipment_label: Label
var session_catch_label: Label
var best_catch_label: Label
var tab_bar_instance: HBoxContainer
var currency_bar_instance: HBoxContainer

var session_fish_count: int = 0
var session_best_fish_id: String = ""
var session_best_rarity: int = -1

const TabBarScript: GDScript = preload("res://scripts/ui/components/tab_bar.gd")
const CurrencyBarScript: GDScript = preload("res://scripts/ui/components/currency_bar.gd")


func enter(_meta: Variant = null) -> void:
	super(_meta)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_layout()
	_refresh_display()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_bottom = 150
	var top_style: StyleBoxFlat = StyleBoxFlat.new()
	top_style.bg_color = Color(0.05, 0.08, 0.15, 0.75)
	top_panel.add_theme_stylebox_override("panel", top_style)
	top_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(top_panel)

	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.add_theme_constant_override("margin_left", 12)
	top_margin.add_theme_constant_override("margin_right", 12)
	top_margin.add_theme_constant_override("margin_bottom", 8)
	top_panel.add_child(top_margin)

	var top_vbox: VBoxContainer = VBoxContainer.new()
	top_vbox.add_theme_constant_override("separation", 4)
	top_margin.add_child(top_vbox)

	currency_bar_instance = CurrencyBarScript.new()
	top_vbox.add_child(currency_bar_instance)

	level_label = Label.new()
	level_label.text = "Level 1"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_vbox.add_child(level_label)

	equipment_label = Label.new()
	equipment_label.text = "No rod equipped"
	equipment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_label.add_theme_font_size_override("font_size", 12)
	top_vbox.add_child(equipment_label)

	session_catch_label = Label.new()
	session_catch_label.text = "Today's Catch: 0 fish"
	session_catch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	session_catch_label.add_theme_font_size_override("font_size", 11)
	session_catch_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	top_vbox.add_child(session_catch_label)

	best_catch_label = Label.new()
	best_catch_label.text = "Best Catch: None yet"
	best_catch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_catch_label.add_theme_font_size_override("font_size", 11)
	best_catch_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	top_vbox.add_child(best_catch_label)

	var bottom_panel: PanelContainer = PanelContainer.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_top = -160
	var bottom_style: StyleBoxFlat = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.05, 0.08, 0.15, 0.75)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	bottom_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bottom_panel)

	var bottom_vbox: VBoxContainer = VBoxContainer.new()
	bottom_vbox.add_theme_constant_override("separation", 8)
	bottom_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_panel.add_child(bottom_vbox)

	cast_button = Button.new()
	cast_button.text = "CAST"
	cast_button.custom_minimum_size = Vector2(200, 60)
	cast_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cast_button.pressed.connect(_on_cast_pressed)
	bottom_vbox.add_child(cast_button)

	tab_bar_instance = TabBarScript.new()
	tab_bar_instance.custom_minimum_size = Vector2(0, 40)
	tab_bar_instance.tab_changed.connect(_on_tab_changed)
	bottom_vbox.add_child(tab_bar_instance)
	ui_manager.set_tab_bar(tab_bar_instance)


func _refresh_display() -> void:
	var current_level: int = 1
	if ProgressManager:
		current_level = ProgressManager.get_current_level()
	if level_label:
		level_label.text = "Fisherman Lv." + str(current_level)

	if equipment_label:
		var lines: Array[String] = []
		var rod_entry: Variant = EquipmentManager.get_equipped(Enums.EquipmentSlot.ROD) if EquipmentManager else null
		var hook_entry: Variant = EquipmentManager.get_equipped(Enums.EquipmentSlot.HOOK) if EquipmentManager else null
		var lure_entry: Variant = EquipmentManager.get_equipped(Enums.EquipmentSlot.LURE) if EquipmentManager else null
		lines.append("Rod: " + _get_equip_display(rod_entry, "rod"))
		lines.append("Hook: " + _get_equip_display(hook_entry, "hook"))
		lines.append("Lure: " + _get_equip_display(lure_entry, "lure"))
		equipment_label.text = "\n".join(lines)

	if session_catch_label:
		session_catch_label.text = "Today's Catch: " + str(session_fish_count) + " fish"

	if best_catch_label:
		if session_best_fish_id != "":
			var best_name: String = session_best_fish_id
			if Main.instance and Main.instance.database_system:
				var fish_data: Variant = Main.instance.database_system.get_fish_by_id(session_best_fish_id)
				if fish_data:
					best_name = fish_data.display_name
			best_catch_label.text = "Best Catch: " + best_name
		else:
			best_catch_label.text = "Best Catch: None yet"


func _get_equip_display(entry: Variant, equipment_type: String) -> String:
	if not entry:
		return "None"
	var display_name: String = entry.item_id
	if GameResources.config and GameResources.config.equipment_catalogue:
		var catalogue: Variant = GameResources.config.equipment_catalogue
		var data: Variant = null
		match equipment_type:
			"rod":
				data = catalogue.get_rod_by_id(entry.item_id)
			"hook":
				data = catalogue.get_hook_by_id(entry.item_id)
			"lure":
				data = catalogue.get_lure_by_id(entry.item_id)
		if data and data.display_name != "":
			display_name = data.display_name
	return display_name + " Lv." + str(entry.level)


func _on_cast_pressed() -> void:
	HapticManager.medium_tap()
	state_machine.change_state(UIStateMachine.State.FISHING_GAME)
	SignalBus.fishing_session_started.emit()
	SignalBus.game_mode_changed.emit(Enums.GameMode.FISHING_SESSION)
	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.start_fishing()


func _on_tab_changed(tab_index: int) -> void:
	var tab_states: Array[int] = [
		UIStateMachine.State.COLLECTION_LOG,
		UIStateMachine.State.EQUIPMENT,
		UIStateMachine.State.STORE,
		UIStateMachine.State.TACKLE_BOX,
	]
	if tab_index >= 0 and tab_index < tab_states.size():
		state_machine.push_state(tab_states[tab_index] as UIStateMachine.State)


func _setup_connections() -> void:
	if not SignalBus.fish_caught.is_connected(_on_fish_caught):
		SignalBus.fish_caught.connect(_on_fish_caught)


func _cleanup_connections() -> void:
	if SignalBus.fish_caught.is_connected(_on_fish_caught):
		SignalBus.fish_caught.disconnect(_on_fish_caught)


func _on_fish_caught(fish_id: String) -> void:
	session_fish_count += 1
	if Main.instance and Main.instance.database_system:
		var fish_data: Variant = Main.instance.database_system.get_fish_by_id(fish_id)
		if fish_data and fish_data.rarity > session_best_rarity:
			session_best_rarity = fish_data.rarity
			session_best_fish_id = fish_id
	_refresh_display()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
