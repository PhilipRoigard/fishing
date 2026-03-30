extends CanvasLayer

var state_machine: UIStateMachine
var tab_bar: Control
var currency_bar: Control
var game_theme: Theme


func _ready() -> void:
	game_theme = _build_theme()

	state_machine = UIStateMachine.new(self)
	state_machine.name = "UIStateMachine"
	add_child(state_machine)

	_create_screens()
	_create_debug_ui()
	_start_loading()


func _build_theme() -> Theme:
	var t: Theme = Theme.new()

	var font: FontFile = load("res://resources/ui/Fonts/bytebounce.medium.ttf")
	t.default_font = font
	t.default_font_size = 16

	t.set_font_size("font_size", "Button", 14)
	t.set_font_size("font_size", "Label", 16)

	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.12, 0.15, 0.22)
	btn_normal.border_color = Color(0.3, 0.4, 0.55)
	btn_normal.border_width_top = 2
	btn_normal.border_width_bottom = 2
	btn_normal.border_width_left = 2
	btn_normal.border_width_right = 2
	btn_normal.corner_radius_top_left = 8
	btn_normal.corner_radius_top_right = 8
	btn_normal.corner_radius_bottom_left = 8
	btn_normal.corner_radius_bottom_right = 8
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8
	btn_normal.content_margin_left = 16
	btn_normal.content_margin_right = 16
	t.set_stylebox("normal", "Button", btn_normal)

	var btn_hover: StyleBoxFlat = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.18, 0.22, 0.32)
	t.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed: StyleBoxFlat = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.08, 0.1, 0.16)
	t.set_stylebox("pressed", "Button", btn_pressed)

	var btn_focus: StyleBoxFlat = btn_hover.duplicate()
	btn_focus.border_color = Color(0.4, 0.55, 0.8)
	t.set_stylebox("focus", "Button", btn_focus)

	var btn_disabled: StyleBoxFlat = btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.08, 0.08, 0.1)
	btn_disabled.border_color = Color(0.15, 0.15, 0.2)
	t.set_stylebox("disabled", "Button", btn_disabled)

	t.set_color("font_color", "Button", Color(0.9, 0.92, 0.95))
	t.set_color("font_hover_color", "Button", Color(1.0, 1.0, 1.0))
	t.set_color("font_pressed_color", "Button", Color(0.7, 0.75, 0.85))
	t.set_color("font_disabled_color", "Button", Color(0.4, 0.4, 0.45))

	t.set_color("font_color", "Label", Color(0.95, 0.95, 0.95))

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.08, 0.14)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	t.set_stylebox("panel", "PanelContainer", panel_style)

	var bar_bg: StyleBoxFlat = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.08, 0.1, 0.16)
	bar_bg.corner_radius_top_left = 4
	bar_bg.corner_radius_top_right = 4
	bar_bg.corner_radius_bottom_left = 4
	bar_bg.corner_radius_bottom_right = 4
	t.set_stylebox("background", "ProgressBar", bar_bg)

	var bar_fill: StyleBoxFlat = StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.15, 0.65, 0.3)
	bar_fill.corner_radius_top_left = 4
	bar_fill.corner_radius_top_right = 4
	bar_fill.corner_radius_bottom_left = 4
	bar_fill.corner_radius_bottom_right = 4
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	var separator_style: StyleBoxFlat = StyleBoxFlat.new()
	separator_style.bg_color = Color(0.2, 0.25, 0.35)
	separator_style.content_margin_top = 1
	separator_style.content_margin_bottom = 1
	t.set_stylebox("separator", "HSeparator", separator_style)
	t.set_constant("separation", "HSeparator", 8)

	var slider_style: StyleBoxFlat = StyleBoxFlat.new()
	slider_style.bg_color = Color(0.1, 0.12, 0.2)
	slider_style.corner_radius_top_left = 4
	slider_style.corner_radius_top_right = 4
	slider_style.corner_radius_bottom_left = 4
	slider_style.corner_radius_bottom_right = 4
	slider_style.content_margin_top = 4
	slider_style.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", slider_style)

	var grabber_style: StyleBoxFlat = StyleBoxFlat.new()
	grabber_style.bg_color = Color(0.3, 0.5, 0.8)
	grabber_style.corner_radius_top_left = 4
	grabber_style.corner_radius_top_right = 4
	grabber_style.corner_radius_bottom_left = 4
	grabber_style.corner_radius_bottom_right = 4
	t.set_stylebox("grabber_area", "HSlider", grabber_style)

	var check_normal: StyleBoxFlat = StyleBoxFlat.new()
	check_normal.bg_color = Color(0.1, 0.12, 0.2)
	check_normal.corner_radius_top_left = 4
	check_normal.corner_radius_top_right = 4
	check_normal.corner_radius_bottom_left = 4
	check_normal.corner_radius_bottom_right = 4
	check_normal.content_margin_top = 8
	check_normal.content_margin_bottom = 8
	check_normal.content_margin_left = 12
	check_normal.content_margin_right = 12
	t.set_stylebox("normal", "CheckButton", check_normal)

	t.set_color("font_color", "CheckButton", Color(0.9, 0.92, 0.95))

	return t


func _create_screens() -> void:
	_register(UIStateMachine.State.LOADING, preload("res://scripts/ui/states/ui_loading_state.gd"))
	_register(UIStateMachine.State.MAIN_MENU, preload("res://scripts/ui/states/ui_main_menu_state.gd"))
	_register(UIStateMachine.State.WHARF_HUB, preload("res://scripts/ui/states/ui_wharf_hub_state.gd"))
	_register(UIStateMachine.State.FISHING_GAME, preload("res://scripts/ui/states/ui_fishing_game_state.gd"))
	_register(UIStateMachine.State.CATCH_RESULT, preload("res://scripts/ui/states/ui_catch_result_state.gd"))
	_register(UIStateMachine.State.EQUIPMENT, preload("res://scripts/ui/states/ui_equipment_state.gd"))
	_register_scene(UIStateMachine.State.EQUIPMENT_DETAILS, preload("res://scenes/ui/components/equipment_details_popup.tscn"))
	_register(UIStateMachine.State.COLLECTION_LOG, preload("res://scripts/ui/states/ui_collection_log_state.gd"))
	_register(UIStateMachine.State.FISH_DETAILS, preload("res://scripts/ui/states/ui_fish_details_state.gd"))
	_register(UIStateMachine.State.STORE, preload("res://scripts/ui/states/ui_store_state.gd"))
	_register(UIStateMachine.State.TACKLE_BOX, preload("res://scripts/ui/states/ui_tackle_box_state.gd"))
	_register(UIStateMachine.State.TACKLE_BOX_REVEAL, preload("res://scripts/ui/states/ui_tackle_box_reveal_state.gd"))
	_register(UIStateMachine.State.SETTINGS, preload("res://scripts/ui/states/ui_settings_state.gd"))
	_register(UIStateMachine.State.PAUSE, preload("res://scripts/ui/states/ui_pause_state.gd"))
	_register(UIStateMachine.State.YES_NO_POPUP, preload("res://scripts/ui/states/ui_yes_no_popup_state.gd"))
	_register(UIStateMachine.State.PURCHASING, preload("res://scripts/ui/states/ui_purchasing_state.gd"))
	_register(UIStateMachine.State.BAIT_CRAFT, preload("res://scripts/ui/states/ui_bait_craft_state.gd"))
	_register(UIStateMachine.State.TOOLTIP, preload("res://scripts/ui/states/ui_tooltip_state.gd"))


func _register(state: UIStateMachine.State, script: GDScript) -> void:
	var node: UIStateNode = script.new()
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.theme = game_theme
	add_child(node)
	state_machine.add_state(state, node)


func _register_scene(state: UIStateMachine.State, scene: PackedScene) -> void:
	var node: UIStateNode = scene.instantiate() as UIStateNode
	node.theme = game_theme
	add_child(node)
	state_machine.add_state(state, node)


func _create_debug_ui() -> void:
	var debug_scene: PackedScene = preload("res://scenes/ui/components/debug_admin_ui.tscn")
	var debug_ui: Control = debug_scene.instantiate()
	debug_ui.theme = game_theme
	add_child(debug_ui)


func _start_loading() -> void:
	state_machine.change_state(UIStateMachine.State.LOADING)


func set_tab_bar(bar: Control) -> void:
	if tab_bar and tab_bar.get_parent():
		tab_bar.get_parent().remove_child(tab_bar)
	tab_bar = bar
	add_child(tab_bar)


func set_currency_bar(bar: Control) -> void:
	if currency_bar and currency_bar.get_parent():
		currency_bar.get_parent().remove_child(currency_bar)
	currency_bar = bar
	add_child(currency_bar)


func show_tab_bar(should_show: bool) -> void:
	if tab_bar:
		tab_bar.visible = should_show


func show_currency_bar(should_show: bool) -> void:
	if currency_bar:
		currency_bar.visible = should_show


func raise_overlays() -> void:
	if currency_bar and currency_bar.get_parent():
		currency_bar.get_parent().move_child.call_deferred(currency_bar, currency_bar.get_parent().get_child_count() - 1)
	if tab_bar and tab_bar.get_parent():
		tab_bar.get_parent().move_child.call_deferred(tab_bar, tab_bar.get_parent().get_child_count() - 1)


func get_state_machine() -> UIStateMachine:
	return state_machine
