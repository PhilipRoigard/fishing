extends MarginContainer
class_name SafeZoneContainer

var base_margin_left: int = 0
var base_margin_top: int = 0
var base_margin_right: int = 0
var base_margin_bottom: int = 0

func _ready():
	_store_base_margins()
	_setup_safe_zone_manager()

func _store_base_margins():
	base_margin_left = get_theme_constant("margin_left")
	base_margin_top = get_theme_constant("margin_top")
	base_margin_right = get_theme_constant("margin_right")
	base_margin_bottom = get_theme_constant("margin_bottom")

func _setup_safe_zone_manager():
	if not SafeZoneManager.safe_zones_updated.is_connected(_on_safe_zones_updated):
		SafeZoneManager.safe_zones_updated.connect(_on_safe_zones_updated)

	var margins = SafeZoneManager.get_safe_margins()
	_on_safe_zones_updated(margins.top, margins.bottom, margins.left, margins.right)

func _on_safe_zones_updated(top: float, bottom: float, left: float, right: float):
	add_theme_constant_override("margin_left", base_margin_left + int(left))
	add_theme_constant_override("margin_top", base_margin_top + int(top))
	add_theme_constant_override("margin_right", base_margin_right + int(right))
	add_theme_constant_override("margin_bottom", base_margin_bottom + int(bottom))
