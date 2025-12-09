extends Control

@export var score_txt: RichTextLabel

func _ready() -> void:
	score_txt.text = "Score : " + str(ScoreManager._score)
