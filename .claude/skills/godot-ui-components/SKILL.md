---
name: godot-ui-components
description: UI component architecture for Godot 4.4+. Container-based layouts, mandatory theme usage, text scaling, presentation-only rule, and MCP-first workflow. Use when creating or modifying UI scenes, components, panels, or HUD elements.
user-invokable: false
---

## MCP-First UI Creation

Always use Godot MCP tools for UI creation - never create UI nodes programmatically:
- `mcp_godot-mcp_create_scene` for new UI scenes
- `mcp_godot-mcp_create_node` to add UI elements
- Set theme on root Control to `res://resources/ui_theme.tres`

## Container-Based Layout

Always use container nodes for layout. Never manually position UI elements.

```
MarginContainer (root - provides screen edge padding)
└── VBoxContainer (stacks vertically)
    ├── Label (title)
    ├── HBoxContainer (arranges horizontally)
    │   ├── Button (option 1)
    │   └── Button (option 2)
    └── Label (description)
```

**Container reference**: MarginContainer (padding), VBoxContainer/HBoxContainer (stacking), CenterContainer (centering), GridContainer (grid), ScrollContainer (overflow), PanelContainer (themed background).

**Size flags**: `SIZE_EXPAND_FILL` (take available space), `SIZE_SHRINK_CENTER` (shrink and center), `SIZE_FILL` (fill without expanding).

Manual positioning only for: floating damage numbers, world-space UI, particles, custom layout algorithms.

## Mandatory Theme Usage

ALL UI uses `res://resources/ui_theme.tres`. Never style controls in code.

```gdscript
# WRONG
button.add_theme_color_override("font_color", Color.RED)
var style := StyleBoxFlat.new()
panel.add_theme_stylebox_override("panel", style)

# CORRECT - set theme_type_variation in scene
# e.g., "PrimaryButton", "HeaderLabel", "CardPanel"
```

**Adding variants**: Open ui_theme.tres -> Add type variation (e.g., "CallToActionButton" based on Button) -> Set properties -> Use via `theme_type_variation` on nodes.

Common variations: PrimaryButton, SecondaryButton, DangerButton, TitleLabel, HeaderLabel, CaptionLabel, ErrorLabel, CardPanel, DialogPanel.

## Text Scaling

Text must never push containers beyond bounds:

```gdscript
func set_text_with_scaling(text: String) -> void:
    content_label.text = text
    content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content_label.clip_text = true
    await get_tree().process_frame

    var container_size: Vector2 = get_size()
    var content_size: Vector2 = content_label.get_minimum_size()
    if content_size.y > container_size.y or content_size.x > container_size.x:
        var scale_factor: float = min(
            container_size.y / content_size.y,
            container_size.x / content_size.x
        )
        var current_font_size: int = content_label.get_theme_font_size("font_size")
        content_label.add_theme_font_size_override("font_size",
            max(ui_config.min_font_size, int(current_font_size * scale_factor)))
```

## UI Is Presentation Only

UI components must NEVER contain game logic or call game systems directly.

```gdscript
# CORRECT - signal-only communication
signal start_pressed
signal settings_changed(new_settings: Dictionary)

@onready var start_button: Button = %StartButton

func _ready() -> void:
    start_button.pressed.connect(func(): start_pressed.emit())

func update_health_display(current: int, maximum: int) -> void:
    health_bar.value = (float(current) / float(maximum)) * 100.0

# WRONG
func _on_start_pressed() -> void:
    GameManager.start_game()  # NEVER call systems from UI
```

**UI does**: Display data, emit signals on interaction, animate, handle input forwarding.
**UI never does**: Call game managers, manage game state, make gameplay decisions, access player data directly.

## Quality Checklist

- No programmatic UI creation (use MCP tools)
- Unique node references (`%NodeName`) not path-based
- No hardcoded constants (use Resources)
- No direct system access (signals only)
- No game logic (presentation only)
- No text overflow (dynamic scaling)
- Layout fits window dimensions
- No theme overrides in code (use ui_theme.tres)
- Container-based layout
- Reusable component scenes
