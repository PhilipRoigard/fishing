---
name: godot-performance-patterns
description: Performance optimization patterns for Godot including object pooling, spatial grid hashing, update bucketing, viewport culling, damage number pools, typed array best practices, and preload vs load. Use when optimizing game performance or implementing high-frequency systems.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **Object Pooling**: Pre-allocate and reuse (20 initial, 100 max per type), reset_state() on reuse
- **Spatial Grid**: Cell-based hashing for O(1) neighbor queries + query cache per frame
- **Update Bucketing**: Spread N entities across 10 frames, compensate with `delta * BUCKET_COUNT`
- **Viewport Culling**: Despawn enemies beyond camera range, batch 200 checks/frame
- **Damage Number Pool**: 100 instances, MAX_PER_FRAME = 10 rate limit
- **Sprite Throttling**: Update direction every 0.1s, not every frame
- **Typed Arrays**: Use `.assign()` after `.filter()/.map()` to preserve typing
- **Prefer typed arrays over Dictionaries** for tracking objects with associated data
- **Preload** for compile-time known resources, **load** only for runtime paths
- `_process` for visuals, `_physics_process` for physics
