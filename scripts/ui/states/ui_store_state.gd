extends UIStateNode

const SECTION_ORDER: Array[String] = ["Gems", "Bundles", "Premium"]
const SECTION_COLORS: Dictionary = {
	"Gems": Color(0.4, 0.8, 1.0),
	"Bundles": Color(1.0, 0.7, 0.2),
	"Premium": Color(0.9, 0.5, 1.0),
}

const COMMON_PACK_PATH: String = "res://data/gacha/basic_tackle_box.tres"
const PREMIUM_PACK_PATH: String = "res://data/gacha/premium_tackle_box.tres"
const PREMIUM_SINGLE_COST: int = 300
const PREMIUM_MEGA_COST: int = 2600
const PREMIUM_MEGA_COUNT: int = 10

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
	var section_vbox: VBoxContainer = VBoxContainer.new()
	section_vbox.add_theme_constant_override("separation", 10)
	content_container.add_child(section_vbox)

	var header: PanelContainer = _create_section_header("Tackle")
	section_vbox.add_child(header)

	var packs_row: HBoxContainer = HBoxContainer.new()
	packs_row.add_theme_constant_override("separation", 10)
	section_vbox.add_child(packs_row)

	var common_card: PanelContainer = _create_common_card()
	common_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	packs_row.add_child(common_card)

	var premium_card: PanelContainer = _create_premium_card()
	premium_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	packs_row.add_child(premium_card)


func _make_card_style() -> StyleBoxFlat:
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
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.content_margin_left = 8
	style.content_margin_right = 8
	return style


func _make_green_btn_style() -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = Color(0.2, 0.55, 0.3)
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s


func _create_common_card() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_card_style())

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Common"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var desc: Label = Label.new()
	desc.text = "Contains a Common or Uncommon item"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc)

	var icon_center: CenterContainer = CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(icon_center)
	var chest_icon: TextureRect = TextureRect.new()
	chest_icon.texture = preload("res://resources/spritesheet/tackle_box_chest.png")
	chest_icon.custom_minimum_size = Vector2(64, 64)
	chest_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_center.add_child(chest_icon)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var open_label: Label = Label.new()
	open_label.text = "Open x1"
	open_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	open_label.add_theme_font_size_override("font_size", 11)
	open_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	vbox.add_child(open_label)

	var ad_btn: Button = Button.new()
	ad_btn.text = "  Watch Ad"
	ad_btn.custom_minimum_size = Vector2(0, 36)
	ad_btn.add_theme_font_size_override("font_size", 14)
	var ad_style: StyleBoxFlat = _make_green_btn_style()
	ad_btn.add_theme_stylebox_override("normal", ad_style)
	var ad_hover: StyleBoxFlat = ad_style.duplicate()
	ad_hover.bg_color = Color(0.25, 0.65, 0.35)
	ad_btn.add_theme_stylebox_override("hover", ad_hover)
	ad_btn.pressed.connect(_on_ad_pull_pressed)
	vbox.add_child(ad_btn)

	return panel


func _create_premium_card() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_card_style())

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Premium"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var desc: Label = Label.new()
	desc.text = "Contains a Uncommon, Rare, or Epic item"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc)

	var icon_center: CenterContainer = CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(icon_center)
	var chest_icon: TextureRect = TextureRect.new()
	chest_icon.texture = preload("res://resources/spritesheet/tackle_box_chest.png")
	chest_icon.custom_minimum_size = Vector2(64, 64)
	chest_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_center.add_child(chest_icon)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var open_labels: HBoxContainer = HBoxContainer.new()
	vbox.add_child(open_labels)
	var ol1: Label = Label.new()
	ol1.text = "Open x1"
	ol1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ol1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ol1.add_theme_font_size_override("font_size", 11)
	ol1.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	open_labels.add_child(ol1)
	var ol2: Label = Label.new()
	ol2.text = "Open x10"
	ol2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ol2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ol2.add_theme_font_size_override("font_size", 11)
	ol2.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	open_labels.add_child(ol2)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	var currency_sheet: Texture2D = preload("res://resources/spritesheet/currency_icons.png")
	var gem_atlas: AtlasTexture = AtlasTexture.new()
	gem_atlas.atlas = currency_sheet
	gem_atlas.region = Rect2(96, 0, 32, 32)

	var single_btn: Button = Button.new()
	single_btn.custom_minimum_size = Vector2(0, 36)
	single_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	single_btn.icon = gem_atlas
	single_btn.text = " " + str(PREMIUM_SINGLE_COST)
	single_btn.add_theme_font_size_override("font_size", 14)
	single_btn.expand_icon = true
	var s1: StyleBoxFlat = _make_green_btn_style()
	single_btn.add_theme_stylebox_override("normal", s1)
	var s1h: StyleBoxFlat = s1.duplicate()
	s1h.bg_color = Color(0.25, 0.65, 0.35)
	single_btn.add_theme_stylebox_override("hover", s1h)
	single_btn.pressed.connect(_on_premium_single_pressed)
	btn_row.add_child(single_btn)

	var mega_btn: Button = Button.new()
	mega_btn.custom_minimum_size = Vector2(0, 36)
	mega_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var gem_atlas2: AtlasTexture = AtlasTexture.new()
	gem_atlas2.atlas = currency_sheet
	gem_atlas2.region = Rect2(96, 0, 32, 32)
	mega_btn.icon = gem_atlas2
	mega_btn.text = " " + str(PREMIUM_MEGA_COST)
	mega_btn.add_theme_font_size_override("font_size", 14)
	mega_btn.expand_icon = true
	var s2: StyleBoxFlat = _make_green_btn_style()
	mega_btn.add_theme_stylebox_override("normal", s2)
	var s2h: StyleBoxFlat = s2.duplicate()
	s2h.bg_color = Color(0.25, 0.65, 0.35)
	mega_btn.add_theme_stylebox_override("hover", s2h)
	mega_btn.pressed.connect(_on_premium_mega_pressed)
	btn_row.add_child(mega_btn)

	return panel


func _on_ad_pull_pressed() -> void:
	HapticManager.medium_tap()
	_do_pull(COMMON_PACK_PATH, 1)


func _on_premium_single_pressed() -> void:
	HapticManager.medium_tap()
	if not CurrencyManager.can_afford_gems(PREMIUM_SINGLE_COST):
		SignalBus.show_notification.emit("Not enough gems!", Color.RED)
		return
	CurrencyManager.spend_gems(PREMIUM_SINGLE_COST)
	_do_pull(PREMIUM_PACK_PATH, 1)


func _on_premium_mega_pressed() -> void:
	HapticManager.medium_tap()
	if not CurrencyManager.can_afford_gems(PREMIUM_MEGA_COST):
		SignalBus.show_notification.emit("Not enough gems!", Color.RED)
		return
	CurrencyManager.spend_gems(PREMIUM_MEGA_COST)
	_do_pull(PREMIUM_PACK_PATH, PREMIUM_MEGA_COUNT)


func _do_pull(pack_path: String, count: int) -> void:
	if not ResourceLoader.exists(pack_path):
		return
	var pack: TackleBoxPackDefinition = load(pack_path) as TackleBoxPackDefinition
	if not pack:
		return

	var results: Array = []
	for i: int in count:
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
		var item_type: String = _detect_item_type(pulled_item_id)

		var new_uuid: String = EquipmentManager.add_item(pulled_item_id, item_type, pulled_quality)
		results.append({"item_id": pulled_item_id, "quality": pulled_quality, "uuid": new_uuid})

	SignalBus.tackle_box_pull_started.emit(pack.id)
	state_machine.push_state(UIStateMachine.State.TACKLE_BOX_REVEAL, results)



func _detect_item_type(item_id: String) -> String:
	if GameResources.config and GameResources.config.equipment_catalogue:
		var cat: EquipmentCatalogue = GameResources.config.equipment_catalogue
		if cat.get_rod_by_id(item_id):
			return "rod"
		if cat.get_hook_by_id(item_id):
			return "hook"
		if cat.get_lure_by_id(item_id):
			return "lure"
		if cat.get_bait_by_id(item_id):
			return "bait"
	return "rod"


func _create_section_header(title: String) -> PanelContainer:
	var header_scene: PackedScene = preload("res://scenes/ui/components/section_header.tscn")
	var header: PanelContainer = header_scene.instantiate() as PanelContainer
	var label: Label = header.get_node("%TitleLabel")
	label.text = title
	return header


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

	var header: PanelContainer = _create_section_header(section_name)
	section_vbox.add_child(header)

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
