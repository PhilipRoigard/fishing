extends Node

var step: int = 0
var timer: float = 0.0
var fight_log_timer: float = 0.0
var fight_logged: bool = false


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	timer += delta

	if _sn() == "FightingState" and not fight_logged:
		fight_log_timer += delta
		if fight_log_timer > 0.5:
			fight_log_timer = 0.0
			var fs: Node = _get_fighting_state()
			if fs:
				print("[PT] FIGHT: progress=%.1f tension=%.1f reeling=%s" % [
					fs.get("progress"), fs.get("tension"), str(fs.get("is_reeling"))])

	match step:
		0:
			if timer > 1.5:
				_nav(2)
				step = 1
				timer = 0.0
		1:
			if timer > 0.5:
				_start_fishing()
				step = 2
				timer = 0.0
		2:
			if timer > 0.5:
				_press()
				step = 3
				timer = 0.0
		3:
			if timer > 0.8:
				_ss("cast")
				_release()
				step = 4
				timer = 0.0
		4:
			if timer > 1.5:
				_ss("line_dropped")
				var hook: Vector2 = _get_hook_pos()
				print("[PT] Hook at: %s line_visible: %s" % [str(hook), str(_is_line_visible())])
				step = 5
				timer = 0.0
		5:
			if timer > 10.0:
				var sn: String = _sn()
				print("[PT] After 10s wait: %s" % sn)
				if sn == "BiteAlertState":
					_ss("bite")
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
					step = 6
				elif sn == "FightingState":
					step = 6
				elif sn == "WaitingState":
					print("[PT] Still waiting - forcing tap in case bite was missed")
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
					step = 5
				timer = 0.0
		6:
			if timer > 0.5:
				var sn: String = _sn()
				if sn == "FightingState":
					_ss("fight_start")
					print("[PT] === FIGHT STARTED - testing hold/release pattern ===")
					_press()
					step = 7
				elif sn == "BiteAlertState":
					_press()
					await get_tree().create_timer(0.05).timeout
					_release()
				timer = 0.0
		7:
			if timer > 2.5:
				_ss("fight_holding")
				_release()
				print("[PT] Released to manage tension")
				step = 8
				timer = 0.0
		8:
			if timer > 1.5:
				_ss("fight_released")
				_press()
				print("[PT] Reeling again")
				step = 9
				timer = 0.0
		9:
			if timer > 2.5:
				_ss("fight_reel2")
				_release()
				step = 10
				timer = 0.0
		10:
			if timer > 1.5:
				_press()
				step = 11
				timer = 0.0
		11:
			if timer > 3.0:
				_ss("fight_reel3")
				_release()
				step = 12
				timer = 0.0
		12:
			if timer > 1.0:
				_press()
				step = 13
				timer = 0.0
		13:
			if timer > 4.0:
				var sn: String = _sn()
				_ss("fight_end_" + sn)
				_release()
				fight_logged = true
				print("[PT] Fight ended in state: %s" % sn)
				step = 14
				timer = 0.0
		14:
			if timer > 3.0:
				_ss("result")
				print("[PT] === DONE ===")
				set_process(false)


func _ss(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/pt_" + n + ".png")
	print("[PT] Screenshot: %s state=%s" % [n, _sn()])

func _sn() -> String:
	var m: Node = get_node_or_null("/root/Main")
	if not m: return "?"
	var fs: Node = m.get_node_or_null("FishingSystem")
	if fs:
		var sm: Node = fs.get_node_or_null("FishingStateMachine")
		if sm and sm.get("current_state"):
			return sm.get("current_state").name
	return "?"

func _get_fighting_state() -> Node:
	var m: Node = get_node_or_null("/root/Main")
	if not m: return null
	var fs: Node = m.get_node_or_null("FishingSystem")
	if fs:
		var sm: Node = fs.get_node_or_null("FishingStateMachine")
		if sm:
			return sm.get("current_state")
	return null

func _get_hook_pos() -> Vector2:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var h: Node = m.get_node_or_null("FishingLevel/HookLayer/Hook")
		if h: return h.position
	return Vector2.ZERO

func _is_line_visible() -> bool:
	var m: Node = get_node_or_null("/root/Main")
	if m:
		var l: Node = m.get_node_or_null("FishingLevel/HookLayer/FishingLine")
		if l: return l.visible and l.get_point_count() > 0
	return false

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
