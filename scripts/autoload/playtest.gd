extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout

	var sm: Variant = _get_ui_sm()
	sm.change_state(2)
	await get_tree().create_timer(0.3).timeout
	_ss("01_hub_fresh")

	_start_fishing()
	await get_tree().create_timer(0.3).timeout
	_press()
	await get_tree().create_timer(0.8).timeout
	_release()

	for i: int in 20:
		await get_tree().create_timer(1.0).timeout
		var sn: String = _sn()
		if sn == "BiteAlertState":
			_press()
			await get_tree().create_timer(0.05).timeout
			_release()
			await get_tree().create_timer(0.3).timeout
			break
		if sn == "FightingState":
			break

	if _sn() == "FightingState":
		_press()
		await get_tree().create_timer(2.5).timeout
		_release()
		await get_tree().create_timer(1.0).timeout
		_press()
		await get_tree().create_timer(3.0).timeout
		_release()
		await get_tree().create_timer(1.0).timeout
		_press()
		await get_tree().create_timer(4.0).timeout
		_release()

	await get_tree().create_timer(1.0).timeout
	_ss("02_catch_result")
	print("[PT] State after fight: %s" % _sn())
	print("[PT] Coins: %d" % CurrencyManager.coins)

	await get_tree().create_timer(1.0).timeout

	if Main.instance and Main.instance.fishing_system:
		Main.instance.fishing_system.stop_fishing()
	sm.change_state(2)
	await get_tree().create_timer(0.5).timeout
	_ss("03_hub_after")

	sm.push_state(7)
	await get_tree().create_timer(0.5).timeout
	_ss("04_collection")
	sm.pop_state()

	await get_tree().create_timer(0.3).timeout
	print("[PT] Final coins: %d" % CurrencyManager.coins)
	print("[PT] === COMPLETE ===")


func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")
	print("[PT] %s state=%s" % [n, _sn()])

func _sn() -> String:
	var m: Node = get_node_or_null("/root/Main")
	if not m: return "?"
	var fs: Node = m.get_node_or_null("FishingSystem")
	if fs:
		var sm: Node = fs.get_node_or_null("FishingStateMachine")
		if sm and sm.get("current_state"):
			return sm.get("current_state").name
	return "?"

func _get_ui_sm() -> Variant:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			return u.get_state_machine()
	return null

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
	var sm: Variant = _get_ui_sm()
	if sm:
		sm.change_state(3)
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var f: Node = m.get_node_or_null("FishingSystem")
		if f and f.has_method("start_fishing"):
			f.start_fishing()
