extends Control

@export var score_txt: RichTextLabel

@export var btn_play : Button

func _ready() -> void:
	score_txt.text = "Score : " + str(ScoreManager._score)
	btn_play.pressed.connect(_on_button_play_pressed)

func _on_button_play_pressed() -> void:
	btn_play.pressed.disconnect(_on_button_play_pressed)
	GameManager._reload_game_scene(0)
