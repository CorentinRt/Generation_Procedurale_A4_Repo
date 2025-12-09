class_name Room_Zone_Detector extends Node2D

signal _on_player_enters(body_position : Vector2)

signal _on_player_exits(body_position : Vector2)

var _is_player_in : bool

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	_is_player_in = true
	_on_player_enters.emit(body.global_position)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
		
	_is_player_in = false
	_on_player_exits.emit(body.global_position)
