extends Control

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

@export var track_color: Color = Color(0.08, 0.1, 0.16, 0.95)
@export var track_border_color: Color = Color(0.25, 0.3, 0.4, 0.8)
@export var bracket_inside_color: Color = Color(0.15, 0.7, 0.4, 0.35)
@export var bracket_outside_color: Color = Color(0.85, 0.15, 0.15, 0.3)
@export var bracket_edge_inside_color: Color = Color(0.2, 0.9, 0.5, 0.9)
@export var bracket_edge_outside_color: Color = Color(1.0, 0.3, 0.2, 0.9)
@export var fish_icon_scale: float = 2.5
@export var restricted_zone_color: Color = Color(0.0, 0.0, 0.0, 0.5)
@export var track_corner_radius: float = 6.0

var fish_normalized_position: float = 0.5
var bracket_normalized_position: float = 0.5
var bracket_normalized_size: float = 0.25
var is_fish_inside: bool = false
var is_fish_stunned: bool = false
var is_range_restricted: bool = false
var restricted_min: float = 0.0
var restricted_max: float = 1.0

var fish_atlas_texture: AtlasTexture
var fish_id: String = ""
var track_padding: float = 4.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SignalBus.fish_track_position_changed.connect(_on_fish_position_changed)
	SignalBus.bracket_position_changed.connect(_on_bracket_position_changed)
	SignalBus.fight_started.connect(_on_fight_started)
	SignalBus.consumable_effect_started.connect(_on_effect_started)
	SignalBus.consumable_effect_ended.connect(_on_effect_ended)


func _exit_tree() -> void:
	if SignalBus.fish_track_position_changed.is_connected(_on_fish_position_changed):
		SignalBus.fish_track_position_changed.disconnect(_on_fish_position_changed)
	if SignalBus.bracket_position_changed.is_connected(_on_bracket_position_changed):
		SignalBus.bracket_position_changed.disconnect(_on_bracket_position_changed)
	if SignalBus.fight_started.is_connected(_on_fight_started):
		SignalBus.fight_started.disconnect(_on_fight_started)
	if SignalBus.consumable_effect_started.is_connected(_on_effect_started):
		SignalBus.consumable_effect_started.disconnect(_on_effect_started)
	if SignalBus.consumable_effect_ended.is_connected(_on_effect_ended):
		SignalBus.consumable_effect_ended.disconnect(_on_effect_ended)


func _on_fight_started(_fid: String) -> void:
	fish_id = _fid
	_setup_fish_texture()


func _setup_fish_texture() -> void:
	fish_atlas_texture = AtlasTexture.new()
	fish_atlas_texture.atlas = FISH_ATLAS
	var region: Rect2 = FISH_ATLAS_REGIONS.get(fish_id, Rect2(0, 0, 16, 16))
	fish_atlas_texture.region = region


func _on_fish_position_changed(pos: float) -> void:
	fish_normalized_position = pos
	queue_redraw()


func _on_bracket_position_changed(pos: float, bracket_size: float) -> void:
	bracket_normalized_position = pos
	bracket_normalized_size = bracket_size
	is_fish_inside = absf(fish_normalized_position - bracket_normalized_position) <= bracket_normalized_size * 0.5
	queue_redraw()


func _on_effect_started(effect: int) -> void:
	if effect == Enums.ConsumableEffect.RESTRICT_RANGE:
		is_range_restricted = true
		var range_size: float = 0.4
		if GameResources.config and GameResources.config.fishing_config:
			range_size = GameResources.config.fishing_config.depth_anchor_range
		restricted_min = clampf(fish_normalized_position - range_size * 0.5, 0.0, 1.0)
		restricted_max = clampf(fish_normalized_position + range_size * 0.5, 0.0, 1.0)
		queue_redraw()
	elif effect == Enums.ConsumableEffect.STUN:
		is_fish_stunned = true
		queue_redraw()


func _on_effect_ended(effect: int) -> void:
	if effect == Enums.ConsumableEffect.RESTRICT_RANGE:
		is_range_restricted = false
		queue_redraw()
	elif effect == Enums.ConsumableEffect.STUN:
		is_fish_stunned = false
		queue_redraw()


func _draw() -> void:
	var inner_x: float = track_padding
	var inner_w: float = size.x - track_padding * 2.0
	var inner_y: float = track_padding
	var inner_h: float = size.y - track_padding * 2.0

	draw_rect(Rect2(Vector2.ZERO, size), track_border_color)
	draw_rect(Rect2(track_padding, track_padding, inner_w, inner_h), track_color)

	if is_range_restricted:
		var top_h: float = restricted_min * inner_h
		if top_h > 0.0:
			draw_rect(Rect2(inner_x, inner_y, inner_w, top_h), restricted_zone_color)
		var bottom_y: float = inner_y + restricted_max * inner_h
		var bottom_h: float = inner_h - restricted_max * inner_h
		if bottom_h > 0.0:
			draw_rect(Rect2(inner_x, bottom_y, inner_w, bottom_h), restricted_zone_color)

	var bracket_half: float = bracket_normalized_size * 0.5
	var bracket_top: float = inner_y + (bracket_normalized_position - bracket_half) * inner_h
	var bracket_h: float = bracket_normalized_size * inner_h
	var fill_color: Color = bracket_inside_color if is_fish_inside else bracket_outside_color
	var edge_color: Color = bracket_edge_inside_color if is_fish_inside else bracket_edge_outside_color
	draw_rect(Rect2(inner_x, bracket_top, inner_w, bracket_h), fill_color)
	draw_rect(Rect2(inner_x, bracket_top, inner_w, 2.0), edge_color)
	draw_rect(Rect2(inner_x, bracket_top + bracket_h - 2.0, inner_w, 2.0), edge_color)

	var fish_y: float = inner_y + fish_normalized_position * inner_h
	if fish_atlas_texture:
		var tex_size: Vector2 = fish_atlas_texture.get_size() * fish_icon_scale
		var fish_pos: Vector2 = Vector2(
			inner_x + (inner_w - tex_size.x) * 0.5,
			fish_y - tex_size.y * 0.5
		)
		var fish_tint: Color = Color.WHITE if is_fish_inside else Color(1.0, 0.7, 0.7)
		if is_fish_stunned:
			fish_tint = Color(0.5, 0.75, 1.0)
		draw_texture_rect(fish_atlas_texture, Rect2(fish_pos, tex_size), false, fish_tint)
		if is_fish_stunned:
			var cx: float = fish_pos.x + tex_size.x * 0.5
			var cy: float = fish_pos.y + tex_size.y * 0.5
			var crystal_color: Color = Color(0.6, 0.9, 1.0, 0.7)
			draw_circle(Vector2(cx - 12.0, cy - 10.0), 3.0, crystal_color)
			draw_circle(Vector2(cx + 10.0, cy - 6.0), 2.5, crystal_color)
			draw_circle(Vector2(cx - 6.0, cy + 10.0), 2.0, crystal_color)
			draw_circle(Vector2(cx + 14.0, cy + 8.0), 3.5, crystal_color)
	else:
		var dot_size: float = 10.0
		var dot_color: Color = Color.WHITE if is_fish_inside else Color(1.0, 0.5, 0.5)
		if is_fish_stunned:
			dot_color = Color(0.5, 0.75, 1.0)
		draw_circle(Vector2(inner_x + inner_w * 0.5, fish_y), dot_size, dot_color)

	var center_line_color: Color = Color(0.3, 0.35, 0.45, 0.15)
	draw_line(
		Vector2(inner_x + inner_w * 0.5, inner_y),
		Vector2(inner_x + inner_w * 0.5, inner_y + inner_h),
		center_line_color, 1.0
	)


