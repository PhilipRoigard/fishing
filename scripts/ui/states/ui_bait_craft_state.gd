extends UIStateNode

const MATERIALS_PER_CRAFT: int = 3

const QUALITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic"]
const QUALITY_COLORS: Array[Color] = [
	Color(0.6, 0.6, 0.6),
	Color(0.2, 0.8, 0.2),
	Color(0.2, 0.6, 1.0),
	Color(0.7, 0.3, 1.0),
]

var _bait_textures: Array[Texture2D] = [
	preload("res://assets/sprites/items/Bait_01.png"),
	preload("res://assets/sprites/items/Bait_01_blue.png"),
	preload("res://assets/sprites/items/Bait_01_pink.png"),
	preload("res://assets/sprites/items/Bait_01_green.png"),
]

var material_labels: Array[Label] = []
var bait_labels: Array[Label] = []
var craft_buttons: Array[Button] = []


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_display()


func exit() -> void:
	super()
	material_labels.clear()
	bait_labels.clear()
	craft_buttons.clear()
	_clear_children()


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

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	_build_bait_section(vbox)
	_build_materials_section(vbox)
	_build_craft_section(vbox)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _build_section_header(parent: VBoxContainer, title_text: String, color: Color) -> void:
	var header: VBoxContainer = VBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	parent.add_child(header)

	var label: Label = Label.new()
	label.text = title_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	header.add_child(label)

	var underline: ColorRect = ColorRect.new()
	underline.custom_minimum_size = Vector2(0, 2)
	underline.color = color
	header.add_child(underline)


func _build_bait_section(parent: VBoxContainer) -> void:
	_build_section_header(parent, "Equipped Bait", Color(0.4, 0.8, 1.0))

	for quality: int in QUALITY_NAMES.size():
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		parent.add_child(row)

		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = Vector2(28, 28)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.texture = _bait_textures[quality]
		row.add_child(icon)

		var name_lbl: Label = Label.new()
		name_lbl.text = QUALITY_NAMES[quality] + " Bait:"
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", QUALITY_COLORS[quality])
		name_lbl.custom_minimum_size = Vector2(130, 0)
		row.add_child(name_lbl)

		var count_lbl: Label = Label.new()
		count_lbl.text = "0"
		count_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(count_lbl)
		bait_labels.append(count_lbl)


func _build_materials_section(parent: VBoxContainer) -> void:
	_build_section_header(parent, "Fish Materials", Color(1.0, 0.84, 0.0))

	for quality: int in QUALITY_NAMES.size():
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		parent.add_child(row)

		var name_lbl: Label = Label.new()
		name_lbl.text = QUALITY_NAMES[quality] + " Material:"
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", QUALITY_COLORS[quality])
		name_lbl.custom_minimum_size = Vector2(160, 0)
		row.add_child(name_lbl)

		var count_lbl: Label = Label.new()
		count_lbl.text = "0"
		count_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(count_lbl)
		material_labels.append(count_lbl)


func _build_craft_section(parent: VBoxContainer) -> void:
	_build_section_header(parent, "Craft", Color(0.3, 0.85, 0.5))

	for quality: int in QUALITY_NAMES.size():
		var btn: Button = Button.new()
		btn.text = "Craft " + QUALITY_NAMES[quality] + " Bait (3 materials)"
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.icon = _bait_textures[quality]
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_craft_pressed.bind(quality))
		parent.add_child(btn)
		craft_buttons.append(btn)


func _refresh_display() -> void:
	var state: PlayerState = _get_player_state()
	if not state:
		return

	for quality: int in QUALITY_NAMES.size():
		var mat_count: int = state.kept_fish.get(quality, 0)
		var bait_count: int = state.bait_inventory.get(quality, 0)

		if quality < material_labels.size():
			material_labels[quality].text = str(mat_count)
		if quality < bait_labels.size():
			bait_labels[quality].text = str(bait_count)
		if quality < craft_buttons.size():
			craft_buttons[quality].disabled = mat_count < MATERIALS_PER_CRAFT
			craft_buttons[quality].text = "Craft " + QUALITY_NAMES[quality] + " Bait (" + str(mat_count) + "/3)"


func _on_craft_pressed(quality: int) -> void:
	HapticManager.light_tap()
	var state: PlayerState = _get_player_state()
	if not state:
		return

	var mat_count: int = state.kept_fish.get(quality, 0)
	if mat_count < MATERIALS_PER_CRAFT:
		return

	state.kept_fish[quality] = mat_count - MATERIALS_PER_CRAFT
	var current_bait: int = state.bait_inventory.get(quality, 0)
	state.bait_inventory[quality] = current_bait + 1
	_refresh_display()


func _get_player_state() -> PlayerState:
	if Main.instance and Main.instance.player_state_system:
		return Main.instance.player_state_system.get_state()
	return null


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
