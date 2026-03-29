extends UIStateNode

const BAIT_WORM: String = "worm_bait"
const BAIT_SHRIMP: String = "shrimp_bait"
const BAIT_SQUID: String = "squid_bait"
const FISH_REQUIRED_PER_CRAFT: int = 3
const BAIT_REQUIRED_PER_UPGRADE: int = 3

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
	vbox.add_child(title)

	var separator_top: HSeparator = HSeparator.new()
	vbox.add_child(separator_top)

	var bait_title: Label = Label.new()
	bait_title.text = "Bait Inventory"
	bait_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bait_title.add_theme_font_size_override("font_size", 16)
	bait_title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	vbox.add_child(bait_title)

	worm_count_label = Label.new()
	worm_count_label.text = "Worm Bait: 0"
	worm_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	worm_count_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(worm_count_label)

	shrimp_count_label = Label.new()
	shrimp_count_label.text = "Shrimp Bait: 0"
	shrimp_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shrimp_count_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	vbox.add_child(shrimp_count_label)

	squid_count_label = Label.new()
	squid_count_label.text = "Squid Bait: 0"
	squid_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	squid_count_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	vbox.add_child(squid_count_label)

	var separator_mid: HSeparator = HSeparator.new()
	vbox.add_child(separator_mid)

	var craft_title: Label = Label.new()
	craft_title.text = "Crafting"
	craft_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	craft_title.add_theme_font_size_override("font_size", 16)
	craft_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(craft_title)

	craft_worm_button = Button.new()
	craft_worm_button.text = "Craft Worm Bait (3 fish)"
	craft_worm_button.custom_minimum_size = Vector2(260, 50)
	craft_worm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	craft_worm_button.pressed.connect(_on_craft_worm)
	vbox.add_child(craft_worm_button)

	craft_shrimp_button = Button.new()
	craft_shrimp_button.text = "Craft Shrimp Bait (3 Worm)"
	craft_shrimp_button.custom_minimum_size = Vector2(260, 50)
	craft_shrimp_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	craft_shrimp_button.pressed.connect(_on_craft_shrimp)
	vbox.add_child(craft_shrimp_button)

	craft_squid_button = Button.new()
	craft_squid_button.text = "Craft Squid Bait (3 Shrimp)"
	craft_squid_button.custom_minimum_size = Vector2(260, 50)
	craft_squid_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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


func _refresh_display() -> void:
	var state: PlayerState = _get_player_state()
	if not state:
		return

	var total_kept_fish: int = _get_total_kept_fish(state)

	var worm_count: int = state.bait_inventory.get(BAIT_WORM, 0)
	var shrimp_count: int = state.bait_inventory.get(BAIT_SHRIMP, 0)
	var squid_count: int = state.bait_inventory.get(BAIT_SQUID, 0)

	if worm_count_label:
		worm_count_label.text = "Worm Bait: " + str(worm_count)
	if shrimp_count_label:
		shrimp_count_label.text = "Shrimp Bait: " + str(shrimp_count)
	if squid_count_label:
		squid_count_label.text = "Squid Bait: " + str(squid_count)

	if craft_worm_button:
		craft_worm_button.disabled = total_kept_fish < FISH_REQUIRED_PER_CRAFT
		craft_worm_button.text = "Craft Worm Bait (3 fish) [" + str(total_kept_fish) + " available]"
	if craft_shrimp_button:
		craft_shrimp_button.disabled = worm_count < BAIT_REQUIRED_PER_UPGRADE
		craft_shrimp_button.text = "Craft Shrimp Bait (3 Worm) [" + str(worm_count) + " available]"
	if craft_squid_button:
		craft_squid_button.disabled = shrimp_count < BAIT_REQUIRED_PER_UPGRADE
		craft_squid_button.text = "Craft Squid Bait (3 Shrimp) [" + str(shrimp_count) + " available]"

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
