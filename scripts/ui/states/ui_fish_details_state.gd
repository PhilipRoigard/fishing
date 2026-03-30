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

const QUALITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]

@onready var background: ColorRect = %Background
@onready var fish_name_label: Label = %FishName
@onready var fish_card: ItemCard = %FishCard
@onready var caught_label: Label = %CaughtLabel
@onready var quality_label: Label = %QualityLabel
@onready var depth_label: Label = %DepthLabel
@onready var value_label: Label = %ValueLabel

var fish_id: String = ""


func _ready() -> void:
	if background and not background.gui_input.is_connected(_on_background_input):
		background.gui_input.connect(_on_background_input)


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_back()


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		fish_id = meta.get("fish_id", "")
	_populate_data()


func _populate_data() -> void:
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(fish_id)

	if not fish_data:
		fish_name_label.text = "Unknown"
		return

	fish_name_label.text = fish_data.display_name

	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = FISH_ATLAS
	atlas_tex.region = FISH_ATLAS_REGIONS.get(fish_data.id, Rect2(0, 0, 16, 16))

	var state: PlayerState = null
	if Main.instance and Main.instance.player_state_system:
		state = Main.instance.player_state_system.get_state()

	var times_caught: int = 0
	var best_quality: int = 0
	if state:
		times_caught = state.collection_log.get(fish_id, 0)
		best_quality = state.collection_best_quality.get(fish_id, 0)

	var quality_color: Color = Enums.QUALITY_COLORS.get(best_quality, Color(0.6, 0.6, 0.6))
	fish_card.set_item_data(fish_data.id, "", atlas_tex, 0, quality_color)
	fish_card.level_label.visible = false

	caught_label.text = "Caught: x%d" % times_caught
	quality_label.text = "Best: %s" % QUALITY_NAMES[mini(best_quality, QUALITY_NAMES.size() - 1)]
	quality_label.add_theme_color_override("font_color", quality_color)
	depth_label.text = "Depth: %dm - %dm" % [int(fish_data.min_depth), int(fish_data.max_depth)]
	value_label.text = "Sell: %d coins" % fish_data.sell_value_coins
