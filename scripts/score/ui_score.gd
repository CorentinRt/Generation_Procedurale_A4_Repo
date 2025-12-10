extends Control

@onready var score_label : Label = $Label

@export var suffix : String
@export var prefix : String
@export var animation_player_score : AnimationPlayer

func _ready() -> void:
	ScoreManager._on_change_score.connect(_set_score_text)
	ScoreManager._on_request_show.connect(_show)
	_set_score_text(ScoreManager._score)

func _set_score_text(score: int) -> void:
	score_label.text = prefix + str(score) + suffix
	animation_player_score.play("bobbing")

func _show(is_shown : bool):
	if is_shown:
		score_label.show()
	else:
		score_label.hide()
