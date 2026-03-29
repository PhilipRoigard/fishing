## Object Pooling

```gdscript
var _pools: Dictionary = {}

func get_enemy(config: EnemyConfig) -> Enemy:
    if not _pools.has(config):
        _pools[config] = []; _grow_pool(config, 20)
    if _pools[config].size() == 0: _grow_pool(config, 10)
    var enemy = _pools[config].pop_back()
    enemy.reset_state()
    return enemy

func return_enemy(enemy: Enemy) -> void:
    enemy.visible = false
    _pools[enemy.config].append(enemy)
```

## Spatial Grid

```gdscript
class_name SpatialGrid
extends RefCounted

func query_radius(position: Vector2, radius: float) -> Array[Node2D]:
    var results: Array[Node2D] = []
    var radius_sq = radius * radius
    var min_cell = _to_cell(position - Vector2.ONE * radius)
    var max_cell = _to_cell(position + Vector2.ONE * radius)
    for x in range(min_cell.x, max_cell.x + 1):
        for y in range(min_cell.y, max_cell.y + 1):
            if _grid.has(Vector2i(x, y)):
                for entity in _grid[Vector2i(x, y)]:
                    if entity.global_position.distance_squared_to(position) <= radius_sq:
                        results.append(entity)
    return results
```

## Update Bucketing

```gdscript
const BUCKET_COUNT: int = 10

func _process(delta: float) -> void:
    var bucket_index = Engine.get_process_frames() % BUCKET_COUNT
    var bucket_delta = delta * BUCKET_COUNT
    for entity in _update_buckets[bucket_index]:
        if is_instance_valid(entity): entity.update(bucket_delta)
```

## Typed Array Best Practices

```gdscript
# WRONG - loses typing
var enemies: Array[Enemy] = active_enemies.filter(func(e): return e.is_alive)

# CORRECT
var enemies: Array[Enemy] = []
enemies.assign(active_enemies.filter(func(e): return e.is_alive))
```

## Damage Number Pool

```gdscript
const POOL_SIZE: int = 100
const MAX_PER_FRAME: int = 10

func spawn(position: Vector2, result: DamageResult) -> void:
    if _spawned_this_frame >= MAX_PER_FRAME: return
    if _pool.size() == 0: return
    _spawned_this_frame += 1
    var dn = _pool.pop_back()
    dn.global_position = position + _random_offset()
    dn.display(result)
    dn.visible = true
```
