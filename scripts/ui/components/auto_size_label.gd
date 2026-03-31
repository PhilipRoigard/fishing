@tool
class_name AutoSizeLabel
extends Label

@export var max_font_size: int = 24
@export var multiline: bool = false

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
	if multiline:
		return # Need to figure out something else for this case

	var translation := TranslationServer.get_translation_object(TranslationServer.get_locale())
	var translated_text = translation.get_message(new_text)
	if translated_text != "":
		new_text = translated_text

	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")
	var suitable_font_size: int = -1

	# Apply font scale from FontManager (skip in editor to avoid tool script errors)
	var s: float = 1.0
	if not Engine.is_editor_hint() and FontManager:
		s = FontManager.current_scale
	var scaled_max := int(max_font_size * s)

	var line := TextLine.new()
	line.direction = text_direction as TextServer.Direction
	line.flags = justification_flags
	line.alignment = horizontal_alignment

	for i in scaled_max:
		line.clear()
		var created := line.add_string(new_text, font, font_size)
		if created:
			var text_size := line.get_line_width()

			if text_size > floor(size.x):
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

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		update_font_size(text)
