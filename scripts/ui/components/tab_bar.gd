extends HBoxContainer

signal tab_changed(tab_index: int)

enum Tab {
	INVENTORY = 0,
	STORE = 1,
	HOME = 2,
	FISH = 3,
	SETTINGS = 4,
}

const TAB_LABELS: Dictionary = {
	Tab.INVENTORY: "Inventory",
	Tab.STORE: "Store",
	Tab.HOME: "Home",
	Tab.FISH: "Fish",
	Tab.SETTINGS: "Settings",
}

const TAB_STATES: Dictionary = {
	Tab.INVENTORY: UIStateMachine.State.EQUIPMENT,
	Tab.STORE: UIStateMachine.State.STORE,
	Tab.HOME: -1,
	Tab.FISH: UIStateMachine.State.COLLECTION_LOG,
	Tab.SETTINGS: UIStateMachine.State.SETTINGS,
}

@onready var _normal_style: StyleBox = preload("res://resources/ui/Style Boxes/StyleBoxFlat/tab_wood_normal.tres")
@onready var _selected_style: StyleBox = preload("res://resources/ui/Style Boxes/StyleBoxFlat/tab_wood_selected.tres")

@onready var inventory_tab: Button = %TabInventory
@onready var store_tab: Button = %TabStore
@onready var home_tab: Button = %TabHome
@onready var fish_tab: Button = %TabFish
@onready var settings_tab: Button = %TabSettings

var expanded_ratio: float = 1.5
var collapsed_ratio: float = 1.0

var _buttons: Dictionary = {}
var _current_tab: Tab = Tab.HOME


func _ready() -> void:
	_buttons = {
		Tab.INVENTORY: inventory_tab,
		Tab.STORE: store_tab,
		Tab.HOME: home_tab,
		Tab.FISH: fish_tab,
		Tab.SETTINGS: settings_tab,
	}
	SignalBus.tab_should_change.connect(_on_tab_should_change)


func _select_tab(index: Tab) -> void:
	if _current_tab == index:
		return

	_current_tab = index
	for tab: int in Tab.values():
		_apply_tab_state(tab as Tab, tab == _current_tab)

	tab_changed.emit(index)


func select_home() -> void:
	_current_tab = Tab.HOME
	for tab: int in Tab.values():
		_apply_tab_state(tab as Tab, tab == _current_tab)


func _apply_tab_state(index: Tab, is_selected: bool) -> void:
	var button: Button = _buttons[index]
	button.add_theme_stylebox_override("normal", _selected_style if is_selected else _normal_style)
	button.text = TAB_LABELS[index] if is_selected else ""
	button.size_flags_stretch_ratio = expanded_ratio if is_selected else collapsed_ratio


func _on_tab_should_change(tab_index: int) -> void:
	if tab_index >= 0 and tab_index < Tab.size():
		_select_tab(tab_index as Tab)


func _on_inventory_pressed() -> void:
	_select_tab(Tab.INVENTORY)


func _on_store_pressed() -> void:
	_select_tab(Tab.STORE)


func _on_home_pressed() -> void:
	_select_tab(Tab.HOME)


func _on_fish_pressed() -> void:
	_select_tab(Tab.FISH)


func _on_settings_pressed() -> void:
	_select_tab(Tab.SETTINGS)
