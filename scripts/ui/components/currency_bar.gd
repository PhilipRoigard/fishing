extends HBoxContainer

@export var animation_duration: float = 0.4

var coin_label: Label
var gem_label: Label
var displayed_coins: int = 0
var displayed_gems: int = 0
var coin_tween: Tween
var gem_tween: Tween


func _ready() -> void:
	_build_layout()
	_sync_initial_values()
	SignalBus.coins_changed.connect(_on_coins_changed)
	SignalBus.gems_changed.connect(_on_gems_changed)


func _build_layout() -> void:
	var coin_icon: Label = Label.new()
	coin_icon.text = "Coins:"
	add_child(coin_icon)

	coin_label = Label.new()
	coin_label.text = "0"
	coin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(coin_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size.x = 20
	add_child(spacer)

	var gem_icon: Label = Label.new()
	gem_icon.text = "Gems:"
	add_child(gem_icon)

	gem_label = Label.new()
	gem_label.text = "0"
	gem_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(gem_label)


func _sync_initial_values() -> void:
	displayed_coins = CurrencyManager.coins
	displayed_gems = CurrencyManager.gems
	coin_label.text = str(displayed_coins)
	gem_label.text = str(displayed_gems)


func _on_coins_changed(_previous: int, current: int) -> void:
	_animate_value_change(true, current)


func _on_gems_changed(_previous: int, current: int) -> void:
	_animate_value_change(false, current)


func _animate_value_change(is_coins: bool, target: int) -> void:
	if is_coins:
		if coin_tween and coin_tween.is_valid():
			coin_tween.kill()
		coin_tween = create_tween()
		coin_tween.tween_method(_update_coin_display, displayed_coins, target, animation_duration)
		displayed_coins = target
	else:
		if gem_tween and gem_tween.is_valid():
			gem_tween.kill()
		gem_tween = create_tween()
		gem_tween.tween_method(_update_gem_display, displayed_gems, target, animation_duration)
		displayed_gems = target


func _update_coin_display(value: int) -> void:
	coin_label.text = str(value)


func _update_gem_display(value: int) -> void:
	gem_label.text = str(value)
