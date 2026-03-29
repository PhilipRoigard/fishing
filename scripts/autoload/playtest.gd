extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var sm: Variant = _get_sm()
	sm.change_state(2)
	await get_tree().create_timer(0.3).timeout
	sm.push_state(5)
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png("/tmp/pt_eq_fixed.png")
	print("[PT] Equipment screenshot taken")

func _get_sm() -> Variant:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			return u.get_state_machine()
	return null
