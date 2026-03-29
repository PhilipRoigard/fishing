extends UIStateNode

const BAIT_WORM: String = "worm_bait"
const BAIT_SHRIMP: String = "shrimp_bait"
const BAIT_SQUID: String = "squid_bait"
const FISH_REQUIRED_PER_CRAFT: int = 3
const BAIT_REQUIRED_PER_UPGRADE: int = 3

var _bait_worm_texture: Texture2D = preload("res://assets/sprites/items/Bait_01.png")
var _bait_shrimp_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_blue.png")
var _bait_squid_texture: Texture2D = preload("res://assets/sprites/items/Bait_01_pink.png")

var kept_fish_label: Label
var worm_count_label: Label
var shrimp_count_label: Label
var squid_count_label: Label
var craft_worm_button: Button
var craft_shrimp_button: Button
var craft_squid_button: Button
var fish_list_container: VBoxContainer


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_refresh_display()


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
	margin.add_theme_constant_override("margin_bottom", SafeZoneManager.get_bottom_margin() + 20)
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
	margin.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Craft Bait"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	vbox.add_child(title)

	var separator_top: HSeparator = HSeparator.new()
	vbox.add_child(separator_top)

	var bait_title: Label = Label.new()
	bait_title.text = "Bait Inventory"
	bait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bait_title.add_theme_font_size_override("font_size", 16)
	bait_title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	vbox.add_child(bait_title)

	var worm_row: HBoxContainer = _create_bait_inventory_row(_bait_worm_texture, "Worm Bait", Color(0.6, 0.6, 0.6))
	vbox.add_child(worm_row)
	worm_count_label = worm_row.get_child(2) as Label

	var shrimp_row: HBoxContainer = _create_bait_inventory_row(_bait_shrimp_texture, "Shrimp Bait", Color(0.2, 0.8, 0.2))
	vbox.add_child(shrimp_row)
	shrimp_count_label = shrimp_row.get_child(2) as Label

	var squid_row: HBoxContainer = _create_bait_inventory_row(_bait_squid_texture, "Squid Bait", Color(0.2, 0.6, 1.0))
	vbox.add_child(squid_row)
	squid_count_label = squid_row.get_child(2) as Label

	var separator_mid: HSeparator = HSeparator.new()
	vbox.add_child(separator_mid)

	var craft_title: Label = Label.new()
	craft_title.text = "Crafting"
	craft_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	craft_title.add_theme_font_size_override("font_size", 16)
	craft_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(craft_title)

	craft_worm_button = _create_craft_button(_bait_worm_texture, "Craft Worm Bait (3 fish)", Color(0.15, 0.2, 0.15))
	craft_worm_button.pressed.connect(_on_craft_worm)
	vbox.add_child(craft_worm_button)

	craft_shrimp_button = _create_craft_button(_bait_shrimp_texture, "Craft Shrimp Bait (3 Worm)", Color(0.1, 0.2, 0.1))
	craft_shrimp_button.pressed.connect(_on_craft_shrimp)
	vbox.add_child(craft_shrimp_button)

	craft_squid_button = _create_craft_button(_bait_squid_texture, "Craft Squid Bait (3 Shrimp)", Color(0.1, 0.15, 0.25))
	craft_squid_button.pressed.connect(_on_craft_squid)
	vbox.add_child(craft_squid_button)

	var separator_bottom: HSeparator = HSeparator.new()
	vbox.add_child(separator_bottom)

	var fish_title: Label = Label.new()
	fish_title.text = "Kept Fish"
	fish_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fish_title.add_theme_font_size_override("font_size", 16)
	fish_title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	vbox.add_child(fish_title)

	kept_fish_label = Label.new()
	kept_fish_label.text = "No fish kept"
	kept_fish_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(kept_fish_label)

	fish_list_container = VBoxContainer.new()
	fish_list_container.add_theme_constant_override("separation", 4)
	vbox.add_child(fish_list_container)

	var back_button: Button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 44)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_back)
	vbox.add_child(back_button)


func _create_bait_inventory_row(texture: Texture2D, bait_name: String, label_color: Color) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = texture
	row.add_child(icon)

	var name_lbl: Label = Label.new()
	name_lbl.text = bait_name + ":"
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", label_color)
	name_lbl.custom_minimum_size = Vector2(120, 0)
	row.add_child(name_lbl)

	var count_lbl: Label = Label.new()
	count_lbl.text = "0"
	count_lbl.add_theme_font_size_override("font_size", 14)
	count_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	row.add_child(count_lbl)

	return row


func _create_craft_button(texture: Texture2D, text: String, bg_color: Color) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(260, 54)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.text = "   " + text
	btn.icon = texture
	btn.expand_icon = true
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var btn_style: StyleBoxFlat = StyleBoxFlat.new()
	btn_style.bg_color = bg_color
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	btn_style.content_margin_left = 8
	btn_style.content_margin_right = 8
	btn.add_theme_stylebox_override("normal", btn_style)

	return btn


func _refresh_display() -> void:
	var state: PlayerState = _get_player_state()
	if not state:
		return

	var total_kept_fish: int = _get_total_kept_fish(state)

	var worm_count: int = state.bait_inventory.get(BAIT_WORM, 0)
	var shrimp_count: int = state.bait_inventory.get(BAIT_SHRIMP, 0)
	var squid_count: int = state.bait_inventory.get(BAIT_SQUID, 0)

	if worm_count_label:
		worm_count_label.text = str(worm_count)
	if shrimp_count_label:
		shrimp_count_label.text = str(shrimp_count)
	if squid_count_label:
		squid_count_label.text = str(squid_count)

	if craft_worm_button:
		craft_worm_button.disabled = total_kept_fish < FISH_REQUIRED_PER_CRAFT
		craft_worm_button.text = "   Craft Worm (" + str(total_kept_fish) + "/3 fish)"
	if craft_shrimp_button:
		craft_shrimp_button.disabled = worm_count < BAIT_REQUIRED_PER_UPGRADE
		craft_shrimp_button.text = "   Craft Shrimp (" + str(worm_count) + "/3 worm)"
	if craft_squid_button:
		craft_squid_button.disabled = shrimp_count < BAIT_REQUIRED_PER_UPGRADE
		craft_squid_button.text = "   Craft Squid (" + str(shrimp_count) + "/3 shrimp)"

	_refresh_fish_list(state)


func _refresh_fish_list(state: PlayerState) -> void:
	if not fish_list_container:
		return

	for child: Node in fish_list_container.get_children():
		child.queue_free()

	var has_fish: bool = false
	for fish_id: String in state.kept_fish:
		var count: int = state.kept_fish[fish_id]
		if count <= 0:
			continue
		has_fish = true

		var fish_display_name: String = fish_id
		if Main.instance and Main.instance.database_system:
			var fish_data: FishData = Main.instance.database_system.get_fish_by_id(fish_id)
			if fish_data:
				fish_display_name = fish_data.display_name

		var row_label: Label = Label.new()
		row_label.text = fish_display_name + " x" + str(count)
		row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row_label.add_theme_font_size_override("font_size", 13)
		fish_list_container.add_child(row_label)

	if kept_fish_label:
		kept_fish_label.visible = not has_fish


func _get_total_kept_fish(state: PlayerState) -> int:
	var total: int = 0
	for fish_id: String in state.kept_fish:
		total += state.kept_fish[fish_id] as int
	return total


func _consume_fish(state: PlayerState, amount: int) -> void:
	var remaining: int = amount
	var fish_ids: Array = state.kept_fish.keys()
	for fish_id: String in fish_ids:
		if remaining <= 0:
			break
		var available: int = state.kept_fish[fish_id] as int
		var to_remove: int = mini(available, remaining)
		state.kept_fish[fish_id] = available - to_remove
		remaining -= to_remove
		if state.kept_fish[fish_id] <= 0:
			state.kept_fish.erase(fish_id)


func _on_craft_worm() -> void:
	HapticManager.light_tap()
	var state: PlayerState = _get_player_state()
	if not state:
		return
	if _get_total_kept_fish(state) < FISH_REQUIRED_PER_CRAFT:
		return
	_consume_fish(state, FISH_REQUIRED_PER_CRAFT)
	var current_worm: int = state.bait_inventory.get(BAIT_WORM, 0)
	state.bait_inventory[BAIT_WORM] = current_worm + 1
	_refresh_display()


func _on_craft_shrimp() -> void:
	HapticManager.light_tap()
	var state: PlayerState = _get_player_state()
	if not state:
		return
	var worm_count: int = state.bait_inventory.get(BAIT_WORM, 0)
	if worm_count < BAIT_REQUIRED_PER_UPGRADE:
		return
	state.bait_inventory[BAIT_WORM] = worm_count - BAIT_REQUIRED_PER_UPGRADE
	var current_shrimp: int = state.bait_inventory.get(BAIT_SHRIMP, 0)
	state.bait_inventory[BAIT_SHRIMP] = current_shrimp + 1
	_refresh_display()


func _on_craft_squid() -> void:
	HapticManager.light_tap()
	var state: PlayerState = _get_player_state()
	if not state:
		return
	var shrimp_count: int = state.bait_inventory.get(BAIT_SHRIMP, 0)
	if shrimp_count < BAIT_REQUIRED_PER_UPGRADE:
		return
	state.bait_inventory[BAIT_SHRIMP] = shrimp_count - BAIT_REQUIRED_PER_UPGRADE
	var current_squid: int = state.bait_inventory.get(BAIT_SQUID, 0)
	state.bait_inventory[BAIT_SQUID] = current_squid + 1
	_refresh_display()


func _get_player_state() -> PlayerState:
	if Main.instance and Main.instance.player_state_system:
		return Main.instance.player_state_system.get_state()
	return null


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
