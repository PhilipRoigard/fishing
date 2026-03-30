class_name VirtualizedItemGrid
extends Control

signal card_selected(card: ItemCard, index: int)

@export var h_separation: int = 6
@export var v_separation: int = 6
@export var buffer_rows: int = 2

var _item_card_scene: PackedScene = preload("res://scenes/ui/components/item_card.tscn")
var _card_pool: Array[ItemCard] = []
var _active_cards: Dictionary = {}
var _data_items: Array = []
var _columns: int = 4
var _card_size: Vector2 = Vector2(70, 70)
var _scroll_container: ScrollContainer
var _configure_callback: Callable
var _last_visible_start: int = -1
var _last_visible_end: int = -1
var _cached_offset_x: float = 0.0


func setup(scroll_container: ScrollContainer, configure_callback: Callable) -> void:
	_scroll_container = scroll_container
	_configure_callback = configure_callback
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	if not _scroll_container.get_v_scroll_bar().value_changed.is_connected(_on_scroll_changed):
		_scroll_container.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)


func set_data(items: Array) -> void:
	_data_items = items
	_recycle_all_cards()
	_update_layout()
	_force_refresh.call_deferred()


func get_card_for_index(index: int) -> ItemCard:
	return _active_cards.get(index, null) as ItemCard


func get_all_active_cards() -> Array[ItemCard]:
	var cards: Array[ItemCard] = []
	for card: Variant in _active_cards.values():
		cards.append(card as ItemCard)
	return cards


func clear() -> void:
	_data_items.clear()
	_recycle_all_cards()
	custom_minimum_size = Vector2.ZERO


func update_columns(available_width: float) -> void:
	if _card_size.x <= 0:
		return
	var cell_width: float = _card_size.x + h_separation
	var cols: int = int(available_width / cell_width)
	_columns = maxi(cols, 1)
	_update_layout()
	_force_refresh()


func _update_layout() -> void:
	var total_rows: int = ceili(float(_data_items.size()) / float(_columns)) if _columns > 0 else 0
	var row_height: float = _card_size.y + v_separation
	var total_height: float = total_rows * row_height - (v_separation if total_rows > 0 else 0)
	custom_minimum_size = Vector2(0, maxf(total_height, 0.0))
	var cell_width: float = _card_size.x + h_separation
	var total_grid_width: float = _columns * cell_width - h_separation
	_cached_offset_x = (size.x - total_grid_width) / 2.0 if size.x > total_grid_width else 0.0


func _on_scroll_changed(_value: float) -> void:
	_update_visible_cards()


func _update_visible_cards() -> void:
	if _data_items.is_empty() or not _scroll_container:
		return

	var row_height: float = _card_size.y + v_separation
	if row_height <= 0:
		return

	var grid_top: float = global_position.y
	var scroll_top: float = _scroll_container.global_position.y
	var scroll_bottom: float = scroll_top + _scroll_container.size.y

	var relative_scroll_top: float = scroll_top - grid_top
	var relative_scroll_bottom: float = scroll_bottom - grid_top

	var first_visible_row: int = maxi(0, int(relative_scroll_top / row_height) - buffer_rows)
	var last_visible_row: int = int(relative_scroll_bottom / row_height) + buffer_rows

	var total_rows: int = ceili(float(_data_items.size()) / float(_columns))
	last_visible_row = mini(last_visible_row, total_rows - 1)
	first_visible_row = maxi(first_visible_row, 0)

	var first_item: int = first_visible_row * _columns
	var last_item: int = mini((last_visible_row + 1) * _columns - 1, _data_items.size() - 1)

	if first_item == _last_visible_start and last_item == _last_visible_end:
		return

	_last_visible_start = first_item
	_last_visible_end = last_item

	var needed_indices: Dictionary = {}
	for i: int in range(first_item, last_item + 1):
		needed_indices[i] = true

	var to_recycle: Array[int] = []
	for idx: int in _active_cards:
		if not needed_indices.has(idx):
			to_recycle.append(idx)

	for idx: int in to_recycle:
		_recycle_card(idx)

	for i: int in range(first_item, last_item + 1):
		if not _active_cards.has(i):
			_show_card(i)


func _show_card(index: int) -> void:
	if index < 0 or index >= _data_items.size():
		return

	var card: ItemCard = _acquire_card()
	_active_cards[index] = card

	var row: int = index / _columns
	var col: int = index % _columns
	var cell_width: float = _card_size.x + h_separation
	var row_height: float = _card_size.y + v_separation

	card.position = Vector2(_cached_offset_x + col * cell_width, row * row_height)
	card.size = _card_size
	card.visible = true

	if _configure_callback.is_valid():
		_configure_callback.call(card, index, _data_items[index])


func _recycle_card(index: int) -> void:
	if not _active_cards.has(index):
		return
	var card: ItemCard = _active_cards[index] as ItemCard
	_active_cards.erase(index)
	card.visible = false
	_disconnect_card(card)
	_card_pool.append(card)


func _recycle_all_cards() -> void:
	for idx: int in _active_cards.keys():
		var card: ItemCard = _active_cards[idx] as ItemCard
		card.visible = false
		_disconnect_card(card)
		_card_pool.append(card)
	_active_cards.clear()
	_last_visible_start = -1
	_last_visible_end = -1


func _acquire_card() -> ItemCard:
	if not _card_pool.is_empty():
		var card: ItemCard = _card_pool.pop_back()
		_disconnect_card(card)
		card.set_selected(false)
		card.set_dimmed(false)
		card.self_modulate = Color.WHITE
		return card

	var card: ItemCard = _item_card_scene.instantiate() as ItemCard
	add_child(card)
	card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	return card


func _disconnect_card(card: ItemCard) -> void:
	for connection: Dictionary in card.selected.get_connections():
		card.selected.disconnect(connection["callable"] as Callable)


func _force_refresh() -> void:
	_last_visible_start = -1
	_last_visible_end = -1
	_recycle_all_cards()
	_update_visible_cards()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_layout()
		_reposition_active_cards()
		_update_visible_cards()


func _reposition_active_cards() -> void:
	var cell_width: float = _card_size.x + h_separation
	var row_height: float = _card_size.y + v_separation
	for idx: int in _active_cards:
		var card: ItemCard = _active_cards[idx] as ItemCard
		var row: int = idx / _columns
		var col: int = idx % _columns
		card.position = Vector2(_cached_offset_x + col * cell_width, row * row_height)
