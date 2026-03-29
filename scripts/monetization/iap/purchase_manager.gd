extends Node

var is_purchasing: bool = false


func _ready() -> void:
	pass


func purchase(product_id: String) -> void:
	if is_purchasing:
		return

	var catalogue: Variant = null
	if GameResources.config:
		catalogue = GameResources.config.iap_catalogue
	if not catalogue:
		SignalBus.purchase_failed.emit(product_id, "No catalogue loaded")
		return

	var product: Variant = catalogue.get_product_by_id(product_id)
	if not product:
		SignalBus.purchase_failed.emit(product_id, "Product not found")
		return

	is_purchasing = true
	SignalBus.purchase_started.emit(product_id)

	_mock_purchase(product)


func _mock_purchase(product: Variant) -> void:
	await get_tree().create_timer(1.0).timeout

	if product.coin_amount > 0:
		CurrencyManager.add_coins(product.coin_amount)
	if product.gem_amount > 0:
		CurrencyManager.add_gems(product.gem_amount)

	is_purchasing = false
	SignalBus.purchase_completed.emit(product.id)
