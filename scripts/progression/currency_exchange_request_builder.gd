class_name CurrencyExchangeRequestBuilder
extends RefCounted

var _request: CurrencyExchangeRequest


static func create() -> CurrencyExchangeRequestBuilder:
	var builder: CurrencyExchangeRequestBuilder = CurrencyExchangeRequestBuilder.new()
	builder._request = CurrencyExchangeRequest.new()
	return builder


func spend_coins(amount: int) -> CurrencyExchangeRequestBuilder:
	_request.coins_spent = amount
	return self


func spend_gems(amount: int) -> CurrencyExchangeRequestBuilder:
	_request.gems_spent = amount
	return self


func gain_coins(amount: int) -> CurrencyExchangeRequestBuilder:
	_request.coins_gained = amount
	return self


func gain_gems(amount: int) -> CurrencyExchangeRequestBuilder:
	_request.gems_gained = amount
	return self


func reason(r: String) -> CurrencyExchangeRequestBuilder:
	_request.reason = r
	return self


func set_animate(a: bool) -> CurrencyExchangeRequestBuilder:
	_request.animate = a
	return self


func set_source_position(pos: Vector2) -> CurrencyExchangeRequestBuilder:
	_request.source_position = pos
	return self


func build() -> CurrencyExchangeRequest:
	return _request
