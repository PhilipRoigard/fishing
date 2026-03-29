extends HBoxContainer

signal tab_changed(tab_index: int)

const TAB_LABELS: Array[String] = ["Fish", "Equipment", "Store", "Tackle Box"]
const TAB_STATES: Array[int] = [
	UIStateMachine.State.COLLECTION_LOG,
	UIStateMachine.State.EQUIPMENT,
	UIStateMachine.State.STORE,
	UIStateMachine.State.TACKLE_BOX,
]

@export var active_color: Color = Color(0.2, 0.6, 1.0)
@export var inactive_color: Color = Color(0.5, 0.5, 0.5)

var active_tab_index: int = -1
var tab_buttons: Array[Button] = []


func _ready() -> void:
	_build_tabs()
	SignalBus.tab_should_change.connect(_on_tab_should_change)


func _build_tabs() -> void:
	for i: int in TAB_LABELS.size():
		var btn: Button = Button.new()
		btn.text = TAB_LABELS[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 48
		btn.pressed.connect(_on_tab_pressed.bind(i))
		add_child(btn)
		tab_buttons.append(btn)
	_update_tab_visuals()


func _on_tab_pressed(index: int) -> void:
	if index == active_tab_index:
		return
	active_tab_index = index
	_update_tab_visuals()
	tab_changed.emit(index)
	HapticManager.light_tap()


func _on_tab_should_change(tab_index: int) -> void:
	if tab_index >= 0 and tab_index < tab_buttons.size():
		_on_tab_pressed(tab_index)


func set_active_tab(index: int) -> void:
	active_tab_index = index
	_update_tab_visuals()


func _update_tab_visuals() -> void:
	for i: int in tab_buttons.size():
		var btn: Button = tab_buttons[i]
		btn.modulate = active_color if i == active_tab_index else inactive_color
