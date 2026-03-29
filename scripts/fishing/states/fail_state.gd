extends BaseState

var fish_id: String = ""
var return_delay: float = 2.0


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")

	_reset_hook_position()

	SignalBus.fish_escaped.emit(fish_id)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.FAIL)
	HapticManager.fail_feedback()

	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		await tree.create_timer(return_delay).timeout
		state_machine.change_state(&"idle")


func exit() -> void:
	pass


func _reset_hook_position() -> void:
	var fishing_level: Node = null
	if Main.instance:
		fishing_level = Main.instance.get_node_or_null("FishingLevel")
	if fishing_level:
		var hook: Area2D = fishing_level.get_node_or_null("%Hook")
		if hook:
			hook.position = Vector2(180, 400)
			SignalBus.hook_position_changed.emit(hook.global_position)
