extends BaseState

var target_depth: float = 0.0
var bite_timer: float = 0.0
var bite_delay: float = 0.0
var fishing_config: FishingConfig
var nibble_timer: float = 0.0
var nibble_interval: float = 2.0


func enter(meta: Dictionary = {}) -> void:
	target_depth = meta.get("depth", 100.0)
	if GameResources.config:
		fishing_config = GameResources.config.fishing_config
	if fishing_config:
		bite_delay = randf_range(fishing_config.bite_delay_min, fishing_config.bite_delay_max)
	else:
		bite_delay = randf_range(3.0, 8.0)
	bite_timer = 0.0
	nibble_timer = 0.0
	nibble_interval = randf_range(1.0, 3.0)
	SignalBus.fishing_state_changed.emit(Enums.FishingState.WAITING)


func exit() -> void:
	pass


func update(delta: float) -> void:
	bite_timer += delta
	nibble_timer += delta

	if nibble_timer >= nibble_interval:
		nibble_timer = 0.0
		nibble_interval = randf_range(1.0, 3.0)
		SignalBus.show_floating_text.emit("...", Vector2(200, 300), Color(1.0, 1.0, 1.0, 0.5))

	if bite_timer >= bite_delay:
		_trigger_bite()


func _trigger_bite() -> void:
	var fish_data: FishData = null
	if Main.instance and Main.instance.database_system:
		fish_data = Main.instance.database_system.get_fish_for_depth(target_depth)

	if fish_data:
		state_machine.change_state(&"bite_alert", {"fish_id": fish_data.id, "depth": target_depth})
	else:
		bite_timer = 0.0
		if fishing_config:
			bite_delay = randf_range(fishing_config.bite_delay_min, fishing_config.bite_delay_max)
