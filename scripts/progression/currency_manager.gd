extends Node

var coins: int = 0
var gems: int = 0


func _ready() -> void:
	_load_currency.call_deferred()


func _load_currency() -> void:
	var main: Node = Engine.get_main_loop().root.get_node_or_null("Main")
	if not main:
		return
	var pss: Node = main.get("player_state_system")
	if not pss:
		return
	var state: Resource = pss.call("get_state")
	if state:
		coins = state.get("coins")
		gems = state.get("gems")
		_grant_starter_currency()


func _grant_starter_currency() -> void:
	if coins > 0 or gems > 0:
		return
	var save_path: String = "user://player_state.tres"
	if FileAccess.file_exists(save_path):
		return
	add_coins(100)
	add_gems(50)


func add_coins(amount: int) -> void:
	var previous: int = coins
	coins += amount
	_save_to_player_state()
	SignalBus.coins_changed.emit(previous, coins)


func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	var previous: int = coins
	coins -= amount
	_save_to_player_state()
	SignalBus.coins_changed.emit(previous, coins)
	return true


func can_afford_coins(amount: int) -> bool:
	return coins >= amount


func add_gems(amount: int) -> void:
	var previous: int = gems
	gems += amount
	_save_to_player_state()
	SignalBus.gems_changed.emit(previous, gems)


func spend_gems(amount: int) -> bool:
	if gems < amount:
		return false
	var previous: int = gems
	gems -= amount
	_save_to_player_state()
	SignalBus.gems_changed.emit(previous, gems)
	return true


func can_afford_gems(amount: int) -> bool:
	return gems >= amount


func _save_to_player_state() -> void:
	var main: Node = Engine.get_main_loop().root.get_node_or_null("Main")
	if not main:
		return
	var pss: Node = main.get("player_state_system")
	if not pss:
		return
	var state: Resource = pss.call("get_state")
	if state:
		state.set("coins", coins)
		state.set("gems", gems)
		SignalBus.save_requested.emit()
