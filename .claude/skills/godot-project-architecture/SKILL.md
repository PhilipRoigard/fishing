---
name: godot-project-architecture
description: Godot 4.4+ project structure, autoload singletons, Main scene bootstrap, factory pattern, and dependency injection. Use when setting up new Godot projects, creating autoloads, bootstrapping game systems, or accessing game managers.
user-invokable: false
---

## Project Structure Convention

```
project_root/
  scripts/           # All GDScript files organized by system
    abilities/       # Active ability implementations
    config/          # Resource class definitions for configuration
    enemy/           # Enemy system (behaviors, states, boss)
    experience/      # XP and leveling
    items/           # Pickups, chests, lunchboxes
    map/             # Map generation and chunks
    monetization/    # IAP and ads integration
    player/          # Player character and systems
    progression/     # Currency, unlocks, persistence
    spawn/           # Wave spawning system
    status_effects/  # Debuffs and buffs
    systems/         # Core systems (damage, stats, coins, rewards)
    tools/           # Debug and development tools
    ui/              # UI system (states, components, world)
      buttons/       # Reusable button components
      components/    # Reusable UI components
      states/        # UI state machine screens
      world/         # In-world UI (health bars, damage numbers)
  scenes/            # All .tscn scene files
    ui_states/       # UI screen scenes
    ui_components/   # Reusable UI component scenes
  resources/         # All .tres resource files
    data/            # Game data configs (abilities, enemies, items, etc.)
    textures/        # Sprite frames and atlases
    materials/       # Shaders and materials
    ui/              # UI themes, fonts, style boxes
  effects/           # Visual effects (particles, trails)
  translations/      # Localization files
```

## Autoload Architecture

Register autoloads in `project.godot` under `[autoload]`. **Critical**: Autoload scripts must NEVER have `class_name` - causes "Class hides an autoload singleton" errors.

```gdscript
# CORRECT autoload script
extends Node
# No class_name here!

signal my_signal
func do_thing() -> void:
    pass
```

## Main Scene Bootstrap Pattern

Main scene acts as game orchestrator with phased initialization:

```gdscript
class_name Main
extends Node

static var instance: Main

var player: Player
var experience_system: ExperienceSystem
var upgrade_system: UpgradeSystem
var ability_controller: AbilitySystem
var damage_system: DamageSystem
var spawn_manager: SpawnManager

func _ready() -> void:
    instance = self
    SignalBus.game_started.connect(_start_game)

func _start_game() -> void:
    await _initialize_game_systems()

func _initialize_game_systems() -> void:
    _load_game_map()
    _initialize_enemy_manager()
    _create_player()
    experience_system = ExperienceSystem.new()
    upgrade_system = UpgradeSystem.new()
    ability_controller = AbilitySystem.new()
    damage_system = DamageSystem.new()
    _link_systems()
    _grant_starting_abilities()
```

## Accessing Game Systems

```gdscript
Main.instance.spawn_manager          # Per-game systems via Main.instance
CurrencyManager.get_essence()        # Autoloads by global name
EnemyManager.get_instance()          # Singleton getter pattern
# NEVER: get_tree().get_nodes_in_group("spawn_manager")
```

## Factory Pattern for Entities

```gdscript
class_name Player
extends Entity

static func create_player(config: PlayerConfig) -> Player:
    var scene = preload("res://scenes/player.tscn")
    var player = scene.instantiate() as Player
    player.initialize(config)
    return player
```

## Dependency Injection via Initialize

```gdscript
class_name DamageSystem
extends Node

var _item_effect_system: ItemEffectSystem

func initialize(item_effect_system: ItemEffectSystem, player: Player) -> void:
    _item_effect_system = item_effect_system
```
