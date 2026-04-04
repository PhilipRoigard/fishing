extends Node2D

enum BobberState {
	HIDDEN,
	IDLE,
	BITE,
	FIGHT,
}

var current_state: BobberState = BobberState.HIDDEN
var bob_time: float = 0.0
var shake_time: float = 0.0
var bite_dip_timer: float = 0.0

var body_color: Color = Color(0.9, 0.15, 0.1)
var highlight_color: Color = Color(1.0, 1.0, 1.0, 0.7)
var bobber_radius: float = 6.0

const BOB_AMPLITUDE: float = 2.0
const BOB_PERIOD: float = 2.0
const BITE_DIP_AMOUNT: float = 8.0
const BITE_DIP_DURATION: float = 0.3
const SHAKE_INTENSITY: float = 2.0


func _ready() -> void:
	SignalBus.fishing_state_changed.connect(_on_fishing_state_changed)
	SignalBus.bite_occurred.connect(_on_bite_occurred)
	_set_state(BobberState.HIDDEN)


func _process(delta: float) -> void:
	match current_state:
		BobberState.IDLE:
			bob_time += delta
			position.y = sin(bob_time * TAU / BOB_PERIOD) * BOB_AMPLITUDE
		BobberState.BITE:
			bite_dip_timer -= delta
			if bite_dip_timer > 0.0:
				var dip_t: float = bite_dip_timer / BITE_DIP_DURATION
				position.y = BITE_DIP_AMOUNT * (1.0 - dip_t)
			else:
				position.y = 0.0
		BobberState.FIGHT:
			shake_time += delta
			position.x = sin(shake_time * 40.0) * SHAKE_INTENSITY
			position.y = cos(shake_time * 33.0) * SHAKE_INTENSITY * 0.5
		BobberState.HIDDEN:
			pass


func _draw() -> void:
	if current_state == BobberState.HIDDEN:
		return

	draw_circle(Vector2.ZERO, bobber_radius, body_color)

	var white_bottom: Color = Color(1.0, 1.0, 1.0, 0.9)
	draw_circle(Vector2(0.0, bobber_radius * 0.5), bobber_radius * 0.5, white_bottom)

	draw_arc(Vector2(-1.0, -2.0), bobber_radius * 0.4, -PI * 0.3, PI * 0.5, 12, highlight_color, 1.5)


func _set_state(new_state: BobberState) -> void:
	current_state = new_state
	position = Vector2.ZERO
	bob_time = 0.0
	shake_time = 0.0
	visible = new_state != BobberState.HIDDEN
	queue_redraw()


func _on_fishing_state_changed(state: int) -> void:
	match state:
		Enums.FishingState.WAITING:
			_set_state(BobberState.IDLE)
		Enums.FishingState.BITE_ALERT:
			_set_state(BobberState.BITE)
		Enums.FishingState.FIGHTING:
			_set_state(BobberState.FIGHT)
		Enums.FishingState.REELING_IN:
			_set_state(BobberState.HIDDEN)
		_:
			_set_state(BobberState.HIDDEN)


func _on_bite_occurred(_fish_id: String) -> void:
	bite_dip_timer = BITE_DIP_DURATION
