extends Node


func execute(request: Variant) -> bool:
	if not _validate(request):
		return false

	if request.coins_spent > 0:
		CurrencyManager.spend_coins(request.coins_spent)
	if request.gems_spent > 0:
		CurrencyManager.spend_gems(request.gems_spent)
	if request.coins_gained > 0:
		CurrencyManager.add_coins(request.coins_gained)
	if request.gems_gained > 0:
		CurrencyManager.add_gems(request.gems_gained)

	if request.animate and request.source_position != Vector2.ZERO:
		SignalBus.currency_animation_requested.emit(
			request.coins_gained + request.gems_gained,
			"coins" if request.coins_gained > 0 else "gems",
			request.source_position
		)

	return true


func _validate(request: Variant) -> bool:
	if request.coins_spent > 0 and not CurrencyManager.can_afford_coins(request.coins_spent):
		return false
	if request.gems_spent > 0 and not CurrencyManager.can_afford_gems(request.gems_spent):
		return false
	return true
