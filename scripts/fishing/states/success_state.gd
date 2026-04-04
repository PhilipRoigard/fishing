extends BaseState

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

var fish_id: String = ""
var hook_node: Area2D
var fish_sprite: Sprite2D
var reel_tween: Tween
var fisherman_ref: Node2D
var reel_target: Vector2 = Vector2.ZERO
var caught_fish_node: Node = null

const REEL_DURATION: float = 0.8


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")
	var fish_ref: Variant = meta.get("fish_node", null)
	caught_fish_node = fish_ref if fish_ref != null and is_instance_valid(fish_ref) else null

	if caught_fish_node and is_instance_valid(caught_fish_node) and caught_fish_node is SwimmingFish:
		var sf: SwimmingFish = caught_fish_node as SwimmingFish
		sf.visible = false
		sf.is_caught = true

	_find_hook_node()
	_find_fisherman()
	_create_fish_sprite()

	SignalBus.fishing_state_changed.emit(Enums.FishingState.REELING_IN)
	_start_reel_animation()


func exit() -> void:
	_remove_fish_sprite()
	if reel_tween and reel_tween.is_valid():
		reel_tween.kill()


func update(_delta: float) -> void:
	if hook_node and is_instance_valid(hook_node):
		SignalBus.hook_position_changed.emit(hook_node.global_position)


func _find_hook_node() -> void:
	if Main.instance:
		var fishing_level: Node = Main.instance.get_node_or_null("FishingLevel")
		if fishing_level:
			hook_node = fishing_level.get_node_or_null("%Hook")


func _find_fisherman() -> void:
	if Main.instance:
		var fishing_level: Node = Main.instance.get_node_or_null("FishingLevel")
		if fishing_level:
			fisherman_ref = fishing_level.get_node_or_null("%Fisherman")


func _create_fish_sprite() -> void:
	if not hook_node:
		return

	fish_sprite = Sprite2D.new()
	fish_sprite.name = "ReelFishSprite"

	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = FISH_ATLAS
	var region: Rect2 = FISH_ATLAS_REGIONS.get(fish_id, Rect2(0, 0, 16, 16))
	atlas_tex.region = region
	fish_sprite.texture = atlas_tex
	fish_sprite.scale = Vector2(5.0, 5.0)
	fish_sprite.position = Vector2(20.0, 10.0)

	hook_node.add_child(fish_sprite)


func _remove_fish_sprite() -> void:
	if fish_sprite and is_instance_valid(fish_sprite):
		fish_sprite.queue_free()
		fish_sprite = null


func _start_reel_animation() -> void:
	if not hook_node:
		_on_reel_complete()
		return

	reel_target = Vector2(180, 130)
	if fisherman_ref and fisherman_ref.has_method("get_rod_tip_position"):
		reel_target = fisherman_ref.get_rod_tip_position()

	var hook_start: Vector2 = hook_node.global_position
	var reel_global_target: Vector2 = reel_target

	reel_tween = hook_node.create_tween()
	reel_tween.set_ease(Tween.EASE_IN)
	reel_tween.set_trans(Tween.TRANS_QUAD)
	reel_tween.tween_property(hook_node, "global_position", reel_global_target, REEL_DURATION)
	reel_tween.tween_callback(_on_reel_complete)


func _on_reel_complete() -> void:
	if caught_fish_node and is_instance_valid(caught_fish_node) and caught_fish_node is SwimmingFish:
		(caught_fish_node as SwimmingFish).catch_fish()

	_remove_fish_sprite()
	_grant_rewards()
	_reset_hook_position()

	SignalBus.fish_caught.emit(fish_id)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.SUCCESS)
	HapticManager.success_feedback()


func _grant_rewards() -> void:
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(fish_id)

	if not fish_data:
		return

	var reward_cfg: RewardConfig = null
	if GameResources.config:
		reward_cfg = GameResources.config.reward_config
	if reward_cfg:
		var base_xp: int = reward_cfg.get_xp_for_rarity(0)
		var xp_bonus_pct: float = _get_rod_perk_value("bonus_xp")
		var xp_amount: int = int(float(base_xp) * (1.0 + xp_bonus_pct / 100.0))
		SignalBus.xp_gained.emit(xp_amount)

	SignalBus.collection_updated.emit(fish_id, 1)


func _get_rod_perk_value(perk_id: String) -> float:
	var rod_entry: EquipmentManager.EquipmentEntry = EquipmentManager.get_equipped(Enums.EquipmentSlot.ROD)
	if not rod_entry or not GameResources.config or not GameResources.config.equipment_catalogue:
		return 0.0
	var rod_data: RodData = GameResources.config.equipment_catalogue.get_rod_by_id(rod_entry.item_id)
	if not rod_data or rod_data.perk_id != perk_id:
		return 0.0
	var perk_idx: int = mini(rod_entry.quality, rod_data.perk_values.size() - 1)
	return rod_data.perk_values[perk_idx]


func _reset_hook_position() -> void:
	var fishing_level: Node = null
	if Main.instance:
		fishing_level = Main.instance.get_node_or_null("FishingLevel")
	if fishing_level:
		var hook: Area2D = fishing_level.get_node_or_null("%Hook")
		if hook:
			hook.position = Vector2(180, 400)
			SignalBus.hook_position_changed.emit(hook.global_position)
