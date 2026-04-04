extends Node2D

enum AnimState {
	IDLE,
	CAST_BEGIN,
	CAST_RELEASE,
	FISHING_IDLE,
	REEL,
}

var current_anim_state: AnimState = AnimState.IDLE

@onready var body_sprite: Sprite2D = $Body
@onready var overalls_sprite: Sprite2D = $Overalls
@onready var arms_sprite: Sprite2D = $Arms
@onready var hat_sprite: Sprite2D = $Hat
@onready var beard_sprite: Sprite2D = $Beard
@onready var rod_sprite: Sprite2D = $FishingRod
@onready var legs_sprite: Sprite2D = $Legs
@onready var eyes_sprite: Sprite2D = $Eyes
@onready var hair_sprite: Sprite2D = $Hair
@onready var shadow_sprite: Sprite2D = $Shadow

var _body_texture: Texture2D = preload("res://assets/sprites/character/naked_body_sprite_sheet.png")
var _overalls_texture: Texture2D = preload("res://assets/sprites/character/overalls_sprite_sheet.png")
var _arms_texture: Texture2D = preload("res://assets/sprites/character/arms_sprite_sheet.png")
var _hat_texture: Texture2D = preload("res://assets/sprites/character/hat_01_sprite_sheet.png")
var _beard_texture: Texture2D = preload("res://assets/sprites/character/beard_01_sprite_sheet.png")
var _rod_texture: Texture2D = preload("res://assets/sprites/character/fishing_rod_sheet.png")
var _legs_texture: Texture2D = preload("res://assets/sprites/character/legs_sprite_sheet.png")
var _eyes_texture: Texture2D = preload("res://assets/sprites/character/eyes_sprite_sheet.png")
var _hair_texture: Texture2D = preload("res://assets/sprites/character/hair_01_sprite_sheet.png")
var _shadow_texture: Texture2D = preload("res://assets/sprites/character/shaddow.png")

var _idle_anim_timer: float = 0.0
var _idle_anim_frame: int = 0
var _fishing_idle_timer: float = 0.0
var _fishing_idle_toggle: bool = false
var _reel_timer: float = 0.0
var _reel_toggle: bool = false
var _cast_release_timer: float = 0.0
var _bite_dip_timer: float = 0.0

const IDLE_FRAME_DURATION: float = 0.15
const IDLE_FRAME_COUNT: int = 8
const FISHING_IDLE_BOB_SPEED: float = 1.2
const REEL_BOB_SPEED: float = 4.0
const CAST_RELEASE_DURATION: float = 0.3
const BITE_DIP_DURATION: float = 0.25
const BITE_DIP_ANGLE: float = 8.0


func _ready() -> void:
	_setup_sprites()
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	SignalBus.cast_started.connect(_on_cast_started)
	SignalBus.cast_landed.connect(_on_cast_landed)
	SignalBus.fight_started.connect(_on_fight_started)
	SignalBus.fish_caught.connect(_on_fish_caught)
	SignalBus.fish_escaped.connect(_on_fish_escaped)
	SignalBus.line_snapped.connect(_on_line_snapped)
	SignalBus.bite_occurred.connect(_on_bite_occurred)
	_set_anim_state(AnimState.IDLE)


func _process(delta: float) -> void:
	match current_anim_state:
		AnimState.IDLE:
			_idle_anim_timer += delta
			if _idle_anim_timer >= IDLE_FRAME_DURATION:
				_idle_anim_timer -= IDLE_FRAME_DURATION
				_idle_anim_frame = (_idle_anim_frame + 1) % IDLE_FRAME_COUNT
				_apply_idle_frames(_idle_anim_frame)
		AnimState.CAST_RELEASE:
			_cast_release_timer -= delta
			if _cast_release_timer <= 0.0:
				_set_anim_state(AnimState.FISHING_IDLE)
		AnimState.FISHING_IDLE:
			_fishing_idle_timer += delta
			var new_toggle: bool = fmod(_fishing_idle_timer, FISHING_IDLE_BOB_SPEED) > FISHING_IDLE_BOB_SPEED * 0.5
			if new_toggle != _fishing_idle_toggle:
				_fishing_idle_toggle = new_toggle
				_apply_fishing_bob_frame(_fishing_idle_toggle)
			_update_bite_dip(delta)
		AnimState.REEL:
			_reel_timer += delta
			var reel_toggle: bool = fmod(_reel_timer, 1.0 / REEL_BOB_SPEED) > (1.0 / REEL_BOB_SPEED) * 0.5
			if reel_toggle != _reel_toggle:
				_reel_toggle = reel_toggle
				_apply_fishing_bob_frame(_reel_toggle)
			_update_bite_dip(delta)


func _setup_sprites() -> void:
	_configure_sprite(body_sprite, _body_texture, 17, 3, Vector2i(0, 2))
	_configure_sprite(overalls_sprite, _overalls_texture, 17, 3, Vector2i(0, 2))
	_configure_sprite(arms_sprite, _arms_texture, 17, 4, Vector2i(0, 3))
	_configure_sprite(hat_sprite, _hat_texture, 17, 3, Vector2i(0, 2))
	_configure_sprite(beard_sprite, _beard_texture, 17, 2, Vector2i(0, 1))
	_configure_sprite(legs_sprite, _legs_texture, 17, 2, Vector2i(0, 1))
	_configure_sprite(eyes_sprite, _eyes_texture, 17, 2, Vector2i(0, 1))
	_configure_sprite(hair_sprite, _hair_texture, 17, 3, Vector2i(0, 2))
	_configure_sprite(rod_sprite, _rod_texture, 5, 3, Vector2i(0, 2))
	rod_sprite.visible = false

	if shadow_sprite:
		shadow_sprite.texture = _shadow_texture
		shadow_sprite.position = Vector2(0, 30)


func _configure_sprite(sprite: Sprite2D, tex: Texture2D, h: int, v: int, default_frame: Vector2i = Vector2i(0, 0)) -> void:
	if not sprite:
		return
	sprite.texture = tex
	sprite.hframes = h
	sprite.vframes = v
	sprite.frame_coords = default_frame


func _apply_idle_frames(col: int) -> void:
	body_sprite.frame_coords = Vector2i(col, 2)
	overalls_sprite.frame_coords = Vector2i(col, 2)
	hat_sprite.frame_coords = Vector2i(col, 2)
	hair_sprite.frame_coords = Vector2i(col, 2)
	arms_sprite.frame_coords = Vector2i(col, 3)
	beard_sprite.frame_coords = Vector2i(col, 1)
	eyes_sprite.frame_coords = Vector2i(col, 1)
	legs_sprite.frame_coords = Vector2i(col, 1)


func _apply_fishing_idle_frames() -> void:
	body_sprite.frame_coords = Vector2i(15, 2)
	overalls_sprite.frame_coords = Vector2i(15, 2)
	hat_sprite.frame_coords = Vector2i(15, 2)
	hair_sprite.frame_coords = Vector2i(15, 2)
	arms_sprite.frame_coords = Vector2i(15, 3)
	beard_sprite.frame_coords = Vector2i(15, 1)
	eyes_sprite.frame_coords = Vector2i(15, 1)
	legs_sprite.frame_coords = Vector2i(15, 1)
	rod_sprite.frame_coords = Vector2i(0, 2)


func _apply_cast_release_frames() -> void:
	body_sprite.frame_coords = Vector2i(13, 2)
	overalls_sprite.frame_coords = Vector2i(13, 2)
	hat_sprite.frame_coords = Vector2i(13, 2)
	hair_sprite.frame_coords = Vector2i(13, 2)
	arms_sprite.frame_coords = Vector2i(13, 3)
	beard_sprite.frame_coords = Vector2i(13, 1)
	eyes_sprite.frame_coords = Vector2i(13, 1)
	legs_sprite.frame_coords = Vector2i(13, 1)
	rod_sprite.frame_coords = Vector2i(0, 2)


func _apply_fishing_bob_frame(alt: bool) -> void:
	var col: int = 16 if alt else 15
	body_sprite.frame_coords = Vector2i(col, 2)
	overalls_sprite.frame_coords = Vector2i(col, 2)
	hat_sprite.frame_coords = Vector2i(col, 2)
	hair_sprite.frame_coords = Vector2i(col, 2)
	arms_sprite.frame_coords = Vector2i(col, 3)
	beard_sprite.frame_coords = Vector2i(col, 1)
	eyes_sprite.frame_coords = Vector2i(col, 1)
	legs_sprite.frame_coords = Vector2i(col, 1)


func _update_bite_dip(delta: float) -> void:
	if _bite_dip_timer > 0.0:
		_bite_dip_timer -= delta
		var dip_t: float = _bite_dip_timer / BITE_DIP_DURATION
		rod_sprite.rotation_degrees = BITE_DIP_ANGLE * dip_t
	else:
		rod_sprite.rotation_degrees = 0.0


func _apply_cast_begin_frames() -> void:
	body_sprite.frame_coords = Vector2i(12, 2)
	overalls_sprite.frame_coords = Vector2i(12, 2)
	hat_sprite.frame_coords = Vector2i(12, 2)
	hair_sprite.frame_coords = Vector2i(12, 2)
	arms_sprite.frame_coords = Vector2i(12, 3)
	beard_sprite.frame_coords = Vector2i(12, 1)
	eyes_sprite.frame_coords = Vector2i(12, 1)
	legs_sprite.frame_coords = Vector2i(12, 1)
	rod_sprite.frame_coords = Vector2i(0, 2)


func _set_anim_state(new_state: AnimState) -> void:
	current_anim_state = new_state
	match new_state:
		AnimState.IDLE:
			rod_sprite.visible = false
			arms_sprite.position = Vector2.ZERO
			_idle_anim_frame = 0
			_idle_anim_timer = 0.0
			_apply_idle_frames(0)
		AnimState.CAST_BEGIN:
			rod_sprite.visible = true
			rod_sprite.rotation_degrees = 0.0
			arms_sprite.position = Vector2.ZERO
			_apply_cast_begin_frames()
		AnimState.CAST_RELEASE:
			rod_sprite.visible = true
			rod_sprite.rotation_degrees = 0.0
			arms_sprite.position = Vector2.ZERO
			_cast_release_timer = CAST_RELEASE_DURATION
			_apply_cast_release_frames()
		AnimState.FISHING_IDLE:
			rod_sprite.visible = true
			rod_sprite.rotation_degrees = 0.0
			arms_sprite.position = Vector2.ZERO
			_fishing_idle_timer = 0.0
			_fishing_idle_toggle = false
			_apply_fishing_idle_frames()
		AnimState.REEL:
			rod_sprite.visible = true
			rod_sprite.rotation_degrees = 0.0
			arms_sprite.position = Vector2.ZERO
			_reel_timer = 0.0
			_reel_toggle = false
			_apply_fishing_idle_frames()


func get_rod_tip_position() -> Vector2:
	if not rod_sprite or not rod_sprite.visible:
		return global_position + Vector2(10, 24)
	return global_position + Vector2(5, 40)


func _on_fishing_state_changed(state: Enums.FishingState) -> void:
	match state:
		Enums.FishingState.IDLE:
			_set_anim_state(AnimState.IDLE)
		Enums.FishingState.CASTING:
			_set_anim_state(AnimState.CAST_BEGIN)
		Enums.FishingState.WAITING:
			_set_anim_state(AnimState.FISHING_IDLE)
		Enums.FishingState.FIGHTING, Enums.FishingState.REELING_IN:
			_set_anim_state(AnimState.REEL)


func _on_cast_started(_strength: float) -> void:
	_set_anim_state(AnimState.CAST_RELEASE)


func _on_cast_landed(_depth: float) -> void:
	pass


func _on_fight_started(_fish_id: String) -> void:
	_set_anim_state(AnimState.REEL)


func _on_fish_caught(_fish_id: String) -> void:
	_set_anim_state(AnimState.IDLE)


func _on_fish_escaped(_fish_id: String) -> void:
	_set_anim_state(AnimState.FISHING_IDLE)


func _on_line_snapped() -> void:
	_set_anim_state(AnimState.IDLE)


func _on_bite_occurred(_fish_id: String) -> void:
	_bite_dip_timer = BITE_DIP_DURATION
