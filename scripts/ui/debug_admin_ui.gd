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


func _add_materials(quality: int, amount: int) -> void:
	if Main.instance and Main.instance.player_state_system:
		var state: Resource = Main.instance.player_state_system.get_state()
		if state:
			var current: int = state.kept_fish.get(quality, 0)
			state.kept_fish[quality] = maxi(current + amount, 0)


func _on_add_common_mats() -> void:
	_add_materials(0, 10)

func _on_add_uncommon_mats() -> void:
	_add_materials(1, 10)

func _on_add_rare_mats() -> void:
	_add_materials(2, 10)

func _on_add_epic_mats() -> void:
	_add_materials(3, 10)


func _on_reset_inventory() -> void:
	EquipmentManager.inventory.clear()
	EquipmentManager.loadout.clear()
	EquipmentManager._save_data()
	EquipmentManager._grant_starter_items()
	print("DEBUG: Inventory reset")
