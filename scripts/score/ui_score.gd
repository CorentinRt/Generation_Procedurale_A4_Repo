extends Control

@onready var score_label : Label = $Label

@export var suffix : String
@export var prefix : String

@export var _bobbing_duration : float = 0.5
var _tween_position_bobbing : Tween
var _tween_scale_bobbing : Tween

func _ready() -> void:
	ScoreManager._on_change_score.connect(_set_score_text)
	_set_score_text(0)
	
func _bobbing_position() -> void:
	if _tween_position_bobbing != null:
		_tween_position_bobbing.kill()
	_tween_position_bobbing = create_tween()
	_tween_position_bobbing.set_ease(Tween.EASE_IN_OUT)
	_tween_position_bobbing.tween_property(score_label, "position", Vector2(20, 120), _bobbing_duration).as_relative()
	_tween_position_bobbing.tween_property(score_label, "position", -Vector2(20, 120), _bobbing_duration).as_relative()	

func _bobbing_scale() -> void:
	if _tween_scale_bobbing != null:
		_tween_scale_bobbing.kill()
	_tween_scale_bobbing = create_tween()
	_tween_scale_bobbing.set_ease(Tween.EASE_IN_OUT)
	_tween_scale_bobbing.tween_property(score_label, "scale", Vector2(2, 2), _bobbing_duration)
	_tween_scale_bobbing.tween_property(score_label, "scale", Vector2(1, 1), _bobbing_duration)	

func _set_score_text(score: int) -> void:
	score_label.text = prefix + str(score) + suffix
	_bobbing_position()
	_bobbing_scale()
