---
name: godot-currency-economy
description: Two-tier currency system with exchange coordinator, request builder pattern, animation queue, and reward calculation for Godot games. Use when implementing game economies, currency systems, IAP flows, or reward calculations.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Architecture

- **CurrencyManager** (autoload): Persistence layer for soft/hard currency
- **CurrencyExchange** (autoload): Single entry point for ALL currency changes, validates + persists + emits for UI
- **CurrencyExchangeRequest**: Data class with factory methods and builder pattern
- **CurrencyBar**: Queue-based animation (flying icons, number rolling, bounces)

## Key Patterns

- Request-based transactions with builder: `.gain_essence(100).spend_gems(50).reason("iap").build()`
- IAP animation source injection: `set_animation_source()` before async purchase
- Reward formula: base + level-squared scaling + time bonus, with defeat penalty multiplier
