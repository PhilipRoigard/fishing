extends Node

const PORT := 9081
const MAX_READ_BYTES := 1048576

var _tcp_server := TCPServer.new()
var _client: StreamPeerTCP = null
var _buffer := ""

func _ready():
	if not OS.is_debug_build():
		set_process(false)
		return

	var err: Error = _tcp_server.listen(PORT, "127.0.0.1")
	if err == OK:
		print("[MCPTestServer] Listening on port ", PORT)
	else:
		push_error("[MCPTestServer] Failed to listen on port %d: %d" % [PORT, err])
		set_process(false)

func _process(delta: float):
	if _tcp_server.is_connection_available():
		if _client != null:
			_client.disconnect_from_host()
		_client = _tcp_server.take_connection()
		_buffer = ""
		print("[MCPTestServer] Client connected")

	if _client == null:
		return

	_client.poll()
	if _client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		_client = null
		_buffer = ""
		return

	var available: int = _client.get_available_bytes()
	if available > 0:
		var data: String = _client.get_utf8_string(mini(available, MAX_READ_BYTES))
		_buffer += data
		_process_buffer()

func _process_buffer():
	while true:
		var newline_pos: int = _buffer.find("\n")
		if newline_pos == -1:
			break
		var line: String = _buffer.substr(0, newline_pos).strip_edges()
		_buffer = _buffer.substr(newline_pos + 1)
		if line.is_empty():
			continue
		_handle_message(line)

func _handle_message(json_str: String):
	var json := JSON.new()
	if json.parse(json_str) != OK:
		return
	var data: Dictionary = json.get_data()
	var command_type: String = data.get("type", "")
	var params: Dictionary = data.get("params", {})
	var command_id: String = data.get("commandId", "")

	match command_type:
		"screenshot":
			_cmd_screenshot(command_id)
		"click_at":
			_cmd_click_at(params, command_id)
		"click_node":
			_cmd_click_node(params, command_id)
		"press_action":
			_cmd_press_action(params, command_id)
		"get_tree":
			_cmd_get_tree(command_id)
		"get_node_info":
			_cmd_get_node_info(params, command_id)
		"read_text":
			_cmd_read_text(command_id)
		_:
			_send_error("Unknown command: " + command_type, command_id)

func _cmd_screenshot(command_id: String):
	var image: Image = get_viewport().get_texture().get_image()
	if image == null:
		_send_error("Failed to capture viewport image", command_id)
		return
	var path: String = OS.get_cache_dir() + "/godot_mcp_screenshot.png"
	var err: Error = image.save_png(path)
	if err != OK:
		_send_error("Failed to save screenshot: %d" % err, command_id)
		return
	_send_success({"path": path, "width": image.get_width(), "height": image.get_height()}, command_id)

func _cmd_click_at(params: Dictionary, command_id: String):
	var x: float = params.get("x", 0.0)
	var y: float = params.get("y", 0.0)
	var pos := Vector2(x, y)

	var down := InputEventMouseButton.new()
	down.position = pos
	down.global_position = pos
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	get_viewport().push_input(down)

	var up := InputEventMouseButton.new()
	up.position = pos
	up.global_position = pos
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	get_viewport().push_input(up)

	_send_success({"clicked_at": {"x": x, "y": y}}, command_id)

func _cmd_click_node(params: Dictionary, command_id: String):
	var node_path: String = params.get("path", "")
	if node_path.is_empty():
		_send_error("Node path is required", command_id)
		return

	var node: Node = _find_node(node_path)
	if node == null:
		_send_error("Node not found: " + node_path, command_id)
		return

	if node is BaseButton:
		node.pressed.emit()
		var pos = _get_node_screen_center(node)
		_send_success({
			"clicked_node": node_path,
			"screen_position": {"x": pos.x if pos else 0, "y": pos.y if pos else 0}
		}, command_id)
		return

	var screen_pos = _get_node_screen_center(node)
	if screen_pos == null:
		_send_error("Cannot determine screen position for node: " + node_path, command_id)
		return

	var down := InputEventMouseButton.new()
	down.position = screen_pos
	down.global_position = screen_pos
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	get_viewport().push_input(down)

	var up := InputEventMouseButton.new()
	up.position = screen_pos
	up.global_position = screen_pos
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	get_viewport().push_input(up)

	_send_success({
		"clicked_node": node_path,
		"screen_position": {"x": screen_pos.x, "y": screen_pos.y}
	}, command_id)

func _cmd_press_action(params: Dictionary, command_id: String):
	var action: String = params.get("action", "")
	var pressed: bool = params.get("pressed", true)
	var duration: float = params.get("duration", 0.0)

	if action.is_empty():
		_send_error("Action name is required", command_id)
		return

	if not InputMap.has_action(action):
		_send_error("Unknown input action: " + action, command_id)
		return

	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)

	if duration > 0.0 and pressed:
		get_tree().create_timer(duration).timeout.connect(func():
			Input.action_release(action)
		)

	_send_success({"action": action, "pressed": pressed, "duration": duration}, command_id)

func _cmd_get_tree(command_id: String):
	var tree_data: Dictionary = _build_tree(get_tree().root)
	_send_success({"tree": tree_data}, command_id)

func _cmd_get_node_info(params: Dictionary, command_id: String):
	var node_path: String = params.get("path", "")
	if node_path.is_empty():
		_send_error("Node path is required", command_id)
		return

	var node: Node = _find_node(node_path)
	if node == null:
		_send_error("Node not found: " + node_path, command_id)
		return

	var info: Dictionary = {
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path()),
		"child_count": node.get_child_count(),
	}

	if node is CanvasItem:
		info["visible"] = node.is_visible_in_tree()

	if node is Control:
		info["position"] = {"x": node.global_position.x, "y": node.global_position.y}
		info["size"] = {"width": node.size.x, "height": node.size.y}
		info["rect"] = {
			"x": node.global_position.x,
			"y": node.global_position.y,
			"width": node.size.x,
			"height": node.size.y
		}
	elif node is Node2D:
		info["position"] = {"x": node.global_position.x, "y": node.global_position.y}
		info["rotation"] = node.rotation
		info["scale"] = {"x": node.scale.x, "y": node.scale.y}

	if node is Label:
		info["text"] = node.text
	elif node is RichTextLabel:
		info["text"] = node.get_parsed_text()
	elif node is Button:
		info["text"] = node.text
		info["disabled"] = node.disabled
	elif node is LineEdit:
		info["text"] = node.text
		info["placeholder"] = node.placeholder_text

	var script = node.get_script()
	if script:
		info["script_path"] = script.resource_path

	_send_success(info, command_id)

func _cmd_read_text(command_id: String):
	var texts: Array[Dictionary] = []
	_collect_text(get_tree().root, texts)
	_send_success({"texts": texts, "count": texts.size()}, command_id)

func _collect_text(node: Node, texts: Array[Dictionary]):
	if node is CanvasItem and not node.is_visible_in_tree():
		return

	if node is Label and not node.text.is_empty():
		texts.append({
			"path": str(node.get_path()),
			"type": "Label",
			"text": node.text,
			"position": {"x": node.global_position.x, "y": node.global_position.y},
			"size": {"width": node.size.x, "height": node.size.y}
		})
	elif node is RichTextLabel:
		var parsed: String = node.get_parsed_text()
		if not parsed.is_empty():
			texts.append({
				"path": str(node.get_path()),
				"type": "RichTextLabel",
				"text": parsed,
				"position": {"x": node.global_position.x, "y": node.global_position.y},
				"size": {"width": node.size.x, "height": node.size.y}
			})
	elif node is Button and not node.text.is_empty():
		texts.append({
			"path": str(node.get_path()),
			"type": "Button",
			"text": node.text,
			"disabled": node.disabled,
			"position": {"x": node.global_position.x, "y": node.global_position.y},
			"size": {"width": node.size.x, "height": node.size.y}
		})
	elif node is LineEdit and not node.text.is_empty():
		texts.append({
			"path": str(node.get_path()),
			"type": "LineEdit",
			"text": node.text,
			"position": {"x": node.global_position.x, "y": node.global_position.y},
			"size": {"width": node.size.x, "height": node.size.y}
		})

	for child in node.get_children():
		_collect_text(child, texts)

func _build_tree(node: Node, depth: int = 0) -> Dictionary:
	var data: Dictionary = {
		"name": node.name,
		"type": node.get_class(),
	}

	if depth > 0:
		data["path"] = str(node.get_path())

	if node is CanvasItem:
		data["visible"] = node.is_visible_in_tree()

	if node is Control:
		data["position"] = {"x": node.global_position.x, "y": node.global_position.y}
		data["size"] = {"width": node.size.x, "height": node.size.y}
	elif node is Node2D:
		data["position"] = {"x": node.global_position.x, "y": node.global_position.y}

	if node is Label:
		data["text"] = node.text
	elif node is Button:
		data["text"] = node.text

	var children: Array[Dictionary] = []
	if depth < 15:
		for child in node.get_children():
			children.append(_build_tree(child, depth + 1))

	if children.size() > 0:
		data["children"] = children

	return data

func _find_node(path: String) -> Node:
	if path.begins_with("/"):
		return get_tree().root.get_node_or_null(path)

	var result: Node = _find_node_by_name(get_tree().root, path)
	if result != null:
		return result

	return get_tree().root.get_node_or_null(path)

func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_name(child, target_name)
		if found != null:
			return found
	return null

func _get_node_screen_center(node: Node) -> Variant:
	if node is Control:
		var rect: Rect2 = node.get_global_rect()
		return rect.position + rect.size / 2.0
	elif node is Node2D:
		var transform: Transform2D = node.get_viewport_transform() * node.get_global_transform()
		return transform.origin
	return null

func _send_success(result: Dictionary, command_id: String):
	var response: Dictionary = {"status": "success", "result": result}
	if not command_id.is_empty():
		response["commandId"] = command_id
	_send_json(response)

func _send_error(message: String, command_id: String):
	var response: Dictionary = {"status": "error", "message": message}
	if not command_id.is_empty():
		response["commandId"] = command_id
	_send_json(response)

func _send_json(data: Dictionary):
	if _client == null:
		return
	var json_str: String = JSON.stringify(data) + "\n"
	_client.put_data(json_str.to_utf8_buffer())

func _exit_tree():
	if _client != null:
		_client.disconnect_from_host()
	if _tcp_server.is_listening():
		_tcp_server.stop()
	print("[MCPTestServer] Stopped")
