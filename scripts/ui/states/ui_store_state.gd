extends UIStateNode

const SECTION_ORDER: Array[String] = ["Gems", "Bundles", "Premium"]
const SECTION_COLORS: Dictionary = {
	"Gems": Color(0.4, 0.8, 1.0),
	"Bundles": Color(1.0, 0.7, 0.2),
	"Premium": Color(0.9, 0.5, 1.0),
}

var coin_label: Label
var gem_label: Label
var content_container: VBoxContainer


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _setup_connections() -> void:
	SignalBus.coins_changed.connect(_on_coins_changed)
	SignalBus.gems_changed.connect(_on_gems_changed)


func _cleanup_connections() -> void:
	if SignalBus.coins_changed.is_connected(_on_coins_changed):
		SignalBus.coins_changed.disconnect(_on_coins_changed)
	if SignalBus.gems_changed.is_connected(_on_gems_changed):
		SignalBus.gems_changed.disconnect(_on_gems_changed)


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 8)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 8)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(root_vbox)

	_build_top_bar(root_vbox)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 20)
	scroll.add_child(content_container)

	_populate_sections()


func _build_top_bar(parent: VBoxContainer) -> void:
	var bar: HBoxContainer = HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	parent.add_child(bar)

	var back_btn: Button = Button.new()
	back_btn.text = "<"
	back_btn.custom_minimum_size = Vector2(32, 32)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_back)
	bar.add_child(back_btn)

	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)

	coin_label = Label.new()
	coin_label.text = "Coins: " + str(CurrencyManager.coins)
	coin_label.add_theme_font_size_override("font_size", 12)
	coin_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	bar.add_child(coin_label)

	gem_label = Label.new()
	gem_label.text = "Gems: " + str(CurrencyManager.gems)
	gem_label.add_theme_font_size_override("font_size", 12)
	gem_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	bar.add_child(gem_label)


func _populate_sections() -> void:
	var catalogue: Variant = null
	if GameResources.config:
		catalogue = GameResources.config.get("iap_catalogue")
	if not catalogue:
		return

	for section_name: String in SECTION_ORDER:
		var products: Array = catalogue.get_products_by_category(section_name)
		if products.is_empty():
			continue
		_build_section(section_name, products)


func _build_section(section_name: String, products: Array) -> void:
	var section_vbox: VBoxContainer = VBoxContainer.new()
	section_vbox.add_theme_constant_override("separation", 10)
	content_container.add_child(section_vbox)

	var header_container: VBoxContainer = VBoxContainer.new()
	header_container.add_theme_constant_override("separation", 4)
	section_vbox.add_child(header_container)

	var header_label: Label = Label.new()
	header_label.text = section_name.to_upper()
	header_label.add_theme_font_size_override("font_size", 18)
	header_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	header_container.add_child(header_label)

	var underline: ColorRect = ColorRect.new()
	underline.custom_minimum_size = Vector2(0, 3)
	underline.color = SECTION_COLORS.get(section_name, Color(0.5, 0.5, 0.5))
	header_container.add_child(underline)

	for product: Variant in products:
		var card: PanelContainer = _create_product_card(product)
		section_vbox.add_child(card)


func _create_product_card(product: Variant) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 70)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.16)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = Color(0.18, 0.22, 0.3)
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.content_margin_left = 12
	style.content_margin_right = 12
	panel.add_theme_stylebox_override("panel", style)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	row.add_child(info_vbox)

	var name_label: Label = Label.new()
	name_label.text = product.display_name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	info_vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = product.description
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_vbox.add_child(desc_label)

	var price_btn: Button = Button.new()
	price_btn.text = "$" + _format_price(product.store_price_usd)
	price_btn.custom_minimum_size = Vector2(80, 36)

	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.5, 0.3)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	btn_style.content_margin_left = 10
	btn_style.content_margin_right = 10
	price_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover_style: StyleBoxFlat = btn_style.duplicate()
	btn_hover_style.bg_color = Color(0.2, 0.6, 0.35)
	price_btn.add_theme_stylebox_override("hover", btn_hover_style)

	var btn_pressed_style: StyleBoxFlat = btn_style.duplicate()
	btn_pressed_style.bg_color = Color(0.1, 0.4, 0.25)
	price_btn.add_theme_stylebox_override("pressed", btn_pressed_style)

	price_btn.add_theme_font_size_override("font_size", 13)
	price_btn.pressed.connect(_on_buy_pressed.bind(product.id))
	row.add_child(price_btn)

	return panel


func _format_price(price_usd: float) -> String:
	if is_equal_approx(price_usd, floorf(price_usd)):
		return "%.0f" % price_usd
	return "%.2f" % price_usd


func _on_buy_pressed(product_id: String) -> void:
	HapticManager.medium_tap()
	state_machine.push_state(UIStateMachine.State.PURCHASING, {"product_id": product_id})
	PurchaseManager.purchase(product_id)


func _on_coins_changed(_previous: int, current: int) -> void:
	if coin_label:
		coin_label.text = "Coins: " + str(current)


func _on_gems_changed(_previous: int, current: int) -> void:
	if gem_label:
		gem_label.text = "Gems: " + str(current)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
