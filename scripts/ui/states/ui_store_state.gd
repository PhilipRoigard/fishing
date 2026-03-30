extends UIStateNode

const SECTION_ORDER: Array[String] = ["Gems", "Bundles", "Premium"]
const SECTION_COLORS: Dictionary = {
	"Gems": Color(0.4, 0.8, 1.0),
	"Bundles": Color(1.0, 0.7, 0.2),
	"Premium": Color(0.9, 0.5, 1.0),
}

const TACKLE_BOX_PATHS: Array[String] = [
	"res://data/gacha/basic_tackle_box.tres",
	"res://data/gacha/premium_tackle_box.tres",
	"res://data/gacha/legendary_tackle_box.tres",
]

var content_container: VBoxContainer


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _setup_connections() -> void:
	pass


func _cleanup_connections() -> void:
	pass


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 40)
	margin.add_theme_constant_override("margin_bottom", 78)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(root_vbox)

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

	_populate_tackle_box_section()
	_populate_sections()



func _populate_tackle_box_section() -> void:
	var packs: Array[TackleBoxPackDefinition] = []
	for path: String in TACKLE_BOX_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var pack: TackleBoxPackDefinition = load(path) as TackleBoxPackDefinition
		if pack:
			packs.append(pack)

	if packs.is_empty():
		return

	var packs_row: HBoxContainer = HBoxContainer.new()
	packs_row.add_theme_constant_override("separation", 10)
	content_container.add_child(packs_row)

	for pack: TackleBoxPackDefinition in packs:
		var card: PanelContainer = _create_vending_card(pack)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		packs_row.add_child(card)


func _create_vending_card(pack: TackleBoxPackDefinition) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.18)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = Color(0.25, 0.25, 0.3)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.content_margin_left = 6
	style.content_margin_right = 6
	panel.add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var name_label: Label = Label.new()
	name_label.text = pack.display_name.replace("Tackle Box", "").strip_edges()
	if name_label.text == "":
		name_label.text = pack.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = pack.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 9)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	var icon_container: CenterContainer = CenterContainer.new()
	icon_container.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(icon_container)

	var chest_icon: TextureRect = TextureRect.new()
	chest_icon.texture = preload("res://resources/spritesheet/tackle_box_chest.png")
	chest_icon.custom_minimum_size = Vector2(72, 72)
	chest_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_container.add_child(chest_icon)

	var open_label: Label = Label.new()
	open_label.text = "Open x" + str(pack.items_per_pull)
	open_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	open_label.add_theme_font_size_override("font_size", 10)
	open_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	vbox.add_child(open_label)

	var pull_btn: Button = Button.new()
	pull_btn.custom_minimum_size = Vector2(0, 36)

	var currency_sheet: Texture2D = preload("res://resources/spritesheet/currency_icons.png")
	var gem_atlas: AtlasTexture = AtlasTexture.new()
	gem_atlas.atlas = currency_sheet
	gem_atlas.region = Rect2(96, 0, 32, 32)
	pull_btn.icon = gem_atlas
	pull_btn.text = " " + str(pack.gem_cost)
	pull_btn.add_theme_font_size_override("font_size", 14)
	pull_btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	pull_btn.expand_icon = true

	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.55, 0.3)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	btn_style.content_margin_left = 8
	btn_style.content_margin_right = 8
	btn_style.content_margin_top = 4
	btn_style.content_margin_bottom = 4
	pull_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover: StyleBoxFlat = btn_style.duplicate()
	btn_hover.bg_color = Color(0.25, 0.65, 0.35)
	pull_btn.add_theme_stylebox_override("hover", btn_hover)

	var btn_pressed: StyleBoxFlat = btn_style.duplicate()
	btn_pressed.bg_color = Color(0.15, 0.45, 0.25)
	pull_btn.add_theme_stylebox_override("pressed", btn_pressed)

	pull_btn.pressed.connect(_on_pull_pressed.bind(pack.id, pack.items_per_pull))
	vbox.add_child(pull_btn)

	return panel


func _on_pull_pressed(pack_id: String, pull_count: int) -> void:
	HapticManager.medium_tap()
	if not CurrencyManager:
		return

	var pack: TackleBoxPackDefinition = _find_pack_by_id(pack_id)
	if not pack:
		return

	if not CurrencyManager.can_afford_gems(pack.gem_cost):
		SignalBus.show_notification.emit("Not enough gems!", Color.RED)
		return

	CurrencyManager.spend_gems(pack.gem_cost)

	var results: Array = []
	for i: int in pull_count:
		var weights: Dictionary = pack.get_quality_weights()
		var total_weight: float = pack.get_total_weight()
		var roll: float = randf() * total_weight
		var cumulative: float = 0.0
		var pulled_quality: int = 0
		for quality_key: Variant in weights:
			cumulative += weights[quality_key]
			if roll <= cumulative:
				pulled_quality = quality_key as int
				break

		var pool: Array[String] = pack.item_pool_ids
		var pulled_item_id: String = pool[randi() % pool.size()] if not pool.is_empty() else "unknown_item"
		var item_type: String = "rod"
		if pulled_item_id.begins_with("hook"):
			item_type = "hook"
		elif pulled_item_id.begins_with("lure"):
			item_type = "lure"

		EquipmentManager.add_item(pulled_item_id, item_type, pulled_quality)
		results.append({"item_id": pulled_item_id, "quality": pulled_quality})

	SignalBus.tackle_box_pull_started.emit(pack_id)
	state_machine.push_state(UIStateMachine.State.TACKLE_BOX_REVEAL, results)


func _find_pack_by_id(pack_id: String) -> TackleBoxPackDefinition:
	for path: String in TACKLE_BOX_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var pack: TackleBoxPackDefinition = load(path) as TackleBoxPackDefinition
		if pack and pack.id == pack_id:
			return pack
	return null


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



func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
