extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var sm: Variant = _get_sm()
	sm.change_state(2)
	await get_tree().create_timer(0.3).timeout

	sm.push_state(5)
	await get_tree().create_timer(0.3).timeout

	print("[PT] Coins: %d Level: %d Items: %d" % [CurrencyManager.coins, ProgressManager.get_current_level(), EquipmentManager.inventory.size()])
	_ss("eq_all")

	print("[PT] Testing Shop tab...")
	_ss("eq_shop_view")

	await get_tree().create_timer(0.3).timeout
	sm.pop_state()

	sm.push_state(10)
	await get_tree().create_timer(0.3).timeout
	_ss("tackle_box")
	sm.pop_state()

	await get_tree().create_timer(0.2).timeout
	_ss("hub_final")

	print("[PT] === DONE ===")
	print("[PT] Final - Coins: %d Items: %d" % [CurrencyManager.coins, EquipmentManager.inventory.size()])


func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")
	print("[PT] Screenshot: %s" % n)

func _get_sm() -> Variant:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			return u.get_state_machine()
	return null
