class_name Sword extends Attack

@export var animation_player_sword : AnimationPlayer

func _ready() -> void:
	_play_attack_anim()
	
func _play_attack_anim() -> void:
	animation_player_sword.play("attack")
