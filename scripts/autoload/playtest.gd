extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var sm: Variant = _get_sm()
	sm.change_state(2)
	await get_tree().create_timer(0.3).timeout
	sm.push_state(5)
	await get_tree().create_timer(0.5).timeout

	var eq_state: Node = sm._get_active_state_node()
	if eq_state and eq_state.has_method("_on_filter_pressed"):
		eq_state._on_filter_pressed(5)
	await get_tree().create_timer(0.5).timeout

	sm.show_tooltip("Bronze Rod\nUncommon\n\nCast Depth: 1000m\nReel Speed: 1.1x\nTension Resist: 1.2x\n\nCost: 300 coins\nRequires: Lv.2")
	await get_tree().create_timer(1.0).timeout
	_ss("tooltip_popup")
	print("[PT] Done")

func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")
	print("[PT] %s" % n)

func _get_sm() -> Variant:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			return u.get_state_machine()
	return null
