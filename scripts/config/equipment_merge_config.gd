class_name EquipmentMergeConfig
extends Resource

@export var merge_requirements: Array[MergeRequirement] = []


func get_requirement_for_quality(quality: Enums.ItemQuality) -> MergeRequirement:
	for req: MergeRequirement in merge_requirements:
		if req.from_quality == quality:
			return req
	return null


func can_merge(quality: Enums.ItemQuality) -> bool:
	return get_requirement_for_quality(quality) != null
