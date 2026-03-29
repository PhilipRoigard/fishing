---
name: godot-persistence-progression
description: Save/load patterns, singleton Resources, player preferences, stats tracking, unlock requirements, XP curves, and delve session management for Godot. Use when implementing persistence, progression, or save systems.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **FileAccess**: Simple key-value data (currency, premium status, ad counts)
- **Resource System**: Structured data with singleton lazy-loading (prefs, item progression, stats)
- **PlayerPrefs**: Enum-keyed preferences with static get/set
- **PlayerStatsData**: Cumulative totals + personal bests with min/max tracking
- **UnlockRequirement**: Config-driven unlock conditions (kills, level, time, prerequisite)
- **ExperienceConfig**: Power-curve XP thresholds
- **DelveManager**: Per-run session state with difficulty scaling multipliers and reward calculation
- **AdRewardTracker**: Daily limits with midnight reset
