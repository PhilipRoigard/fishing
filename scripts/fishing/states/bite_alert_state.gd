extends BaseState

var fish_id: String = ""
var depth: float = 0.0
var fish_node: Node = null
var window_timer: float = 0.0
var bite_window: float = 2.0
var hooked: bool = false


func enter(meta: Dictionary = {}) -> void:
	fish_id = meta.get("fish_id", "")
	depth = meta.get("depth", 0.0)
	fish_node = meta.get("fish_node", null)
	hooked = false
	window_timer = 0.0
	if GameResources.config and GameResources.config.fishing_config:
		bite_window = GameResources.config.fishing_config.bite_window
	SignalBus.bite_occurred.emit(fish_id)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.BITE_ALERT)
	SignalBus.reel_input_started.connect(_on_reel_input)


func exit() -> void:
	if SignalBus.reel_input_started.is_connected(_on_reel_input):
		SignalBus.reel_input_started.disconnect(_on_reel_input)


func update(delta: float) -> void:
	window_timer += delta
	if window_timer >= bite_window and not hooked:
		SignalBus.bite_missed.emit()
		if fish_node and is_instance_valid(fish_node) and fish_node is SwimmingFish:
			(fish_node as SwimmingFish)._is_curious = false
		state_machine.change_state(&"waiting", {"depth": depth})


func _on_reel_input() -> void:
	if hooked:
		return
	hooked = true
	state_machine.change_state(&"fighting", {
		"fish_id": fish_id,
		"depth": depth,
		"fish_node": fish_node,
	})
