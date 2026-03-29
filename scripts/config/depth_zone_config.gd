class_name DepthZoneConfig
extends Resource

@export var zones: Array[DepthZoneEntry] = []


func get_zone_for_depth(depth: float) -> DepthZoneEntry:
	for zone: DepthZoneEntry in zones:
		if depth >= zone.min_depth and depth < zone.max_depth:
			return zone
	if not zones.is_empty():
		return zones.back()
	return null


func get_zone_enum_for_depth(depth: float) -> Enums.DepthZone:
	var zone: DepthZoneEntry = get_zone_for_depth(depth)
	if zone:
		return zone.zone_type
	return Enums.DepthZone.SHALLOWS
