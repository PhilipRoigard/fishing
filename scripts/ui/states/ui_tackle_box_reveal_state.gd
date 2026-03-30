extends UIStateNode

const _item_card_scene: PackedScene = preload("res://scenes/ui/components/item_card.tscn")
const ITEM_REVEAL_DELAY: float = 0.15
const ITEM_POP_DURATION: float = 0.25

var _chest_texture: Texture2D = preload("res://resources/spritesheet/tackle_box_chest.png")

var darkenator: ColorRect
var chest_image: TextureRect
var glow: TextureRect
var item_grid: GridContainer
var continue_button: Button
var tap_label: Label

var rewards: Array = []
var item_cards: Array[ItemCard] = []
var _waiting_for_tap: bool = false
var _revealing: bool = false
var _reveal_complete: bool = false
var _reveal_index: int = 0
var _skip_requested: bool = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press"):
		if _waiting_for_tap:
			_open()
		elif _revealing:
			_skip_requested = true


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Array:
		rewards = meta
	elif meta is Dictionary:
		rewards = meta.get("results", [])

	item_cards.clear()
	_reveal_index = 0
	_skip_requested = false
	_revealing = false
	_reveal_complete = false

	_build_layout()
	_create_cards_hidden()
	_animate_entrance()


func exit() -> void:
	for card: ItemCard in item_cards:
		if is_instance_valid(card):
			card.queue_free()
	item_cards.clear()
	_clear_children()
	super()


func _build_layout() -> void:
	darkenator = ColorRect.new()
	darkenator.set_anchors_preset(Control.PRESET_FULL_RECT)
	darkenator.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(darkenator)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var transparent_style: StyleBoxFlat = StyleBoxFlat.new()
	transparent_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	panel.add_theme_stylebox_override("panel", transparent_style)
	add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 40)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 80)
	panel.add_child(margin)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(main_vbox)

	var chest_center: CenterContainer = CenterContainer.new()
	chest_center.custom_minimum_size = Vector2(0, 160)
	main_vbox.add_child(chest_center)

	var chest_anchor: Control = Control.new()
	chest_center.add_child(chest_anchor)

	var gradient: Gradient = Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([Color(1.0, 0.96, 0.33, 1.0), Color(1.0, 0.76, 0.04, 0.0)])

	var glow_texture: GradientTexture2D = GradientTexture2D.new()
	glow_texture.gradient = gradient
	glow_texture.width = 300
	glow_texture.height = 300
	glow_texture.fill = GradientTexture2D.FILL_RADIAL
	glow_texture.fill_from = Vector2(0.5, 0.5)
	glow_texture.fill_to = Vector2(0.85, 0.85)

	glow = TextureRect.new()
	glow.texture = glow_texture
	glow.offset_left = -150
	glow.offset_top = -150
	glow.offset_right = 150
	glow.offset_bottom = 150
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_anchor.add_child(glow)

	chest_image = TextureRect.new()
	chest_image.texture = _chest_texture
	chest_image.custom_minimum_size = Vector2(150, 150)
	chest_image.offset_left = -75
	chest_image.offset_top = -75
	chest_image.offset_right = 75
	chest_image.offset_bottom = 75
	chest_image.pivot_offset = Vector2(75, 75)
	chest_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	chest_image.z_index = 1
	chest_anchor.add_child(chest_image)

	item_grid = GridContainer.new()
	item_grid.columns = 4
	item_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	item_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_grid.add_theme_constant_override("h_separation", 6)
	item_grid.add_theme_constant_override("v_separation", 6)
	main_vbox.add_child(item_grid)

	var bottom_vbox: VBoxContainer = VBoxContainer.new()
	bottom_vbox.custom_minimum_size = Vector2(0, 50)
	bottom_vbox.alignment = BoxContainer.ALIGNMENT_END
	main_vbox.add_child(bottom_vbox)

	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.visible = false
	continue_button.custom_minimum_size = Vector2(250, 50)
	continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	continue_button.add_theme_font_size_override("font_size", 22)

	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.55, 0.25, 0.2)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.content_margin_top = 10
	btn_style.content_margin_bottom = 10
	continue_button.add_theme_stylebox_override("normal", btn_style)

	var btn_hover: StyleBoxFlat = btn_style.duplicate()
	btn_hover.bg_color = Color(0.65, 0.3, 0.25)
	continue_button.add_theme_stylebox_override("hover", btn_hover)

	continue_button.pressed.connect(_on_continue_pressed)
	bottom_vbox.add_child(continue_button)

	tap_label = Label.new()
	tap_label.text = "Tap to Open"
	tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tap_label.add_theme_font_size_override("font_size", 28)
	bottom_vbox.add_child(tap_label)

	_waiting_for_tap = true


func _animate_entrance() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(darkenator, "color", Color(0.0, 0.0, 0.0, 0.9), 0.15)


func _open() -> void:
	_waiting_for_tap = false
	tap_label.visible = false
	_bounce_chest()
	await get_tree().process_frame
	_start_reveal()


func _create_cards_hidden() -> void:
	for result: Variant in rewards:
		var item_id: String = ""
		var quality: int = 0
		var item_type: String = "rod"

		if result is TackleBoxPullResult:
			var pull: TackleBoxPullResult = result as TackleBoxPullResult
			item_id = pull.item_id
			quality = pull.quality
		elif result is Dictionary:
			item_id = result.get("item_id", "")
			quality = result.get("quality", 0)

		if item_id.begins_with("hook"):
			item_type = "hook"
		elif item_id.begins_with("lure"):
			item_type = "lure"

		var card: ItemCard = _item_card_scene.instantiate() as ItemCard
		var quality_color: Color = Enums.QUALITY_COLORS.get(quality, Color.WHITE)

		card.modulate.a = 0.0
		card.scale = Vector2(0.3, 0.3)
		card.pivot_offset = Vector2(35, 35)

		var icon_texture: Texture2D = _get_item_icon(item_id, item_type)
		card.set_item_data.call_deferred(item_id, "", icon_texture, 1, quality_color)

		item_grid.add_child(card)
		item_cards.append(card)


func _start_reveal() -> void:
	_revealing = true
	_reveal_index = 0
	_reveal_next_card()


func _reveal_next_card() -> void:
	if _skip_requested:
		_show_all_remaining()
		return

	if _reveal_index >= item_cards.size():
		_on_reveal_complete()
		return

	var card: ItemCard = item_cards[_reveal_index]
	_reveal_index += 1

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "modulate:a", 1.0, ITEM_POP_DURATION * 0.5)
	tween.tween_property(card, "scale", Vector2(1.15, 1.15), ITEM_POP_DURATION * 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(false)
	tween.tween_property(card, "scale", Vector2.ONE, ITEM_POP_DURATION * 0.4)

	_bounce_chest()
	tween.finished.connect(_reveal_next_card)


func _show_all_remaining() -> void:
	for i: int in range(_reveal_index, item_cards.size()):
		var card: ItemCard = item_cards[i]
		card.modulate.a = 1.0
		card.scale = Vector2.ONE
	_on_reveal_complete()


func _on_reveal_complete() -> void:
	_revealing = false
	_reveal_complete = true
	_skip_requested = false
	continue_button.visible = true


func _on_continue_pressed() -> void:
	HapticManager.success_feedback()
	_back()


func _bounce_chest() -> void:
	var chest_tween: Tween = create_tween()
	chest_tween.tween_property(chest_image, "scale", Vector2(1.15, 1.15), 0.12)
	chest_tween.tween_property(chest_image, "scale", Vector2.ONE, 0.12)


func _get_item_icon(item_id: String, equipment_type: String) -> Texture2D:
	var folley: Texture2D = preload("res://assets/sprites/items/Folley_Sprite_Sheet.png")
	match equipment_type:
		"rod":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = folley
			match item_id:
				"bronze_rod": atlas.region = Rect2(65, 2, 15, 15)
				"silver_rod": atlas.region = Rect2(81, 2, 15, 15)
				"gold_rod": atlas.region = Rect2(81, 2, 15, 15)
				_: atlas.region = Rect2(49, 2, 15, 14)
			return atlas
		"hook":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = folley
			match item_id:
				"barbed_hook": atlas.region = Rect2(17, 1, 14, 16)
				"titanium_hook": atlas.region = Rect2(33, 1, 14, 16)
				_: atlas.region = Rect2(1, 0, 14, 17)
			return atlas
		"lure":
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = folley
			match item_id:
				"shiny_lure": atlas.region = Rect2(113, 1, 15, 16)
				"golden_lure": atlas.region = Rect2(128, 1, 15, 16)
				_: atlas.region = Rect2(97, 3, 13, 13)
			return atlas
	return preload("res://assets/sprites/items/Bait_01_green.png")


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
