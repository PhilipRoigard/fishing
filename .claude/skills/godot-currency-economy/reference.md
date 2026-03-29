## CurrencyManager (Persistence)

```gdscript
extends Node  # autoload - NO class_name

signal currency_changed(essence: int, gems: int)
signal essence_changed(amount: int)
signal gems_changed(amount: int)

var _essence: int = 0
var _gems: int = 0

func add_essence(amount: int) -> void:
    if amount <= 0: return
    _essence += amount
    _save_currency()
    essence_changed.emit(_essence)
    currency_changed.emit(_essence, _gems)

func spend_essence(amount: int) -> bool:
    if not can_afford_essence(amount): return false
    _essence -= amount
    _save_currency()
    essence_changed.emit(_essence)
    currency_changed.emit(_essence, _gems)
    return true
```

## CurrencyExchangeRequest (Builder)

```gdscript
class_name CurrencyExchangeRequest
extends RefCounted

var essence_delta: int = 0
var gems_delta: int = 0
var essence_source_pos: Vector2
var gems_source_pos: Vector2
var animate: bool = true
var reason: String = ""

static func gain_essence(amount: int, pos: Vector2 = Vector2.ZERO, reason: String = "") -> CurrencyExchangeRequest:
    var req = CurrencyExchangeRequest.new()
    req.essence_delta = amount
    req.essence_source_pos = pos
    req.reason = reason
    return req
```

## Currency Animation Queue

```gdscript
var _animation_queue: Array[CurrencyExchangeRequest] = []
var _is_animating: bool = false

func _on_exchange_processed(request: CurrencyExchangeRequest) -> void:
    _animation_queue.append(request)
    if not _is_animating:
        _process_animation_queue()

func _process_animation_queue() -> void:
    _is_animating = true
    while _animation_queue.size() > 0:
        await _animate_exchange(_animation_queue.pop_front())
    _is_animating = false
```

## Reward Calculation

```gdscript
class_name RewardConfig
extends Resource

@export var essence_on_victory: int = 30
@export var essence_per_level_squared: float = 10.0
@export var defeat_penalty_multiplier: float = 0.5

func calculate_rewards(level: int, time_remaining: float, is_victory: bool) -> Dictionary:
    var essence = essence_on_victory + (level * level * essence_per_level_squared)
    if not is_victory: essence *= defeat_penalty_multiplier
    return {"essence": int(essence), "gems": int(gems)}
```
