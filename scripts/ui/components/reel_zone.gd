extends Control

signal reel_input_started
signal reel_input_ended

@export var active_color: Color = Color(0.2, 0.6, 1.0, 0.3)
@export var idle_color: Color = Color(0.3, 0.35, 0.5, 0.2)
@export var pulse_speed: float = 2.0
@export var compact_mode: bool = false

var is_held: bool = false
var pulse_time: float = 0.0
var background: ColorRect
var reel_label: Label


func _ready() -> void:
	_build_layout()
	mouse_filter = Control.MOUSE_FILTER_STOP


func _build_layout() -> void:
	if compact_mode:
		custom_minimum_size = Vector2(80, 80)

	background = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = idle_color
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	if compact_mode:
		reel_label = Label.new()
		reel_label.text = "REEL"
		reel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		reel_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		reel_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(reel_label)


func _process(delta: float) -> void:
	if is_held:
		pulse_time += delta * pulse_speed
		var alpha: float = lerpf(active_color.a * 0.5, active_color.a, (sin(pulse_time) + 1.0) * 0.5)
		background.color = Color(active_color.r, active_color.g, active_color.b, alpha)
	else:
		pulse_time = 0.0
		background.color = idle_color


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			_start_reel()
		else:
			_stop_reel()
	elif event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				_start_reel()
			else:
				_stop_reel()


func _start_reel() -> void:
	if is_held:
		return
	is_held = true
	reel_input_started.emit()
	SignalBus.reel_input_started.emit()
	HapticManager.light_tap()


func _stop_reel() -> void:
	if not is_held:
		return
	is_held = false
	reel_input_ended.emit()
	SignalBus.reel_input_ended.emit()
