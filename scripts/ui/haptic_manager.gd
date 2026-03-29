extends Node


func light_tap() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(15)


func medium_tap() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(30)


func heavy_tap() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)


func success_feedback() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(40)


func fail_feedback() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(80)
