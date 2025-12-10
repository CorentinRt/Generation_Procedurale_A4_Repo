extends Control

@export var score_txt: RichTextLabel

@export var btn_play : Button
@export var btn_quit : Button

func _ready() -> void:
	score_txt.text = "Score : " + str(ScoreManager._score)
	btn_play.pressed.connect(_on_button_play_pressed)
	btn_quit.pressed.connect(_on_button_quit_pressed)
	call_deferred("_play_sound_menu")

func _play_sound_menu() -> void:
	GameManager._player_init_sound()

func _on_button_play_pressed() -> void:
	btn_play.pressed.disconnect(_on_button_play_pressed)
	GameManager._reload_game_scene(0)
	
func _on_button_quit_pressed() -> void:
	btn_quit.pressed.disconnect(_on_button_quit_pressed)
	get_tree().quit()
