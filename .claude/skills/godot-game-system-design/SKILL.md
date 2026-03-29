---
name: godot-game-system-design
description: Game system architecture patterns for Godot 4.4+. System template with init/cleanup lifecycle, dependency injection depth, zero-UI-in-systems rule, and validation checklist. Use when creating or modifying game systems like ExperienceSystem, AbilitySystem, ItemSystem, SpawnSystem.
user-invokable: false
---

## System Structure Template

Every game system follows this pattern:

```gdscript
class_name ExampleSystem
extends Node

signal system_state_changed(new_state: Dictionary)

var config: ExampleSystemConfig
var player: Player
var _is_initialized: bool = false

func init(p_player: Player, p_config: ExampleSystemConfig) -> void:
    player = p_player
    config = p_config
    _is_initialized = true
    _setup()

func _setup() -> void:
    SignalBus.some_event.connect(_on_some_event)

func _ready() -> void:
    assert(_is_initialized, "System must be initialized via init() before ready")

func cleanup() -> void:
    if SignalBus.some_event.is_connected(_on_some_event):
        SignalBus.some_event.disconnect(_on_some_event)
    _is_initialized = false

func _on_some_event(data: Dictionary) -> void:
    pass
```

## Dependency Injection via init()

Systems receive ALL dependencies through `init()`. Order matters in Main.gd - create dependencies first:

```gdscript
func _initialize_systems() -> void:
    experience_system = ExperienceSystem.new()
    experience_system.init(game_config.experience_config)
    add_child(experience_system)

    # AbilitySystem depends on experience_system
    ability_system = AbilitySystem.new()
    ability_system.init(player, experience_system, game_config.ability_config)
    add_child(ability_system)
```

## Zero UI in Systems

Systems contain game logic ONLY. Never create UI nodes, never update UI directly. Emit to SignalBus, let UI respond:

```gdscript
# CORRECT - system emits signal
func gain_experience(amount: int) -> void:
    current_experience += amount
    SignalBus.experience_updated.emit(current_experience, required_experience)

# WRONG - system touching UI
func gain_experience(amount: int) -> void:
    current_experience += amount
    ui_manager.update_experience_bar(current_experience)  # NEVER
```

## Cleanup Lifecycle

Every system must implement `cleanup()` called by Main.gd on reset/death/restart:

```gdscript
func cleanup() -> void:
    # 1. Disconnect all SignalBus connections
    if SignalBus.player_died.is_connected(_on_player_died):
        SignalBus.player_died.disconnect(_on_player_died)
    # 2. Clear internal state
    _inventory.clear()
    _active_effects.clear()
    # 3. Clean up timers/tweens
    for timer in get_children():
        if timer is Timer:
            timer.queue_free()
    _is_initialized = false
```

## System Validation Checklist

Before completing a system:
- No magic numbers - all values from Resource configs
- No UI code - only SignalBus signals
- Dependencies passed via `init()`
- Proper `cleanup()` that disconnects signals and resets state
- `assert(_is_initialized)` in `_ready()`
- Internal state is private, exposed via signals
- Uses `preload()` for configs

## System Implementation Workflow

1. Define requirements
2. Identify dependencies (what other systems/components needed)
3. Design SignalBus integration (signals to emit/listen)
4. Create Config Resource class + .tres file
5. Implement core logic with dependency injection
6. Add cleanup/reset functionality
7. Update Main.gd with creation and initialization
8. Add signal definitions to SignalBus
