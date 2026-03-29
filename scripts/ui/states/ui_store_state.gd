extends UIStateNode

const CATEGORIES: Array[String] = ["Gems", "Bundles", "Premium"]

var product_list: VBoxContainer
var active_category: int = 0


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_products()


func exit() -> void:
	super()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 10)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 60)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Store"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var category_bar: HBoxContainer = HBoxContainer.new()
	category_bar.add_theme_constant_override("separation", 8)
	vbox.add_child(category_bar)

	for i: int in CATEGORIES.size():
		var btn: Button = Button.new()
		btn.text = CATEGORIES[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_category_pressed.bind(i))
		category_bar.add_child(btn)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	product_list = VBoxContainer.new()
	product_list.add_theme_constant_override("separation", 8)
	scroll.add_child(product_list)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _refresh_products() -> void:
	for child: Node in product_list.get_children():
		child.queue_free()

	var catalogue: Variant = null
	if GameResources.config:
		catalogue = GameResources.config.get("iap_catalogue")
	if not catalogue:
		return

	var category_name: String = CATEGORIES[active_category]
	var products: Array = catalogue.get_products_by_category(category_name)

	for product: Variant in products:
		var card: HBoxContainer = _create_product_card(product)
		product_list.add_child(card)


func _create_product_card(product: Variant) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info_vbox)

	var name_label: Label = Label.new()
	name_label.text = product.display_name
	info_vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = product.description
	desc_label.modulate = Color(0.7, 0.7, 0.7)
	info_vbox.add_child(desc_label)

	var buy_button: Button = Button.new()
	buy_button.text = "$" + str(product.store_price_usd)
	buy_button.custom_minimum_size = Vector2(90, 44)
	buy_button.pressed.connect(_on_buy_pressed.bind(product.id))
	row.add_child(buy_button)

	return row


func _on_category_pressed(index: int) -> void:
	active_category = index
	HapticManager.light_tap()
	_refresh_products()


func _on_buy_pressed(product_id: String) -> void:
	HapticManager.medium_tap()
	state_machine.push_state(UIStateMachine.State.PURCHASING, {"product_id": product_id})
	PurchaseManager.purchase(product_id)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
