extends Node

func _init_game() -> void:
	ScoreManager._reset_score()
	
func _reload_game_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	
	
