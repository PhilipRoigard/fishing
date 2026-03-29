extends Node

func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	var m: Node = get_node_or_null("/root/Main")
	if not m:
		return
	var u: Node = m.get_node_or_null("UIManager")
	if not u or not u.has_method("get_state_machine"):
		return
	var sm: Variant = u.get_state_machine()

	sm.change_state(2)
	await get_tree().create_timer(0.5).timeout
	_ss("hub")

	_start_fishing()
	await get_tree().create_timer(0.5).timeout
	_press()
	await get_tree().create_timer(0.8).timeout
	_release()
	await get_tree().create_timer(12.0).timeout

	for i: int in 5:
		_press()
		await get_tree().create_timer(0.05).timeout
		_release()
		await get_tree().create_timer(0.5).timeout

	var sn: String = _sn()
	if sn == "FightingState":
		_press()
		await get_tree().create_timer(8.0).timeout
		_release()
		await get_tree().create_timer(2.0).timeout
		_ss("catch_result")
		sn = _sn()
		print("[PT] After fight: %s" % sn)
	else:
		print("[PT] Not in fight: %s" % sn)

	await get_tree().create_timer(2.0).timeout
	_ss("after_dismiss")

	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.stop_fishing()
	sm.change_state(2)
	await get_tree().create_timer(0.5).timeout

	sm.push_state(7)
	await get_tree().create_timer(0.5).timeout
	_ss("collection_with_sprites")

	sm.pop_state()
	await get_tree().create_timer(0.3).timeout
	_ss("hub_final")

	print("[PT] Coins: %d" % CurrencyManager.coins)
	print("[PT] === DONE ===")


func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")
	print("[PT] %s" % n)

func _sn() -> String:
	var m: Node = get_node_or_null("/root/Main")
	if not m: return "?"
	var fs: Node = m.get_node_or_null("FishingSystem")
	if fs:
		var sm: Node = fs.get_node_or_null("FishingStateMachine")
		if sm and sm.get("current_state"):
			return sm.get("current_state").name
	return "?"

func _press() -> void:
	var e: InputEventMouseButton = InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = Vector2(180, 400)
	Input.parse_input_event(e)

func _release() -> void:
	var e: InputEventMouseButton = InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = false
	e.position = Vector2(180, 400)
	Input.parse_input_event(e)

func _start_fishing() -> void:
	var m: Node = get_node_or_null("/root/Main")
	if not m: return
	var u: Node = m.get_node_or_null("UIManager")
	if u and u.has_method("get_state_machine"):
		u.get_state_machine().change_state(3)
	var f: Node = m.get_node_or_null("FishingSystem")
	if f and f.has_method("start_fishing"):
		f.start_fishing()
