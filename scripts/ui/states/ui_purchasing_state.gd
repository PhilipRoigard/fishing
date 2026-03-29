extends UIStateNode

var status_label: Label
var spinner_time: float = 0.0
var pending_product_id: String = ""


func enter(meta: Variant = null) -> void:
	super(meta)
	if meta is Dictionary:
		pending_product_id = meta.get("product_id", "")
	spinner_time = 0.0
	_build_layout()


func exit() -> void:
	super()
	_clear_children()


func _setup_connections() -> void:
	SignalBus.purchase_completed.connect(_on_purchase_completed)
	SignalBus.purchase_failed.connect(_on_purchase_failed)


func _cleanup_connections() -> void:
	SignalBus.purchase_completed.disconnect(_on_purchase_completed)
	SignalBus.purchase_failed.disconnect(_on_purchase_failed)


func _process(delta: float) -> void:
	if not visible:
		return
	spinner_time += delta
	if status_label:
		var dots: int = int(spinner_time * 2.0) % 4
		status_label.text = "Processing purchase" + ".".repeat(dots)


func _build_layout() -> void:
	var dimmer: ColorRect = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.6)
	add_child(dimmer)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	status_label = Label.new()
	status_label.text = "Processing purchase..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(status_label)


func _on_purchase_completed(product_id: String) -> void:
	if product_id == pending_product_id or pending_product_id == "":
		HapticManager.success_feedback()
		SignalBus.show_notification.emit("Purchase successful!", Color.GREEN)
		_back()


func _on_purchase_failed(product_id: String, _reason: String) -> void:
	if product_id == pending_product_id or pending_product_id == "":
		HapticManager.fail_feedback()
		SignalBus.show_notification.emit("Purchase failed", Color.RED)
		_back()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
