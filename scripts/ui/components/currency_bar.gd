extends PanelContainer

@export var animation_duration: float = 0.4

var coin_label: Label
var gem_label: Label
var displayed_coins: int = 0
var displayed_gems: int = 0
var coin_tween: Tween
var gem_tween: Tween

var coin_icon_texture: AtlasTexture
var gem_icon_texture: AtlasTexture


func _ready() -> void:
	_setup_icons()
	_build_layout()
	_sync_initial_values()
	SignalBus.coins_changed.connect(_on_coins_changed)
	SignalBus.gems_changed.connect(_on_gems_changed)


func _setup_icons() -> void:
	var currency_sheet: Texture2D = preload("res://resources/spritesheet/currency_icons.png")
	coin_icon_texture = AtlasTexture.new()
	coin_icon_texture.atlas = currency_sheet
	coin_icon_texture.region = Rect2(0, 0, 32, 32)

	gem_icon_texture = AtlasTexture.new()
	gem_icon_texture.atlas = currency_sheet
	gem_icon_texture.region = Rect2(96, 0, 32, 32)


func _build_layout() -> void:
	var wood_style: StyleBoxFlat = StyleBoxFlat.new()
	wood_style.bg_color = Color(0.28, 0.2, 0.12, 0.92)
	wood_style.border_color = Color(0.4, 0.3, 0.18)
	wood_style.border_width_bottom = 2
	wood_style.content_margin_top = 4
	wood_style.content_margin_bottom = 6
	wood_style.content_margin_left = 12
	wood_style.content_margin_right = 12
	add_theme_stylebox_override("panel", wood_style)

	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0
	offset_left = 0
	offset_top = 0
	offset_right = 0

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin())
	margin.add_theme_constant_override("margin_bottom", 2)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)

	var coin_container: HBoxContainer = HBoxContainer.new()
	coin_container.add_theme_constant_override("separation", 6)
	hbox.add_child(coin_container)

	var coin_icon: TextureRect = TextureRect.new()
	coin_icon.texture = coin_icon_texture
	coin_icon.custom_minimum_size = Vector2(24, 24)
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_container.add_child(coin_icon)

	coin_label = Label.new()
	coin_label.text = "0"
	coin_label.add_theme_font_size_override("font_size", 18)
	coin_container.add_child(coin_label)

	var gem_container: HBoxContainer = HBoxContainer.new()
	gem_container.add_theme_constant_override("separation", 6)
	hbox.add_child(gem_container)

	var gem_icon: TextureRect = TextureRect.new()
	gem_icon.texture = gem_icon_texture
	gem_icon.custom_minimum_size = Vector2(24, 24)
	gem_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gem_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gem_container.add_child(gem_icon)

	gem_label = Label.new()
	gem_label.text = "0"
	gem_label.add_theme_font_size_override("font_size", 18)
	gem_container.add_child(gem_label)


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
