extends CanvasLayer

@onready var loading_state: UIStateNode = $LoadingStateNode
@onready var main_menu_state: UIStateNode = $MainMenuStateNode
@onready var wharf_hub_state: UIStateNode = $WharfHubStateNode
@onready var fishing_game_state: UIStateNode = $FishingGameStateNode
@onready var catch_result_state: UIStateNode = $CatchResultStateNode
@onready var equipment_state: UIStateNode = $EquipmentStateNode
@onready var equipment_details_state: UIStateNode = $EquipmentDetailsStateNode
@onready var collection_log_state: UIStateNode = $CollectionLogStateNode
@onready var fish_details_state: UIStateNode = $FishDetailsStateNode
@onready var store_state: UIStateNode = $StoreStateNode
@onready var tackle_box_state: UIStateNode = $TackleBoxStateNode
@onready var tackle_box_reveal_state: UIStateNode = $TackleBoxRevealStateNode
@onready var settings_state: UIStateNode = $SettingsStateNode
@onready var pause_state: UIStateNode = $PauseStateNode
@onready var yes_no_popup_state: UIStateNode = $YesNoPopupStateNode
@onready var purchasing_state: UIStateNode = $PurchasingStateNode
@onready var bait_craft_state: UIStateNode = $BaitCraftStateNode
@onready var tooltip_state: UIStateNode = $TooltipStateNode

var state_machine: UIStateMachine
var tab_bar: Control
var currency_bar: Control
var game_theme: Theme


func _ready() -> void:
	game_theme = _build_theme()
	_apply_theme_to_states()
	_initialize_state_machine()
	_create_debug_ui()
	state_machine.change_state(UIStateMachine.State.LOADING)


func _apply_theme_to_states() -> void:
	for child: Node in get_children():
		if child is Control:
			(child as Control).theme = game_theme


func _initialize_state_machine() -> void:
	state_machine = UIStateMachine.new(self)
	state_machine.name = "UIStateMachine"
	add_child(state_machine)

	state_machine.add_state(UIStateMachine.State.LOADING, loading_state)
	state_machine.add_state(UIStateMachine.State.MAIN_MENU, main_menu_state)
	state_machine.add_state(UIStateMachine.State.WHARF_HUB, wharf_hub_state)
	state_machine.add_state(UIStateMachine.State.FISHING_GAME, fishing_game_state)
	state_machine.add_state(UIStateMachine.State.CATCH_RESULT, catch_result_state)
	state_machine.add_state(UIStateMachine.State.EQUIPMENT, equipment_state)
	state_machine.add_state(UIStateMachine.State.EQUIPMENT_DETAILS, equipment_details_state)
	state_machine.add_state(UIStateMachine.State.COLLECTION_LOG, collection_log_state)
	state_machine.add_state(UIStateMachine.State.FISH_DETAILS, fish_details_state)
	state_machine.add_state(UIStateMachine.State.STORE, store_state)
	state_machine.add_state(UIStateMachine.State.TACKLE_BOX, tackle_box_state)
	state_machine.add_state(UIStateMachine.State.TACKLE_BOX_REVEAL, tackle_box_reveal_state)
	state_machine.add_state(UIStateMachine.State.SETTINGS, settings_state)
	state_machine.add_state(UIStateMachine.State.PAUSE, pause_state)
	state_machine.add_state(UIStateMachine.State.YES_NO_POPUP, yes_no_popup_state)
	state_machine.add_state(UIStateMachine.State.PURCHASING, purchasing_state)
	state_machine.add_state(UIStateMachine.State.BAIT_CRAFT, bait_craft_state)
	state_machine.add_state(UIStateMachine.State.TOOLTIP, tooltip_state)


func _create_debug_ui() -> void:
	var debug_scene: PackedScene = preload("res://scenes/ui/components/debug_admin_ui.tscn")
	var debug_ui: Control = debug_scene.instantiate()
	debug_ui.theme = game_theme
	add_child(debug_ui)


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
