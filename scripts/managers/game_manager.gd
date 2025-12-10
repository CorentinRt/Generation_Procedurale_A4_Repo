extends Node

signal on_open_final_chest()

signal on_kill_enemy()

signal on_player_has_lost()
signal on_player_loose_dialog_ended()

var has_lost : bool = false

func _ready() -> void:
	_init_game()

func _init_game() -> void:
	ScoreManager._reset_score()
	has_lost = false
	await get_tree().create_timer(0.1).timeout
	NpcSpawnManager.init_npcs()
	ItemSpawnManager.init_quest_items()
	_player_init_sound()
	
func _player_init_sound():
	AudioManager.Instance.play_sound("main_theme")
	AudioManager.Instance.play_sound("reading")
	AudioManager.Instance.set_volume_with_name("reading", -80)
	
func _load_menu_scene() -> void:
	print("load menu")
	get_tree().change_scene_to_file("res://scenes/ended_game.tscn")
	
func _reload_game_scene(delay:float) -> void:
	await get_tree().create_timer(delay).timeout
	print("reload")
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	_init_game()
	
func _notify_open_final_chest() -> void:
	on_open_final_chest.emit()
	
func _loose_game() -> void:
	if has_lost:
		return
	has_lost = true
	print("has lost")
	on_player_has_lost.emit()
	
func _notify_player_loose_dialog_ended() -> void:
	print("player loose dialog ended")
	on_player_loose_dialog_ended.emit()
	AudioManager.Instance.play_sound("end_pirate_attack")
	await get_tree().create_timer(4).timeout
	_load_menu_scene()
	
	
func _notify_kill_enemy() -> void:
	print("kill enemy")
	on_kill_enemy.emit()
