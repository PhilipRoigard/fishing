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

var fish_name_label: Label
var rarity_label: Label
var coins_label: Label
var xp_label: Label
var discovery_label: Label
var sell_button: Button
var keep_button: Button
var fish_sprite: TextureRect
var caught_fish_id: String = ""
var caught_quality: int = 0
var discovery_tween: Tween


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		caught_fish_id = meta.get("fish_id", "")
		caught_quality = meta.get("caught_quality", 0)
	_build_layout()
	_populate_data()


func exit() -> void:
	super()
	if discovery_tween and discovery_tween.is_valid():
		discovery_tween.kill()
	_clear_children()


func _build_layout() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.06, 0.12, 1.0)
	add_child(bg)

	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", preload("res://resources/ui/Style Boxes/StyleBoxTexture/panels/panel_container_header.tres"))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 450)
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -225
	panel.offset_bottom = 225
	add_child(panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	fish_sprite = TextureRect.new()
	fish_sprite.custom_minimum_size = Vector2(128, 128)
	fish_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fish_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fish_sprite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(fish_sprite)

	fish_name_label = Label.new()
	fish_name_label.text = "Unknown Fish"
	fish_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fish_name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(fish_name_label)

	rarity_label = Label.new()
	rarity_label.text = "Common"
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(rarity_label)

	var separator: HSeparator = HSeparator.new()
	vbox.add_child(separator)

	coins_label = Label.new()
	coins_label.text = "Coins: 0"
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(coins_label)

	xp_label = Label.new()
	xp_label.text = "XP: 0"
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(xp_label)

	discovery_label = Label.new()
	discovery_label.text = ""
	discovery_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	discovery_label.add_theme_font_size_override("font_size", 20)
	discovery_label.visible = false
	vbox.add_child(discovery_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	vbox.add_child(button_row)

	sell_button = Button.new()
	sell_button.text = "Sell"
	sell_button.custom_minimum_size = Vector2(130, 50)
	sell_button.pressed.connect(_on_sell_pressed)
	button_row.add_child(sell_button)

	keep_button = Button.new()
	keep_button.text = "Save as Material"
	keep_button.custom_minimum_size = Vector2(130, 50)
	keep_button.pressed.connect(_on_keep_pressed)
	button_row.add_child(keep_button)


func _populate_data() -> void:
	if caught_fish_id == "":
		return

	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(caught_fish_id)

	if not fish_data:
		return

	_set_fish_sprite(caught_fish_id)

	var rarity_color: Color = _get_rarity_color(fish_data.rarity)

	if fish_name_label:
		fish_name_label.text = fish_data.display_name
		fish_name_label.add_theme_color_override("font_color", rarity_color)

	var rarity_name: String = Enums.RARITY_NAMES.get(fish_data.rarity, "Common")
	if rarity_label:
		rarity_label.text = rarity_name
		rarity_label.add_theme_color_override("font_color", rarity_color)

	if coins_label:
		coins_label.text = "Coins: +" + str(fish_data.sell_value_coins)
		coins_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))

	if sell_button:
		sell_button.text = "Sell (+" + str(fish_data.sell_value_coins) + ")"

	var reward_cfg: RewardConfig = null
	if GameResources.config:
		reward_cfg = GameResources.config.reward_config
	if xp_label and reward_cfg:
		xp_label.text = "XP: +" + str(reward_cfg.get_xp_for_rarity(fish_data.rarity))
		xp_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))

	_check_new_discovery()


func _set_fish_sprite(fish_id: String) -> void:
	if not fish_sprite:
		return
	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = FISH_ATLAS
	var region: Rect2 = FISH_ATLAS_REGIONS.get(fish_id, Rect2(0, 0, 16, 16))
	atlas_tex.region = region
	fish_sprite.texture = atlas_tex


func _check_new_discovery() -> void:
	if not Main.instance or not Main.instance.player_state_system:
		return
	var state: PlayerState = Main.instance.player_state_system.get_state()
	if not state:
		return
	var catch_count: int = state.collection_log.get(caught_fish_id, 0)
	if catch_count <= 1 and discovery_label:
		discovery_label.text = "NEW DISCOVERY!"
		discovery_label.visible = true
		discovery_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		discovery_tween = create_tween().set_loops()
		discovery_tween.tween_property(discovery_label, "modulate:a", 0.4, 0.5)
		discovery_tween.tween_property(discovery_label, "modulate:a", 1.0, 0.5)


func _get_rarity_color(rarity: Enums.Rarity) -> Color:
	match rarity:
		Enums.Rarity.COMMON:
			return Color(0.7, 0.7, 0.7)
		Enums.Rarity.UNCOMMON:
			return Color(0.2, 0.8, 0.2)
		Enums.Rarity.RARE:
			return Color(0.2, 0.6, 1.0)
		Enums.Rarity.LEGENDARY:
			return Color(1.0, 0.84, 0.0)
	return Color.WHITE


func _on_sell_pressed() -> void:
	HapticManager.light_tap()
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(caught_fish_id)
	if fish_data:
		CurrencyManager.add_coins(fish_data.sell_value_coins)
	_back()


func _on_keep_pressed() -> void:
	HapticManager.light_tap()
	if Main.instance and Main.instance.player_state_system:
		var state: PlayerState = Main.instance.player_state_system.get_state()
		if state:
			var max_material_tier: int = mini(caught_quality, 2)
			for q: int in range(0, max_material_tier + 1):
				var current: int = state.kept_fish.get(q, 0)
				state.kept_fish[q] = current + 1
	_back()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
