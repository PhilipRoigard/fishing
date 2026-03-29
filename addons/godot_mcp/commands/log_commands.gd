@tool
class_name MCPLogCommands
extends MCPBaseCommandProcessor

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"get_editor_log_live":
			_get_editor_log_live(client_id, params, command_id)
			return true
		"debug_find_log_panel":
			_debug_find_log_panel(client_id, params, command_id)
			return true
	return false

func _get_editor_log_live(client_id: int, params: Dictionary, command_id: String) -> void:
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var base_control = editor_interface.get_base_control()

	var editor_log = _find_editor_log_node(base_control)
	if not editor_log:
		return _send_error(client_id, "Could not find EditorLog node in the editor.", command_id)

	var log_node: RichTextLabel = null
	for child in editor_log.get_children():
		if child is RichTextLabel:
			log_node = child
			break

	if not log_node:
		return _send_error(client_id, "Could not find RichTextLabel inside EditorLog.", command_id)

	var full_text: String = log_node.get_text()
	var lines = full_text.split("\n")
	var max_lines: int = params.get("max_lines", 100)
	var filter_text: String = params.get("filter", "")

	var filtered_lines: PackedStringArray = PackedStringArray()
	for line in lines:
		if filter_text.is_empty() or line.to_lower().contains(filter_text.to_lower()):
			filtered_lines.append(line)

	if filtered_lines.size() > max_lines:
		filtered_lines = filtered_lines.slice(filtered_lines.size() - max_lines)

	var log_output = "\n".join(filtered_lines)

	_send_success(client_id, {
		"log": log_output,
		"source": "editor_output_panel",
		"line_count": filtered_lines.size()
	}, command_id)

func _debug_find_log_panel(client_id: int, params: Dictionary, command_id: String) -> void:
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var base_control = editor_interface.get_base_control()

	var results: Array[String] = []
	_collect_richtext_info(base_control, results, 0)

	_send_success(client_id, {
		"richtext_nodes": results,
		"count": results.size()
	}, command_id)

func _collect_richtext_info(node: Node, results: Array[String], depth: int) -> void:
	if node is RichTextLabel:
		var p = node.get_parent()
		var pname = str(p.name) if p else "none"
		var pclass = str(p.get_class()) if p else "none"
		results.append("name=%s parent_name=%s parent_class=%s depth=%d" % [node.name, pname, pclass, depth])

	for child in node.get_children():
		_collect_richtext_info(child, results, depth + 1)

func _find_editor_log_node(node: Node) -> Node:
	if node.get_class() == "EditorLog":
		return node

	for child in node.get_children():
		var found = _find_editor_log_node(child)
		if found:
			return found

	return null
