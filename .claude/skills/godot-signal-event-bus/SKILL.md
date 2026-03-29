---
name: godot-signal-event-bus
description: Centralized SignalBus pattern for Godot game event architecture. Covers safe connect/disconnect, broadcast vs request patterns, signal naming conventions, and event flow tracing. Use when implementing cross-system communication or game events.
user-invokable: false
---

## SignalBus Pattern

Centralized autoload singleton as game event hub (NO class_name):

```gdscript
extends Node

signal player_health_changed(health: float)
signal player_death_started
signal player_death_finished
signal enemy_defeated(enemy: Enemy)
signal game_started
signal game_ended
signal dealt_damage(damage: float, source: String)
signal spawn_pause_requested
signal boss_spawned(boss_name: String, max_health: float)
signal show_upgrade_choices(choices: Array[ChoiceData])
signal upgrade_applied(upgrade_type: String, upgrade_name: String, level: int)
```

## Safe Connect/Disconnect Pattern

```gdscript
func _ready() -> void:
    if not SignalBus.enemy_defeated.is_connected(_on_enemy_defeated):
        SignalBus.enemy_defeated.connect(_on_enemy_defeated)

func _exit_tree() -> void:
    if SignalBus.enemy_defeated.is_connected(_on_enemy_defeated):
        SignalBus.enemy_defeated.disconnect(_on_enemy_defeated)
```

## When to Use What

- **SignalBus**: Game-wide events with multiple listeners (player death, enemy defeated)
- **Local signals**: Parent-child communication (`choice_selected`, `buy_pressed`)
- **Direct refs**: Immediate state queries (`Main.instance.coin_system.get_coins()`)

## Signal Naming Conventions

| Pattern | Example | When |
|---------|---------|------|
| `noun_verbed` | `enemy_defeated` | Something happened |
| `noun_property_changed` | `player_health_changed` | State updated |
| `action_requested` | `spawn_pause_requested` | Request to another system |
| `action_confirmed` | `lunchbox_purchase_confirmed` | After validation |

## Event Flow Example

```
Enemy health <= 0
  -> SignalBus.enemy_defeated(enemy)
     -> DelveManager: increments kill count
     -> ChestRewardSystem: checks chest spawn
     -> AudioManager: plays death sound
     -> StatsSystem: tracks kill stats
```
