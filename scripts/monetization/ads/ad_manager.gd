extends Node

signal rewarded_ad_completed(placement: String)
signal rewarded_ad_failed(placement: String)

var is_ad_available: bool = true


func show_rewarded_ad(placement: String) -> void:
	_mock_rewarded_ad(placement)


func _mock_rewarded_ad(placement: String) -> void:
	await get_tree().create_timer(0.5).timeout
	rewarded_ad_completed.emit(placement)
