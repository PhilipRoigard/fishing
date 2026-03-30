extends UIStateNode

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
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
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
		var best_quality: int = -1
		if state:
			times_caught = state.collection_log.get(fish_data.id, 0)
			best_quality = state.collection_best_quality.get(fish_data.id, -1)
		if times_caught > 0:
			caught_count += 1

		var cell: PanelContainer = _create_fish_cell(fish_data, times_caught, best_quality)
		grid.add_child(cell)

	if completion_label:
		var pct: int = 0
		if total_count > 0:
			pct = int((float(caught_count) / float(total_count)) * 100.0)
		completion_label.text = str(caught_count) + "/" + str(total_count) + " (" + str(pct) + "%)"



func _create_fish_cell(fish_data: FishData, times_caught: int, best_quality: int) -> PanelContainer:
	var card_scene: PackedScene = preload("res://scenes/ui/components/item_card.tscn")
	var card: ItemCard = card_scene.instantiate() as ItemCard
	var fish_tex: Texture2D = fish_data.texture

	if times_caught > 0:
		var quality_color: Color = Enums.QUALITY_COLORS.get(best_quality, Color(0.6, 0.6, 0.6))
		card.ready.connect(func() -> void:
			card.set_item_data(fish_data.id, "", fish_tex, 0, quality_color)
			card.level_label.text = "x" + str(times_caught)
			card.selected.connect(_on_fish_pressed.bind(fish_data.id))
		)
	else:
		card.ready.connect(func() -> void:
			card.item_texture.texture = fish_tex
			card.item_texture.modulate = Color(0.0, 0.0, 0.0, 1.0)
			card.self_modulate = Color(0.12, 0.12, 0.14)
			card.level_label.text = "???"
			card.level_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.25))
		)

	return card


func _on_fish_pressed(fish_id: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.FISH_DETAILS, {"fish_id": fish_id})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
