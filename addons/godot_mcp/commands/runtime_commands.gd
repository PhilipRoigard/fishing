@tool
class_name MCPRuntimeCommands
extends MCPBaseCommandProcessor

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"run_scene":
			_run_scene(client_id, params, command_id)
			return true
		"stop_scene":
			_stop_scene(client_id, params, command_id)
			return true
		"is_game_running":
			_is_game_running(client_id, params, command_id)
			return true
	return false

func _run_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	if EditorInterface.is_playing_scene():
		return _send_error(client_id, "A scene is already running. Stop it first.", command_id)

	var scene_path: String = params.get("scene_path", "")

	if scene_path.is_empty():
		EditorInterface.play_main_scene()
		_send_success(client_id, {"message": "Main scene launched", "running": true}, command_id)
	else:
		if not FileAccess.file_exists(scene_path):
			return _send_error(client_id, "Scene not found: " + scene_path, command_id)
		EditorInterface.play_custom_scene(scene_path)
		_send_success(client_id, {"message": "Scene launched: " + scene_path, "running": true}, command_id)

func _stop_scene(client_id: int, _params: Dictionary, command_id: String) -> void:
	if not EditorInterface.is_playing_scene():
		return _send_success(client_id, {"message": "No scene is running", "running": false}, command_id)

	EditorInterface.stop_playing_scene()
	_send_success(client_id, {"message": "Scene stopped", "running": false}, command_id)

func _is_game_running(client_id: int, _params: Dictionary, command_id: String) -> void:
	var running := EditorInterface.is_playing_scene()
	_send_success(client_id, {"running": running}, command_id)
