class_name Skew_Bump_TEffect extends Node

@export var duration : float = 0.3
@export var sprite : Sprite2D

var skew_tween : Tween


func _play_effect() -> void:
	if skew_tween != null:
		skew_tween.kill()
	skew_tween = create_tween()
	skew_tween.tween_property(sprite, "skew", 50, duration)
	skew_tween.tween_property(sprite, "skew", 0, duration)
	
