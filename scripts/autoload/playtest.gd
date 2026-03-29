extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var sm: Variant = _get_sm()
	sm.change_state(2)
	await get_tree().create_timer(0.3).timeout
	sm.change_state(3)
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var f: Node = m.get_node_or_null("FishingSystem")
		if f and f.has_method("start_fishing"):
			f.start_fishing()
	await get_tree().create_timer(1.0).timeout
	_ss("fishing_view")
	await get_tree().create_timer(3.0).timeout
	_ss("fishing_with_fish")
	print("[PT] Done")

func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")

func _get_sm() -> Variant:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			return u.get_state_machine()
	return null
