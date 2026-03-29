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
	margin.add_theme_constant_override("margin_top", SafeZoneManager.get_top_margin() + 10)
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 60)
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
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


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

		var cell: Button = _create_fish_cell(fish_data, times_caught)
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


func _create_fish_cell(fish_data: FishData, times_caught: int) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(72, 72)
	if times_caught > 0:
		btn.text = fish_data.display_name.substr(0, 6) + "\nx" + str(times_caught)
		btn.modulate = _get_rarity_color(fish_data.rarity)
		btn.pressed.connect(_on_fish_pressed.bind(fish_data.id))
	else:
		btn.text = "???"
		btn.modulate = Color(0.3, 0.3, 0.3)
	return btn


func _on_fish_pressed(fish_id: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.FISH_DETAILS, {"fish_id": fish_id})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
