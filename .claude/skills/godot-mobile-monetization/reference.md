## IAP Product

```gdscript
class_name Product
extends Resource

@export var id: String
@export var coin_amount: int = 0
@export var essence_amount: int = 0
@export var grants_premium: bool = false
@export var is_consumable: bool = true

func complete_purchase() -> void:
    if grants_premium: PremiumManager.set_has_premium(true)
    CurrencyExchange.submit(CurrencyExchangeRequestBuilder.new()
        .gain_gems(coin_amount).gain_essence(essence_amount)
        .reason("iap_" + id).build())
```

## PurchaseManager (Platform Abstraction)

```gdscript
func _ready() -> void:
    _iap_handler = MockIAPPlugin.new() if not _has_native_iap() else _create_native_handler()

func purchase(product_id: String) -> bool:
    _iap_handler.purchase(product_id)
    return await purchase_finalized
```

## Virtual Joystick

```gdscript
class_name VirtualJoystick
extends Control

signal joystick_input(input_vector: Vector2)
signal auto_shoot_started
signal auto_shoot_stopped

const DEAD_ZONE: float = 0.15
const AUTO_SHOOT_THRESHOLD: float = 0.7

func _input(event: InputEvent) -> void:
    if event is InputEventScreenDrag and event.index == _touch_index:
        var normalized = ((event.position - _center).limit_length(MAX_DISTANCE)) / MAX_DISTANCE
        if normalized.length() < DEAD_ZONE: normalized = Vector2.ZERO
        joystick_input.emit(normalized)
```

## Safe Zone Manager

```gdscript
func _calculate_safe_zones() -> void:
    var safe_area = DisplayServer.get_display_safe_area()
    var screen_size = DisplayServer.screen_get_size()
    _margins.top = safe_area.position.y
    _margins.bottom = screen_size.y - (safe_area.position.y + safe_area.size.y)
    safe_zones_updated.emit(_margins.top, _margins.bottom, _margins.left, _margins.right)
```
