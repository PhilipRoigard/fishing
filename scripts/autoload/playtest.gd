extends Node

var step: int = 0
var timer: float = 0.0
var enabled: bool = false


func _ready() -> void:
	enabled = OS.has_feature("debug")
	if not enabled:
		set_process(false)


func _process(delta: float) -> void:
	if not enabled:
		return
	timer += delta
	match step:
		0:
			if timer > 1.5:
				_nav(2)
				step = 1
				timer = 0.0
		1:
			if timer > 1.0:
				_ss("01_hub")
				_start_fishing()
				step = 2
				timer = 0.0
		2:
			if timer > 0.5:
				_press()
				step = 3
				timer = 0.0
		3:
			if timer > 1.0:
				_ss("02_casting")
				_release()
				step = 4
				timer = 0.0
		4:
			if timer > 1.5:
				_ss("03_line")
				step = 5
				timer = 0.0
		5:
			if timer > 8.0:
				_ss("04_bite")
				_press()
				await get_tree().create_timer(0.05).timeout
				_release()
				step = 6
				timer = 0.0
		6:
			if timer > 1.0:
				var sn: String = _sn()
				if sn == "FightingState":
					_ss("05_fight")
					_press()
					step = 7
				else:
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
				timer = 0.0
		7:
			if timer > 4.0:
				_ss("06_result")
				_release()
				step = 8
				timer = 0.0
		8:
			if timer > 3.0:
				_ss("07_final")
				print("[PT] DONE state=%s coins=%d items=%d" % [_sn(), CurrencyManager.coins, EquipmentManager.inventory.size()])
				set_process(false)
				step = 99


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

func _start_fishing() -> void:
	_nav(3)
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var f: Node = m.get_node_or_null("FishingSystem")
		if f and f.has_method("start_fishing"):
			f.start_fishing()
