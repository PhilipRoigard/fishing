---
name: godot-ui-state-machine
description: Stack-based UI state machine for Godot game screens. Covers push/pop overlays, tab navigation, confirmation dialogs, safe zones, multilingual fonts, and common UI animation patterns. Use when building game UI, screen management, or popups.
user-invokable: false
---

## UIStateMachine (Stack-Based)

```gdscript
class_name UIStateMachine
extends Node

var _state_stack: Array[UIStateNode] = []
var _states: Dictionary = {}

func change_state(state_enum: int, meta: Dictionary = {}) -> void:
    while _state_stack.size() > 0:
        _state_stack.pop_back().exit()
    var new_state = _states[state_enum]
    _state_stack.push_back(new_state)
    new_state.enter(meta)
    new_state.focus()

func push_state(state_enum: int, meta: Dictionary = {}) -> void:
    if _state_stack.size() > 0:
        _state_stack.back().unfocus()
    var new_state = _states[state_enum]
    _state_stack.push_back(new_state)
    new_state.enter(meta)
    new_state.focus()

func pop_state() -> void:
    if _state_stack.size() <= 1: return
    _state_stack.pop_back().exit()
    if _state_stack.size() > 0:
        _state_stack.back().focus()
```

## UIStateNode Base Class

```gdscript
class_name UIStateNode
extends Control

enum Flags { DO_NOT_SHOW = 0, SHOW_CURRENCY = 1 << 0, SHOW_TABS = 1 << 1, ANIMATE = 1 << 2 }

func enter(meta: Dictionary = {}) -> void:
    visible = true; _setup_connections()
func focus() -> void:
    get_parent().move_child.call_deferred(self, -1)
func unfocus() -> void: pass
func exit() -> void:
    visible = false; _cleanup_connections()
func _setup_connections() -> void: pass
func _cleanup_connections() -> void: pass
```

## Unique Node References (always use %NodeName)

```gdscript
@onready var health_label: Label = %HealthLabel       # CORRECT
# @onready var label: Label = $VBox/Header/Label      # WRONG
```

## Confirmation Dialog Pattern

```gdscript
ui_state_machine.push_state(UIState.YES_NO_POPUP, {
    "description": "Abandon this run?",
    "yes_text": "Abandon", "no_text": "Cancel",
    "yes_callback": _on_abandon_confirmed,
    "no_callback": func(): ui_state_machine.pop_state(),
})
```

## Common UI Animations

```gdscript
# Button hover
func _on_mouse_entered() -> void:
    create_tween().tween_property(self, "scale", Vector2.ONE * 1.05, 0.2)

# Popup scale-in
panel.scale = Vector2.ZERO
create_tween().tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)

# Pulse loop
var tween = create_tween().set_loops()
tween.tween_property(node, "modulate:a", 0.5, 0.5)
tween.tween_property(node, "modulate:a", 1.0, 0.5)

# Timer flash (sine wave)
var modifier = 0.5 * sin(game_time * TAU) + 0.5
var color = lerp(original_color, Color.RED, modifier)
```

## Safe Zone Support (Mobile Notches)

```gdscript
class_name SafeZoneContainer
extends MarginContainer

func _ready() -> void:
    SafeZoneManager.safe_zones_updated.connect(_on_safe_zones_updated)

func _on_safe_zones_updated(top, bottom, left, right) -> void:
    add_theme_constant_override("margin_top", _base_margins.top + top)
    # ... same for bottom, left, right
```
