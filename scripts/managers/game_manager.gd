extends Node

signal on_open_final_chest()

signal on_kill_enemy()

func _ready() -> void:
	_init_game()

func _init_game() -> void:
	ScoreManager._reset_score()
	
func _reload_game_scene(delay:float) -> void:
	await get_tree().create_timer(delay).timeout
	print("reload")
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	_init_game()
	
	
func _notify_open_final_chest() -> void:
	on_open_final_chest.emit()
	
func _notify_kill_enemy() -> void:
	print("kill enemy")
	on_kill_enemy.emit()
