extends Control

@onready var coins_amount_label: Label = %CoinsAmountLabel
@onready var gems_amount_label: Label = %GemsAmountLabel

var active_touches: int = 0


func _ready() -> void:
	if not OS.has_feature("debug") and not OS.has_feature("editor"):
		queue_free()
		return
	visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_visibility()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches += 1
		else:
			active_touches -= 1
			active_touches = maxi(active_touches, 0)

		if active_touches >= 4:
			active_touches = 0
			toggle_visibility()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible:
		return
	_update_currency_displays()


func toggle_visibility() -> void:
	visible = not visible


func _update_currency_displays() -> void:
	if coins_amount_label:
		coins_amount_label.text = "Current: %d" % CurrencyManager.coins
	if gems_amount_label:
		gems_amount_label.text = "Current: %d" % CurrencyManager.gems


func _on_remove_coins_1000() -> void:
	CurrencyManager.spend_coins(1000)

func _on_remove_coins_100() -> void:
	CurrencyManager.spend_coins(100)

func _on_add_coins_100() -> void:
	CurrencyManager.add_coins(100)

func _on_add_coins_1000() -> void:
	CurrencyManager.add_coins(1000)

func _on_remove_gems_1000() -> void:
	CurrencyManager.spend_gems(1000)

func _on_remove_gems_100() -> void:
	CurrencyManager.spend_gems(100)

func _on_add_gems_100() -> void:
	CurrencyManager.add_gems(100)

func _on_add_gems_1000() -> void:
	CurrencyManager.add_gems(1000)


func _on_reset_inventory() -> void:
	EquipmentManager.inventory.clear()
	EquipmentManager.loadout.clear()
	EquipmentManager._save_data()
	EquipmentManager._grant_starter_items()
	print("DEBUG: Inventory reset")
