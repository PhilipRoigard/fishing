## FileAccess (Simple Data)

```gdscript
func _save() -> void:
    var file = FileAccess.open("user://data.tres", FileAccess.WRITE)
    file.store_var({"essence": _essence, "gems": _gems})

func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH): return
    var data = FileAccess.open(SAVE_PATH, FileAccess.READ).get_var()
    if data is Dictionary: _essence = data.get("essence", 0)
```

## Singleton Resource Pattern

```gdscript
class_name ItemProgressionData
extends Resource

const SAVE_PATH = "user://item_progression.tres"
static var _instance: ItemProgressionData

static var instance: ItemProgressionData:
    get:
        if _instance == null:
            if ResourceLoader.exists(SAVE_PATH):
                var loaded = ResourceLoader.load(SAVE_PATH)
                if loaded is ItemProgressionData:
                    _instance = loaded
                    return _instance
            _instance = ItemProgressionData.new()
        return _instance

func save() -> void:
    ResourceSaver.save(self, SAVE_PATH)
```

## PlayerPrefs

```gdscript
class_name PlayerPrefs
extends Resource

enum PrefKeys { SEEN_HOW_TO_PLAY, PLAYED_AT_LEAST_ONCE, TOTAL_DELVES_COMPLETED }

static func get_pref(key: PrefKeys, default_value = null):
    return instance.items.get(key, default_value)

static func set_pref(key: PrefKeys, value) -> void:
    instance.items[key] = value; _save()
```

## Stats Tracking

```gdscript
func commit(new_stats: Dictionary, config: StatsConfig) -> void:
    for stat_key in new_stats:
        total_stats[stat_key] = total_stats.get(stat_key, 0) + new_stats[stat_key]
        if stat_config.is_lower_score_better:
            if value < best_stats.get(stat_key, INF): best_stats[stat_key] = value
        else:
            if value > best_stats.get(stat_key, 0): best_stats[stat_key] = value
```

## Delve Session (Difficulty Scaling)

```gdscript
func get_enemy_health_multiplier() -> float:
    return pow(1.5, current_delve_level - 1)

func get_spawn_cooldown_multiplier() -> float:
    return max(pow(0.85, current_delve_level - 1), 0.1)
```
