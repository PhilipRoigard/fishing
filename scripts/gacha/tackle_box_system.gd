class_name TackleBoxSystem
extends RefCounted

var pity_tracker: TackleBoxPityTracker
var daily_tracker: TackleBoxDailyTracker


func _init() -> void:
	pity_tracker = TackleBoxPityTracker.new()
	daily_tracker = TackleBoxDailyTracker.new()


func can_pull(pack: TackleBoxPackDefinition) -> bool:
	if not CurrencyManager.can_afford_gems(pack.gem_cost):
		return false
	if not daily_tracker.can_pull(pack.id, pack.daily_limit):
		return false
	return true


func pull(pack: TackleBoxPackDefinition) -> Array[TackleBoxPullResult]:
	var results: Array[TackleBoxPullResult] = []

	if not can_pull(pack):
		return results

	var request: CurrencyExchangeRequest = CurrencyExchangeRequestBuilder.create() \
		.spend_gems(pack.gem_cost) \
		.reason("tackle_box_pull_%s" % pack.id) \
		.build()

	var exchange_success: bool = CurrencyExchange.execute(request)
	if not exchange_success:
		return results

	SignalBus.tackle_box_pull_started.emit(pack.id)

	for i: int in range(pack.items_per_pull):
		var result: TackleBoxPullResult = _roll_single_item(pack)
		results.append(result)

	daily_tracker.record_pull(pack.id)

	SignalBus.tackle_box_pull_completed.emit(results)

	return results


func _roll_single_item(pack: TackleBoxPackDefinition) -> TackleBoxPullResult:
	var result: TackleBoxPullResult = TackleBoxPullResult.new()

	var is_pity: bool = pity_tracker.check_pity(pack.id, pack.pity_threshold)
	var quality: Enums.ItemQuality = _roll_quality(pack, is_pity)

	result.item_id = _pick_random_item(pack)
	result.quality = quality
	result.is_pity = is_pity and quality >= pack.pity_minimum_quality

	pity_tracker.record_pull(pack.id)
	if quality >= Enums.ItemQuality.RARE:
		pity_tracker.reset(pack.id)

	SignalBus.equipment_item_acquired.emit("", result.item_id, result.quality)

	return result


func _roll_quality(pack: TackleBoxPackDefinition, force_pity: bool) -> Enums.ItemQuality:
	if force_pity:
		return _roll_pity_quality(pack)

	var weights: Dictionary = pack.get_quality_weights()
	var total: float = pack.get_total_weight()
	var roll: float = randf() * total
	var cumulative: float = 0.0

	for quality_value: int in [
		Enums.ItemQuality.COMMON,
		Enums.ItemQuality.UNCOMMON,
		Enums.ItemQuality.RARE,
		Enums.ItemQuality.EPIC,
		Enums.ItemQuality.LEGENDARY,
	]:
		var quality: Enums.ItemQuality = quality_value as Enums.ItemQuality
		cumulative += weights[quality]
		if roll <= cumulative:
			return quality

	return Enums.ItemQuality.COMMON


func _roll_pity_quality(pack: TackleBoxPackDefinition) -> Enums.ItemQuality:
	var weights: Dictionary = pack.get_quality_weights()
	var pity_min: int = pack.pity_minimum_quality

	var filtered_total: float = 0.0
	for quality_value: int in [
		Enums.ItemQuality.RARE,
		Enums.ItemQuality.EPIC,
		Enums.ItemQuality.LEGENDARY,
	]:
		if quality_value >= pity_min:
			filtered_total += weights[quality_value as Enums.ItemQuality]

	var roll: float = randf() * filtered_total
	var cumulative: float = 0.0

	for quality_value: int in [
		Enums.ItemQuality.RARE,
		Enums.ItemQuality.EPIC,
		Enums.ItemQuality.LEGENDARY,
	]:
		if quality_value >= pity_min:
			var quality: Enums.ItemQuality = quality_value as Enums.ItemQuality
			cumulative += weights[quality]
			if roll <= cumulative:
				return quality

	return pack.pity_minimum_quality


func _pick_random_item(pack: TackleBoxPackDefinition) -> String:
	if pack.item_pool_ids.is_empty():
		return ""
	var index: int = randi_range(0, pack.item_pool_ids.size() - 1)
	return pack.item_pool_ids[index]
