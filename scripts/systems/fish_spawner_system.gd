extends Node

var _fish_atlas: Texture2D = preload("res://assets/sprites/fish/FishGame_Fish_Sprite_Sheet.png")
var spawn_timer: float = 0.0
var active_schools: Array[FishSchool] = []
var spawn_config: SpawnConfig
var school_config: SchoolConfig
var fish_pool_selector: FishPoolSelector



func _ready() -> void:
	if GameResources.config:
		spawn_config = GameResources.config.spawn_config
		school_config = GameResources.config.school_config
		if GameResources.config.fish_database:
			fish_pool_selector = FishPoolSelector.new(GameResources.config.fish_database)


func _process(delta: float) -> void:
	if not spawn_config or not fish_pool_selector:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_config.spawn_interval:
		spawn_timer = 0.0
		_try_spawn_school()

	_cleanup_despawned()


func _try_spawn_school() -> void:
	if _get_total_fish_count() >= spawn_config.max_fish_on_screen:
		return

	var depth_range: Vector2 = _get_visible_depth_range()
	var fish_data: FishData = fish_pool_selector.select_fish(depth_range.x, depth_range.y)
	if not fish_data:
		return

	_spawn_school(fish_data)


func _spawn_school(fish_data: FishData) -> void:
	if not school_config:
		return

	var school: FishSchool = FishSchool.new()
	school.name = "School_" + fish_data.id

	var spawn_from_left: bool = randf() > 0.5

	var spawn_x: float
	var target_x: float
	if spawn_from_left:
		spawn_x = -10.0
		target_x = 370.0
	else:
		spawn_x = 370.0
		target_x = -10.0

	var spawn_y: float = randf_range(170.0, 550.0)

	var path: PackedVector2Array = PackedVector2Array()
	path.append(Vector2(spawn_x, spawn_y))
	path.append(Vector2(target_x, spawn_y))

	school.setup(fish_data, school_config, path)

	var fish_layer: Node = _get_fish_layer()
	if fish_layer:
		fish_layer.add_child(school)
	else:
		add_child(school)

	var school_size: int = randi_range(fish_data.min_school_size, fish_data.max_school_size)
	for i: int in school_size:
		var swimming_fish: SwimmingFish = SwimmingFish.new()
		swimming_fish.name = "Fish_" + str(i)
		swimming_fish.fish_data = fish_data
		swimming_fish.spawn_config = spawn_config

		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "Sprite2D"

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = _fish_atlas
		atlas_tex.region = _get_fish_atlas_region(fish_data.id)
		sprite.texture = atlas_tex
		sprite.scale = Vector2(3.0, 3.0)

		swimming_fish.add_child(sprite)

		var area: Area2D = Area2D.new()
		area.name = "Area2D"
		var collision: CollisionShape2D = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape: CircleShape2D = CircleShape2D.new()
		shape.radius = 12.0
		collision.shape = shape
		area.add_child(collision)
		swimming_fish.add_child(area)

		var offset: Vector2 = Vector2(
			randf_range(-school_config.school_spawn_spread, school_config.school_spawn_spread),
			randf_range(-school_config.school_spawn_spread, school_config.school_spawn_spread)
		)
		swimming_fish.position = offset

		var initial_direction: float = 1.0 if spawn_from_left else -1.0
		swimming_fish.velocity = Vector2(initial_direction * fish_data.swim_speed * randf_range(0.8, 1.2), randf_range(-5.0, 5.0))

		school.add_child(swimming_fish)
		school.add_member(swimming_fish)

	school.school_despawn.connect(_on_school_despawn.bind(school))
	school.school_empty.connect(_on_school_empty.bind(school))
	active_schools.append(school)

	SignalBus.school_spawned.emit(fish_data.id, school_size, Vector2(spawn_x, spawn_y))


func _on_school_despawn(school: FishSchool) -> void:
	_remove_school(school)


func _on_school_empty(school: FishSchool) -> void:
	_remove_school(school)


func _remove_school(school: FishSchool) -> void:
	active_schools.erase(school)
	if is_instance_valid(school):
		school.cleanup()


func _get_total_fish_count() -> int:
	var count: int = 0
	for school: FishSchool in active_schools:
		if is_instance_valid(school):
			count += school.get_member_count()
	return count


func _cleanup_despawned() -> void:
	active_schools.assign(active_schools.filter(func(s: FishSchool) -> bool: return is_instance_valid(s)))


func _get_visible_depth_range() -> Vector2:
	var camera_rect: Rect2 = _get_camera_rect()
	if camera_rect.size == Vector2.ZERO:
		return Vector2(0.0, 200.0)
	return Vector2(camera_rect.position.y, camera_rect.end.y)


func _get_camera_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(360, 640))


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


func _get_fish_atlas_region(fish_id: String) -> Rect2:
	if fish_id in FISH_ATLAS_REGIONS:
		return FISH_ATLAS_REGIONS[fish_id]
	return Rect2(0, 0, 16, 16)


func _get_fish_layer() -> Node:
	if Main.instance:
		var fish_layer: Node = Main.instance.get_node_or_null("FishingLevel/FishLayer")
		if fish_layer:
			return fish_layer
	return null
