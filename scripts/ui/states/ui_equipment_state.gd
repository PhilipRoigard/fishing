extends UIStateNode

const FILTER_LABELS: Array[String] = ["All", "Rods", "Hooks", "Lures"]
const FILTER_TYPES: Array[String] = ["", "rod", "hook", "lure"]

var grid: GridContainer
var filter_container: HBoxContainer
var active_filter: int = 0


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
	title.text = "Equipment"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	filter_container = HBoxContainer.new()
	filter_container.add_theme_constant_override("separation", 8)
	vbox.add_child(filter_container)

	for i: int in FILTER_LABELS.size():
		var btn: Button = Button.new()
		btn.text = FILTER_LABELS[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_filter_pressed.bind(i))
		filter_container.add_child(btn)

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

	var filter_type: String = FILTER_TYPES[active_filter]
	var items: Array[EquipmentManager.EquipmentEntry] = []
	items.assign(EquipmentManager.inventory)

	if filter_type != "":
		var filtered: Array[EquipmentManager.EquipmentEntry] = []
		filtered.assign(items.filter(func(e: EquipmentManager.EquipmentEntry) -> bool: return e.equipment_type == filter_type))
		items = filtered

	for entry: EquipmentManager.EquipmentEntry in items:
		var cell: Button = _create_item_cell(entry)
		grid.add_child(cell)


func _get_display_name_for_entry(entry: EquipmentManager.EquipmentEntry) -> String:
	if not GameResources.config or not GameResources.config.equipment_catalogue:
		return entry.item_id
	var catalogue: Variant = GameResources.config.equipment_catalogue
	match entry.equipment_type:
		"rod":
			var data: Variant = catalogue.get_rod_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"hook":
			var data: Variant = catalogue.get_hook_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"lure":
			var data: Variant = catalogue.get_lure_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
		"bait":
			var data: Variant = catalogue.get_bait_by_id(entry.item_id)
			if data and data.display_name != "":
				return data.display_name
	return entry.item_id


func _create_item_cell(entry: EquipmentManager.EquipmentEntry) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(72, 72)
	var display_name: String = _get_display_name_for_entry(entry)
	btn.text = display_name.substr(0, 8) + "\nLv." + str(entry.level)
	btn.modulate = Enums.QUALITY_COLORS.get(entry.quality, Color.WHITE)

	var is_equipped: bool = _is_item_equipped(entry.uuid)
	if is_equipped:
		btn.text += "\n[E]"

	btn.pressed.connect(_on_item_pressed.bind(entry.uuid))
	return btn


func _is_item_equipped(uuid: String) -> bool:
	for slot: Enums.EquipmentSlot in [Enums.EquipmentSlot.ROD, Enums.EquipmentSlot.HOOK, Enums.EquipmentSlot.LURE]:
		var equipped: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(slot)
		if equipped and equipped.uuid == uuid:
			return true
	return false


func _on_filter_pressed(index: int) -> void:
	active_filter = index
	HapticManager.light_tap()
	_refresh_grid()


func _on_item_pressed(uuid: String) -> void:
	HapticManager.light_tap()
	state_machine.push_state(UIStateMachine.State.EQUIPMENT_DETAILS, {"uuid": uuid})


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
