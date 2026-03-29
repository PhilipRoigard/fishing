extends UIStateNode

var cast_button: Button
var level_label: Label
var equipment_label: Label
var tab_bar_instance: HBoxContainer
var currency_bar_instance: HBoxContainer

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
	top_panel.offset_bottom = 100
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

	var rod_entry: Variant = EquipmentManager.get_equipped(0) if EquipmentManager else null
	if equipment_label:
		if rod_entry:
			var rod_display_name: String = rod_entry.item_id
			if GameResources.config and GameResources.config.equipment_catalogue:
				var rod_data: Variant = GameResources.config.equipment_catalogue.get_rod_by_id(rod_entry.item_id)
				if rod_data and rod_data.display_name != "":
					rod_display_name = rod_data.display_name
			equipment_label.text = "Rod: " + rod_display_name + " Lv." + str(rod_entry.level)
		else:
			equipment_label.text = "No rod equipped"


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


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
