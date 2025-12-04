extends Node

signal _on_change_score(new_score : int)
signal _on_request_show(is_shown : bool)

var _score :int = 0
var _total_lost_score = 0

func _reset_score() -> void:
	_score = 0
	
func _change_score(value:int) -> void:
	_score = value
	_on_change_score.emit(_score)

func _add_score(value:int) -> void:
	_change_score(_score + value)
	
func _remove_score(value:int) -> void:
	_change_score(_score - value)
	_total_lost_score += value

func _show(is_shown : bool):
	print("show score : ", is_shown)
	_on_request_show.emit(is_shown)
