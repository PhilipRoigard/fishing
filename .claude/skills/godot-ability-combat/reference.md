## AbilitySystem

```gdscript
class_name AbilitySystem
extends Node

var _abilities: Array[AbilityInstance] = []

func _process(delta: float) -> void:
    for ability in _abilities:
        ability.cooldown_remaining -= delta
        if ability.cooldown_remaining <= 0.0:
            ability.scene_instance.trigger()
            ability.cooldown_remaining = ability.data.get_cooldown_at_level(ability.level)
```

## BaseAbility (Multiplier Stacking)

```gdscript
func get_damage() -> float:
    var base = _get_ability_data().get_damage_at_level(_get_level())
    var item_mult = _player.item_effect_system.get_total_damage_multiplier()
    var upgrade_mult = _upgrade_system.get_damage_multiplier()
    return base * (1.0 + item_mult) * (1.0 + upgrade_mult)
```

## DamageSystem Pipeline

```gdscript
func deal_damage(target: Enemy, base_damage: float, source: String) -> DamageResult:
    var bonus_mult = _item_effect_system.get_conditional_bonus(target)
    var crit_result = _item_effect_system.try_crit()
    if _item_effect_system.try_execute(target):
        result.final_damage = target.health
    else:
        result.final_damage = base_damage * (1.0 + bonus_mult) * crit_mult
    target.health -= result.final_damage
    _damage_numbers.spawn(target.global_position, result)
    _material_flash.flash(target)
    _item_effect_system.try_apply_status(target, _status_effects)
    SignalBus.dealt_damage.emit(result.final_damage, source)
```

## Player Damage Pipeline

```gdscript
func _take_damage(amount: float) -> void:
    if randf() < _get_dodge_chance(): _show_miss(); return
    if randf() < item_effect_system.get_emergency_heal_chance():
        if health_percent() < 0.3: _heal(...); return
    var reduced = amount * (1.0 - _get_damage_resistance())
    reduced = max(reduced - _get_flat_reduction(), 0.0)
    if item_effect_system.current_shield > 0:
        var absorbed = min(reduced, item_effect_system.current_shield)
        item_effect_system.current_shield -= absorbed
        reduced -= absorbed
    health -= reduced
```

## Spawn Patterns

```gdscript
class_name CircleAroundPattern
extends SpawnPattern

func get_spawn_positions(player_pos: Vector2, count: int) -> Array[Vector2]:
    var positions: Array[Vector2] = []
    for i in count:
        var angle = TAU * i / count + randf() * 0.2
        positions.append(player_pos + Vector2.from_angle(angle) * radius)
    return positions
```
