---
name: godot-resource-config
description: Data-driven game configuration using Godot Resource classes. Covers root config aggregators, per-level stat arrays, export groups, weighted random selection, difficulty scaling, and preload vs load patterns. Use when creating game configs or balance systems.
user-invokable: false
---

## Philosophy

Game balance values -> Resource configs (.gd + .tres). Component defaults -> @export is fine.

## Root Config Aggregator

```gdscript
class_name GameResourcesConfig
extends Resource

@export var all_abilities: Array[AbilityData] = []
@export var all_passives: Array[BaseAbilityData] = []
@export var lunchbox_config: LunchboxConfig
@export var item_system_config: ItemSystemConfig
```

Loaded once by autoload: `GameResources.config.item_system_config.all_items`

## Per-Level Stat Arrays

```gdscript
@export_group("Per-Level Stats")
@export var damage_by_level: Array[float] = []
@export var cooldown_by_level: Array[float] = []

func get_damage_at_level(level: int) -> float:
    if level <= 0 or level > damage_by_level.size(): return 0.0
    return damage_by_level[level - 1]
```

## Export Group Organization

```gdscript
class_name EnemyConfig
extends Resource

@export_group("Movement")
@export var speed: float = 100.0
@export_group("Combat")
@export var health: int = 3
@export_group("Drops")
@export var drop_config: ItemDropConfig
```

## Weighted Random Selection

```gdscript
class_name ItemDropConfig
extends Resource

@export var drop_chance: float = 0.1
@export var drops: Array[ItemDropItem] = []

func get_dropped_item() -> Item:
    if randf() > drop_chance: return null
    var total_weight := 0.0
    for drop in drops: total_weight += drop.weight
    var roll := randf() * total_weight
    var cumulative := 0.0
    for drop in drops:
        cumulative += drop.weight
        if roll <= cumulative: return drop.item
    return null
```

## Preload vs Load

```gdscript
var enemy_scene = preload("res://scenes/enemy.tscn")      # Compile-time, always needed
var config = load("res://resources/game_resources.tres")   # Runtime, one-time startup
```
