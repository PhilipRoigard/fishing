extends UIStateNode

var loading_label: Label
var dots_timer: float = 0.0
var dot_count: int = 0


func enter(_meta: Variant = null) -> void:
	super(_meta)
	_build_layout()
	_begin_loading()


func exit() -> void:
	super()
	_clear_children()


func _process(delta: float) -> void:
	if not visible:
		return
	dots_timer += delta
	if dots_timer >= 0.4:
		dots_timer = 0.0
		dot_count = (dot_count + 1) % 4
		if loading_label:
			loading_label.text = "Loading" + ".".repeat(dot_count)


func _build_layout() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	loading_label = Label.new()
	loading_label.text = "Loading"
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(loading_label)


func _begin_loading() -> void:
	await get_tree().create_timer(0.5).timeout
	if visible:
		state_machine.change_state(UIStateMachine.State.WHARF_HUB)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
