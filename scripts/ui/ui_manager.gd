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
@onready var merge_state: UIStateNode = $MergeStateNode

var state_machine: UIStateMachine
var tab_bar: Control
var currency_bar: Control
var game_theme: Theme


func _ready() -> void:
	game_theme = preload("res://resources/ui/game_theme.tres")
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
	state_machine.add_state(UIStateMachine.State.MERGE, merge_state)


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


