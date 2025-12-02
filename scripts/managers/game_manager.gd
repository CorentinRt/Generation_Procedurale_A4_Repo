extends Node

func _ready() -> void:
	_init_game()

func _init_game() -> void:
	ScoreManager._reset_score()
	
func _reload_game_scene(delay:float) -> void:
	await get_tree().create_timer(delay).timeout
	print("reload")
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	_init_game()
	
