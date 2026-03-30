@tool
class_name AutoSizeButton
extends Button

@export var max_font_size: int = 24

func _ready() -> void:
	clip_contents = true
	item_rect_changed.connect(_on_item_rect_changed)
	update_font_size(text)


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			if value != text:
				update_font_size(value)
	return false


func update_font_size(new_text: String) -> void:
	var font: Font = get_theme_font("font")
	var font_size: int = get_theme_font_size("font_size")
	var suitable_font_size: int = -1

	var scaled_max: int = max_font_size

	var line: TextLine = TextLine.new()
	line.direction = text_direction as TextServer.Direction
	line.alignment = alignment

	for i: int in scaled_max:
		line.clear()
		var created: bool = line.add_string(new_text, font, font_size)
		if created:
			var text_size: float = line.get_line_width()

			if text_size > floor(size.x) - 10:
				if suitable_font_size > 0:
					font_size = suitable_font_size
					break
				if font_size == 1:
					break
				font_size -= 1
			elif font_size < scaled_max:
				suitable_font_size = font_size
				font_size += 1
			else:
				break
		else:
			push_warning("Could not create a string")
			break

	add_theme_font_size_override("font_size", font_size)


func _on_item_rect_changed() -> void:
	update_font_size(text)
