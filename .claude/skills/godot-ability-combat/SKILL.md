---
name: godot-ability-combat
description: Ability system, damage pipeline, item effects, upgrade choices, and wave-based spawning for Godot games. Use when implementing combat systems, abilities, damage calculation, item effects, or spawn systems.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **AbilitySystem**: Auto-triggering abilities with internal cooldown tracking
- **BaseAbility**: Override `trigger()`, stat getters apply all multipliers (items + upgrades)
- **DamageSystem**: Central hub: conditional bonuses -> crit check -> execute check -> apply -> visual feedback -> status effects
- **ItemEffectSystem**: Stacking items with conditional bonuses (vs low HP, elite, boss, slowed)
- **Player Damage Pipeline**: dodge -> emergency heal -> % resistance -> flat reduction -> shield -> HP
- **UpgradeSystem**: Weighted random choice generation with evolution priority
- **SpawnSystem**: Wave-based with quota maintenance, spawn patterns (circle, directional arc, cluster)
