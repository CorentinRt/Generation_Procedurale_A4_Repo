class_name Room_Zone_Detector extends Node2D

signal _on_player_enters()

signal _on_player_exits()

var _is_player_in : bool

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	_is_player_in = true
	_on_player_enters.emit()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
		
	_is_player_in = false
	_on_player_exits.emit()
