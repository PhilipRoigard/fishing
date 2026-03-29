extends Node

var step: int = 0
var timer: float = 0.0
var cast_num: int = 0
var issues: PackedStringArray = PackedStringArray()


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	timer += delta

	match step:
		0:
			if timer > 1.5:
				_nav(2)
				step = 1
				timer = 0.0

		1:
			if timer > 0.5:
				_start_fishing()
				step = 10
				timer = 0.0

		10:
			if timer > 0.3:
				cast_num += 1
				print("[PT] === CAST #%d ===" % cast_num)
				_press()
				step = 11
				timer = 0.0
		11:
			if timer > 0.8:
				_release()
				step = 12
				timer = 0.0
		12:
			if timer > 12.0:
				var sn: String = _sn()
				if sn == "BiteAlertState":
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
					step = 13
				elif sn == "FightingState":
					step = 13
				else:
					print("[PT] Waiting too long, retrying tap")
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
				timer = 0.0
		13:
			if timer > 0.5:
				if _sn() == "FightingState":
					_press()
					step = 14
				elif _sn() == "BiteAlertState":
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
				timer = 0.0
		14:
			if timer > 2.5:
				_release()
				step = 15
				timer = 0.0
		15:
			if timer > 1.0:
				_press()
				step = 16
				timer = 0.0
		16:
			if timer > 3.0:
				_release()
				step = 17
				timer = 0.0
		17:
			if timer > 1.0:
				_press()
				step = 18
				timer = 0.0
		18:
			if timer > 4.0:
				_release()
				var sn: String = _sn()
				print("[PT] Cast #%d result: %s" % [cast_num, sn])
				if sn == "SuccessState":
					_ss("catch_%d" % cast_num)
				elif sn == "FailState" or sn == "IdleState":
					_ss("fail_%d" % cast_num)
				step = 19
				timer = 0.0
		19:
			if timer > 3.0:
				_press()
				await get_tree().create_timer(0.05).timeout
				_release()
				step = 20
				timer = 0.0
		20:
			if timer > 1.0:
				if cast_num < 3:
					var sn: String = _sn()
					if sn != "IdleState":
						if Main.instance and Main.instance.fishing_system:
							Main.instance.fishing_system.stop_fishing()
							Main.instance.fishing_system.start_fishing()
					step = 10
				else:
					step = 30
				timer = 0.0

		30:
			if timer > 0.5:
				if Main.instance and Main.instance.fishing_system:
					Main.instance.fishing_system.stop_fishing()
				_nav(2)
				step = 31
				timer = 0.0
		31:
			if timer > 0.5:
				_ss("hub_after_3_casts")
				print("[PT] After 3 casts - Coins: %d Items: %d" % [CurrencyManager.coins, EquipmentManager.inventory.size()])
				_push(5)
				step = 32
				timer = 0.0
		32:
			if timer > 0.5:
				_ss("equipment_check")
				_pop()
				step = 33
				timer = 0.0
		33:
			if timer > 0.3:
				_push(7)
				step = 34
				timer = 0.0
		34:
			if timer > 0.5:
				_ss("collection_after_casts")
				_pop()
				step = 35
				timer = 0.0
		35:
			if timer > 0.3:
				print("[PT] === ALL TESTS COMPLETE ===")
				print("[PT] Casts: %d  Issues: %d" % [cast_num, issues.size()])
				for issue: String in issues:
					print("[PT] ISSUE: %s" % issue)
				set_process(false)


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

func _nav(s: int) -> void:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			u.get_state_machine().change_state(s)

func _push(s: int) -> void:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			u.get_state_machine().push_state(s)

func _pop() -> void:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var u: Node = m.get_node_or_null("UIManager")
		if u and u.has_method("get_state_machine"):
			u.get_state_machine().pop_state()

func _start_fishing() -> void:
	_nav(3)
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var f: Node = m.get_node_or_null("FishingSystem")
		if f and f.has_method("start_fishing"):
			f.start_fishing()
