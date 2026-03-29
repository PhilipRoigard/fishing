extends BaseState

const FISH_ATLAS: Texture2D = preload("res://assets/sprites/fish/FishGame_Fish_Sprite_Sheet.png")
const SplashEffectScript: GDScript = preload("res://scripts/environment/splash_effect.gd")
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
var fish_data: FishData
var depth: float = 0.0
var progress: float = 30.0
var tension: float = 0.0
var is_reeling: bool = false
var current_phase: Enums.FightPhase = Enums.FightPhase.NORMAL
var fishing_config: FishingConfig

var fish_position: float = 0.5
var fish_direction: float = 1.0
var fish_change_timer: float = 0.0
var fish_stopped: bool = false
var fish_stop_timer: float = 0.0

var active_effects: Dictionary = {}
var hook_node: Area2D
var hook_base_position: Vector2 = Vector2.ZERO
var fish_sprite: Sprite2D
var fish_y_range: float = 60.0
var jump_timer: float = 0.0
var jump_cooldown: float = 4.0
var is_jumping: bool = false
var jump_elapsed: float = 0.0
var reel_line_flash_timer: float = 0.0


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")
	depth = meta.get("depth", 0.0)

	if GameResources.config:
		fishing_config = GameResources.config.fishing_config
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_by_id(fish_id)

	_find_hook_node()

	progress = fishing_config.starting_progress if fishing_config else 30.0
	tension = 0.0
	is_reeling = false
	current_phase = Enums.FightPhase.NORMAL
	fish_position = 0.5
	fish_direction = 1.0
	fish_change_timer = 0.0
	fish_stopped = false
	fish_stop_timer = 0.0
	active_effects.clear()
	jump_timer = 0.0
	jump_cooldown = randf_range(3.0, 6.0)
	is_jumping = false
	jump_elapsed = 0.0
	reel_line_flash_timer = 0.0

	_create_fish_sprite()

	SignalBus.fight_started.emit(fish_id)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.FIGHTING)
	SignalBus.reel_input_started.connect(_on_reel_start)
	SignalBus.reel_input_ended.connect(_on_reel_end)
	SignalBus.consumable_used.connect(_on_consumable_used)


func exit() -> void:
	_remove_fish_sprite()
	if SignalBus.reel_input_started.is_connected(_on_reel_start):
		SignalBus.reel_input_started.disconnect(_on_reel_start)
	if SignalBus.reel_input_ended.is_connected(_on_reel_end):
		SignalBus.reel_input_ended.disconnect(_on_reel_end)
	if SignalBus.consumable_used.is_connected(_on_consumable_used):
		SignalBus.consumable_used.disconnect(_on_consumable_used)


func update(delta: float) -> void:
	_update_fish_ai(delta)
	_update_progress(delta)
	_update_tension(delta)
	_update_phase()
	_update_active_effects(delta)
	_update_hook_position()
	_update_fish_jump(delta)
	_update_reel_feedback(delta)

	SignalBus.fight_progress_changed.emit(progress)
	SignalBus.fight_tension_changed.emit(tension)

	if progress >= 100.0:
		state_machine.change_state(&"success", {"fish_id": fish_id})
	elif progress <= 0.0 or tension >= _get_tension_cap():
		if tension >= _get_tension_cap():
			SignalBus.line_snapped.emit()
		state_machine.change_state(&"fail", {"fish_id": fish_id})


func _update_fish_ai(delta: float) -> void:
	if _is_effect_active(Enums.ConsumableEffect.STUN):
		return

	var speed: float = fishing_config.fish_speed_base if fishing_config else 64.0
	if fish_data:
		speed = fish_data.fight_speed

	var phase_multiplier: float = 1.0
	match current_phase:
		Enums.FightPhase.DESPERATE:
			phase_multiplier = 1.5
		Enums.FightPhase.FINAL_STAND:
			phase_multiplier = 2.0

	if fish_stopped:
		fish_stop_timer -= delta
		if fish_stop_timer <= 0.0:
			fish_stopped = false
		return

	fish_change_timer -= delta
	if fish_change_timer <= 0.0:
		var change_interval: float = fishing_config.fish_change_interval if fishing_config else 0.5
		if fish_data:
			change_interval *= (1.0 - fish_data.fight_erratic * 0.5)
		fish_change_timer = change_interval
		fish_direction = -fish_direction

		var stop_chance: float = 0.3 - (fish_data.fight_erratic * 0.2 if fish_data else 0.0)
		if randf() < stop_chance:
			fish_stopped = true
			fish_stop_timer = fishing_config.fish_stop_duration if fishing_config else 0.5

	fish_position += fish_direction * speed * phase_multiplier * delta / 640.0
	fish_position = clampf(fish_position, 0.0, 1.0)


func _update_progress(delta: float) -> void:
	if is_reeling:
		var gain_rate: float = fishing_config.catch_increase_rate if fishing_config else 40.0
		var gain_multiplier: float = _get_effect_multiplier(Enums.ConsumableEffect.INCREASE_PROGRESS_GAIN)
		progress += gain_rate * gain_multiplier * delta
	else:
		var decay_rate: float = fishing_config.catch_decrease_rate if fishing_config else 20.0
		var decay_multiplier: float = _get_effect_multiplier(Enums.ConsumableEffect.REDUCE_DECAY)
		var stamina: float = fish_data.fight_stamina if fish_data else 1.0
		progress -= decay_rate * stamina * decay_multiplier * delta

	progress = clampf(progress, 0.0, 100.0)


func _update_tension(delta: float) -> void:
	if is_reeling:
		var tension_rate: float = fishing_config.base_tension_rate if fishing_config else 25.0
		var fish_tension_mod: float = fish_data.tension_generation if fish_data else 1.0

		var fighting_multiplier: float = 1.0
		if not fish_stopped and fishing_config:
			fighting_multiplier = fishing_config.tension_fighting_fish_multiplier

		tension += tension_rate * fish_tension_mod * fighting_multiplier * delta
	else:
		var relief_rate: float = fishing_config.tension_relief_rate if fishing_config else 35.0
		tension -= relief_rate * delta

	if _is_effect_active(Enums.ConsumableEffect.REDUCE_TENSION):
		tension -= 5.0 * delta

	tension = clampf(tension, 0.0, 150.0)


func _update_phase() -> void:
	if not fish_data or not fishing_config:
		return

	var new_phase: Enums.FightPhase = current_phase

	if fish_data.phase_count >= 3 and progress >= fishing_config.final_stand_phase_threshold:
		new_phase = Enums.FightPhase.FINAL_STAND
	elif fish_data.phase_count >= 2 and progress >= fishing_config.desperate_phase_threshold:
		new_phase = Enums.FightPhase.DESPERATE

	if new_phase != current_phase:
		current_phase = new_phase
		SignalBus.fight_phase_changed.emit(current_phase)


func _get_tension_cap() -> float:
	var cap: float = fishing_config.tension_snap_threshold if fishing_config else 100.0
	if _is_effect_active(Enums.ConsumableEffect.INCREASE_TENSION_CAP):
		cap *= 1.3
	return cap


func _on_reel_start() -> void:
	is_reeling = true


func _on_reel_end() -> void:
	is_reeling = false


func _on_consumable_used(effect: Enums.ConsumableEffect, duration: float) -> void:
	active_effects[effect] = duration
	SignalBus.consumable_effect_started.emit(effect)


func _update_active_effects(delta: float) -> void:
	var expired: Array[Enums.ConsumableEffect] = []
	for effect: Enums.ConsumableEffect in active_effects:
		active_effects[effect] -= delta
		if active_effects[effect] <= 0.0:
			expired.append(effect)
	for effect: Enums.ConsumableEffect in expired:
		active_effects.erase(effect)
		SignalBus.consumable_effect_ended.emit(effect)


func _is_effect_active(effect: Enums.ConsumableEffect) -> bool:
	return effect in active_effects and active_effects[effect] > 0.0


func _get_effect_multiplier(effect: Enums.ConsumableEffect) -> float:
	if not _is_effect_active(effect):
		return 1.0
	match effect:
		Enums.ConsumableEffect.REDUCE_DECAY:
			return fishing_config.line_wax_decay_multiplier if fishing_config else 0.5
		Enums.ConsumableEffect.INCREASE_PROGRESS_GAIN:
			return fishing_config.lucky_hook_gain_multiplier if fishing_config else 1.4
	return 1.0


func _find_hook_node() -> void:
	if Main.instance:
		var fishing_level: Node = Main.instance.get_node_or_null("FishingLevel")
		if fishing_level:
			hook_node = fishing_level.get_node_or_null("%Hook")
			if hook_node:
				hook_base_position = hook_node.position


func _update_hook_position() -> void:
	if not hook_node:
		return
	var wobble_x: float = (fish_position - 0.5) * 40.0
	hook_node.position = hook_base_position + Vector2(wobble_x, 0.0)
	SignalBus.hook_position_changed.emit(hook_node.global_position)

	if fish_sprite and is_instance_valid(fish_sprite):
		if not is_jumping:
			var offset_y: float = (fish_position - 0.5) * fish_y_range
			fish_sprite.position = Vector2(20.0, offset_y + 10.0)
			fish_sprite.rotation = 0.0
		fish_sprite.flip_h = fish_direction < 0.0


func _create_fish_sprite() -> void:
	if not hook_node:
		return

	fish_sprite = Sprite2D.new()
	fish_sprite.name = "FightFishSprite"

	var atlas_tex: AtlasTexture = AtlasTexture.new()
	atlas_tex.atlas = FISH_ATLAS
	var region: Rect2 = FISH_ATLAS_REGIONS.get(fish_id, Rect2(0, 0, 16, 16))
	atlas_tex.region = region
	fish_sprite.texture = atlas_tex
	fish_sprite.scale = Vector2(5.0, 5.0)

	hook_node.add_child(fish_sprite)


func _remove_fish_sprite() -> void:
	if fish_sprite and is_instance_valid(fish_sprite):
		fish_sprite.queue_free()
		fish_sprite = null


func _update_fish_jump(delta: float) -> void:
	if is_jumping:
		jump_elapsed += delta
		var jump_duration: float = 0.6
		var t: float = jump_elapsed / jump_duration
		if t >= 1.0:
			is_jumping = false
			if fish_sprite and is_instance_valid(fish_sprite):
				fish_sprite.position.y = (fish_position - 0.5) * fish_y_range + 10.0
			_spawn_splash_at_fish()
			return
		if fish_sprite and is_instance_valid(fish_sprite):
			var jump_height: float = -40.0 * sin(t * PI)
			fish_sprite.position.y = (fish_position - 0.5) * fish_y_range + 10.0 + jump_height
			fish_sprite.rotation = sin(t * PI * 2.0) * 0.3
		return

	jump_timer += delta
	if jump_timer >= jump_cooldown:
		jump_timer = 0.0
		jump_cooldown = randf_range(3.0, 7.0)
		is_jumping = true
		jump_elapsed = 0.0
		_spawn_splash_at_fish()
		if fish_sprite and is_instance_valid(fish_sprite):
			fish_sprite.rotation = 0.0


func _update_reel_feedback(delta: float) -> void:
	if is_reeling:
		reel_line_flash_timer += delta
		if fish_sprite and is_instance_valid(fish_sprite):
			var pulse: float = 1.0 + sin(reel_line_flash_timer * 10.0) * 0.1
			fish_sprite.scale = Vector2(5.0 * pulse, 5.0 * pulse)
	else:
		reel_line_flash_timer = 0.0
		if fish_sprite and is_instance_valid(fish_sprite) and not is_jumping:
			fish_sprite.scale = Vector2(5.0, 5.0)


func _spawn_splash_at_fish() -> void:
	if not hook_node:
		return
	var fishing_level: Node = null
	if Main.instance:
		fishing_level = Main.instance.get_node_or_null("FishingLevel")
	if not fishing_level:
		return
	var splash: Node2D = Node2D.new()
	splash.set_script(SplashEffectScript)
	splash.position = hook_node.global_position + Vector2(20.0, (fish_position - 0.5) * fish_y_range)
	fishing_level.add_child(splash)
