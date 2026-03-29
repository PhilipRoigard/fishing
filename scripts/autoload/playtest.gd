extends Node

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	var m: Node = get_node_or_null("/root/Main")
	if not m:
		return
	var u: Node = m.get_node_or_null("UIManager")
	if u and u.has_method("get_state_machine"):
		u.get_state_machine().change_state(2)
		await get_tree().create_timer(0.5).timeout
		get_viewport().get_texture().get_image().save_png("/tmp/pt_fresh_hub.png")
		print("[QT] Hub screenshot taken")
		print("[QT] Coins: %d Gems: %d" % [CurrencyManager.coins, CurrencyManager.gems])
		print("[QT] Items: %d" % EquipmentManager.inventory.size())
		for item in EquipmentManager.inventory:
			print("[QT] Item: %s type=%s quality=%d" % [item.item_id, item.equipment_type, item.quality])
		u.get_state_machine().push_state(5)
		await get_tree().create_timer(0.5).timeout
		get_viewport().get_texture().get_image().save_png("/tmp/pt_fresh_eq.png")
		print("[QT] Equipment screenshot taken")
	set_process(false)
