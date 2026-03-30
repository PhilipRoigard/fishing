extends UIStateNode

const FISH_ATLAS: Texture2D = preload("res://assets/sprites/fish/FishGame_Fish_Sprite_Sheet.png")
const FISH_ATLAS_REGIONS: Dictionary = {
	"sardine": Rect2(0, 0, 16, 16),
	"snapper": Rect2(16, 0, 16, 16),
	"anchovy": Rect2(0, 16, 16, 16),
	"herring": Rect2(16, 16, 16, 16),
	"pufferfish": Rect2(32, 16, 16, 16),
	"clownfish": Rect2(48, 16, 16, 16),
	"flounder": Rect2(0, 32, 16, 16),
	"tuna": Rect2(16, 32, 16, 16),
	"trevally": Rect2(32, 32, 16, 16),
	"mackerel": Rect2(64, 16, 16, 16),
	"perch": Rect2(80, 0, 16, 16),
	"barramundi": Rect2(96, 0, 16, 16),
	"marlin": Rect2(96, 32, 16, 16),
	"swordfish": Rect2(80, 16, 16, 16),
	"napoleon_wrasse": Rect2(96, 16, 16, 16),
	"giant_trevally": Rect2(48, 0, 16, 16),
	"manta_ray": Rect2(112, 16, 16, 16),
	"great_white_shark": Rect2(112, 32, 16, 16),
	"sunfish": Rect2(80, 32, 16, 16),
	"whale_shark": Rect2(64, 32, 16, 16),
}

var grid: GridContainer
var completion_label: Label


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_grid()


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
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 40)
	margin.add_theme_constant_override("margin_bottom", 78)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Collection Log"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	completion_label = Label.new()
	completion_label.text = "0/0"
	completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(completion_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_highlight", StyleBoxEmpty.new())
	scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber_pressed", StyleBoxEmpty.new())
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)


func _refresh_grid() -> void:
	for child: Node in grid.get_children():
		child.queue_free()

	if not Main.instance or not Main.instance.database_system:
		return

	var fish_db: FishDatabase = null
	if GameResources.config:
		fish_db = GameResources.config.fish_database

	if not fish_db:
		return

	var state: PlayerState = null
	if Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()

	var caught_count: int = 0
	var total_count: int = fish_db.fish.size()

	for fish_data: FishData in fish_db.fish:
		var times_caught: int = 0
		if state:
			times_caught = state.collection_log.get(fish_data.id, 0)
		if times_caught > 0:
			caught_count += 1

		var cell: PanelContainer = _create_fish_cell(fish_data, times_caught)
		grid.add_child(cell)

	if completion_label:
		var pct: int = 0
		if total_count > 0:
			pct = int((float(caught_count) / float(total_count)) * 100.0)
		completion_label.text = str(caught_count) + "/" + str(total_count) + " (" + str(pct) + "%)"


func _get_rarity_color(rarity: int) -> Color:
	match rarity:
		Enums.Rarity.UNCOMMON:
			return Color(0.2, 0.8, 0.2)
		Enums.Rarity.RARE:
			return Color(0.2, 0.6, 1.0)
		Enums.Rarity.LEGENDARY:
			return Color(1.0, 0.84, 0.0)
	return Color(0.6, 0.6, 0.6)


func _create_fish_cell(fish_data: FishData, times_caught: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(100, 100)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	if times_caught > 0:
		var rarity_color: Color = _get_rarity_color(fish_data.rarity)

		var border_style: StyleBoxFlat = StyleBoxFlat.new()
		border_style.bg_color = Color(0.08, 0.1, 0.16)
		border_style.border_color = rarity_color
		border_style.border_width_top = 2
		border_style.border_width_bottom = 2
		border_style.border_width_left = 2
		border_style.border_width_right = 2
		border_style.corner_radius_top_left = 4
		border_style.corner_radius_top_right = 4
		border_style.corner_radius_bottom_left = 4
		border_style.corner_radius_bottom_right = 4
		border_style.content_margin_top = 4
		border_style.content_margin_bottom = 4
		border_style.content_margin_left = 4
		border_style.content_margin_right = 4
		panel.add_theme_stylebox_override("panel", border_style)

		var sprite: TextureRect = TextureRect.new()
		sprite.custom_minimum_size = Vector2(64, 64)
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = FISH_ATLAS
		atlas_tex.region = FISH_ATLAS_REGIONS.get(fish_data.id, Rect2(0, 0, 16, 16))
		sprite.texture = atlas_tex
		vbox.add_child(sprite)

		var name_label: Label = Label.new()
		name_label.text = fish_data.display_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 10)
		name_label.add_theme_color_override("font_color", rarity_color)
		vbox.add_child(name_label)

		var count_label: Label = Label.new()
		count_label.text = "x" + str(times_caught)
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 9)
		vbox.add_child(count_label)

		var click_button: Button = Button.new()
		click_button.set_anchors_preset(Control.PRESET_FULL_RECT)
		click_button.flat = true
		click_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		click_button.pressed.connect(_on_fish_pressed.bind(fish_data.id))
		panel.add_child(click_button)
	else:
		var dark_style: StyleBoxFlat = StyleBoxFlat.new()
		dark_style.bg_color = Color(0.06, 0.06, 0.08)
		dark_style.border_color = Color(0.15, 0.15, 0.2)
		dark_style.border_width_top = 2
		dark_style.border_width_bottom = 2
		dark_style.border_width_left = 2
		dark_style.border_width_right = 2
		dark_style.corner_radius_top_left = 4
		dark_style.corner_radius_top_right = 4
		dark_style.corner_radius_bottom_left = 4
		dark_style.corner_radius_bottom_right = 4
		dark_style.content_margin_top = 4
		dark_style.content_margin_bottom = 4
		dark_style.content_margin_left = 4
		dark_style.content_margin_right = 4
		panel.add_theme_stylebox_override("panel", dark_style)

		var silhouette: ColorRect = ColorRect.new()
		silhouette.custom_minimum_size = Vector2(64, 64)
		silhouette.color = Color(0.1, 0.1, 0.12)
		silhouette.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(silhouette)

		var unknown_label: Label = Label.new()
		unknown_label.text = "???"
		unknown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unknown_label.add_theme_font_size_override("font_size", 10)
		unknown_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35))
		vbox.add_child(unknown_label)

	return panel


func _on_fish_pressed(fish_id: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.FISH_DETAILS, {"fish_id": fish_id})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
