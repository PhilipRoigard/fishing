class_name IAPCatalogue
extends Resource

@export var products: Array[Product] = []


func get_product_by_id(product_id: String) -> Product:
	for p: Product in products:
		if p.id == product_id:
			return p
	return null


func get_products_by_category(category: String) -> Array[Product]:
	var result: Array[Product] = []
	result.assign(products.filter(func(p: Product) -> bool: return p.category == category))
	return result
