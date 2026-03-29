## State Machine

```gdscript
class_name EnemyStateMachine
extends RefCounted

var _states: Dictionary = {}
var _current_state: EnemyState

func transition_to(state_name: String) -> void:
    if _current_state: _current_state.exit()
    _current_state = _states[state_name]
    _current_state.enter()

func update(delta: float) -> void:
    if _current_state: _current_state.update(delta)
```

## Behavior System (Strategy Pattern)

```gdscript
class_name EnemyBehavior
extends RefCounted

func get_desired_velocity(enemy: Enemy, player_pos: Vector2) -> Vector2:
    return Vector2.ZERO

class_name EnemyBehaviorConfig
extends Resource

@export var behavior_script: GDScript

func create_behavior_instance() -> EnemyBehavior:
    return behavior_script.new()
```

## Spatial Grid

```gdscript
class_name SpatialGrid
extends RefCounted

var _cell_size: float = 64.0
var _grid: Dictionary = {}

func query_radius(position: Vector2, radius: float) -> Array[Enemy]:
    var results: Array[Enemy] = []
    var radius_sq = radius * radius
    var min_cell = _world_to_cell(position - Vector2.ONE * radius)
    var max_cell = _world_to_cell(position + Vector2.ONE * radius)
    for x in range(min_cell.x, max_cell.x + 1):
        for y in range(min_cell.y, max_cell.y + 1):
            var cell = Vector2i(x, y)
            if _grid.has(cell):
                for enemy in _grid[cell]:
                    if enemy.global_position.distance_squared_to(position) <= radius_sq:
                        results.append(enemy)
    return results
```

## Object Pooling

```gdscript
# enemy_pool_manager.gd (autoload - NO class_name)
var _pools: Dictionary = {}

func get_enemy(config: EnemyConfig) -> Enemy:
    if not _pools.has(config):
        _pools[config] = []
        _grow_pool(config, 20)
    if _pools[config].size() == 0:
        _grow_pool(config, 10)
    var enemy = _pools[config].pop_back()
    enemy.reset_state()
    return enemy

func return_enemy(enemy: Enemy) -> void:
    enemy.visible = false
    _pools[enemy.config].append(enemy)
```

## Boss System

```gdscript
class_name Boss
extends Enemy

var attack_queue: Array[BossAttackConfig] = []

func get_next_attack() -> BossAttackConfig:
    match config.sequence_mode:
        BossConfig.SequenceMode.CYCLIC: return _get_cyclic_attack()
        BossConfig.SequenceMode.WEIGHTED_RANDOM: return _get_weighted_random_attack()
    return null
```
