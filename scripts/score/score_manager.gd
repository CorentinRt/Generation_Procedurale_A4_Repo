extends Node

signal _on_change_score(new_score : int)
signal _on_add_score(added_score : int)
signal _on_request_show(is_shown : bool)

var _score :int = 0
var _total_lost_score = 0
var _last_lost_score = 0

func _reset_score() -> void:
	_change_score(25000)
	
func _change_score(value:int) -> void:
	_score = value
	_on_change_score.emit(_score)
	_check_lose()
	print("change score " + str(_score))

func _add_score(value:int) -> void:
	if value < 0:
		_remove_score(value * -1)
		return
	
	_on_add_score.emit(value)
	_change_score(_score + value)
	
	if AudioManager.Instance != null:
		AudioManager.Instance.play_sound("gold")
	
func _remove_score(value:int) -> void:
	_change_score(_score - value)
	_total_lost_score += value
	
	# Taunt every 200k lost
	_last_lost_score += value
	if _last_lost_score >= 50000:
		_last_lost_score = 0
		UtilsManager.get_dialog_manager().show_taunt_dialog()
	

func _show(is_shown : bool):
	print("show score : ", is_shown)
	_on_request_show.emit(is_shown)
	
func _check_lose() -> void:
	if _score <= 0:
		GameManager._loose_game()
	
