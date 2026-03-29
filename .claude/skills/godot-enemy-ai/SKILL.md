---
name: godot-enemy-ai
description: Enemy AI architecture with state machines, pluggable behaviors, spatial grids, object pooling, and boss systems for Godot. Use when implementing enemy systems, AI behaviors, spatial optimization, or boss encounters.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **State Machine**: idle/attack/telegraph/recovery/dying states via EnemyStateMachine
- **Pluggable Behaviors**: Strategy pattern for movement (DefaultBehavior, OrbitBehavior, StationaryBehavior)
- **EnemyManager Singleton**: Centralized tracking with update bucketing (10 buckets across 10 frames)
- **Spatial Grid**: Cell-based hashing for O(1) neighbor queries
- **Object Pooling**: Per-config enemy pools (20 initial, 100 max per type)
- **Boss System**: Extended Enemy with attack queues (cyclic or weighted random)
- **Despawn/Recycle**: Viewport-based culling with batch processing (200 checks/frame)
