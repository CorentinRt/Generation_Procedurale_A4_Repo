class_name EndInteract extends Node2D

@export var interact_icon : Sprite2D

func _process(_delta: float) -> void:
	var is_player_near: bool = _check_is_player_near()
	show_interact_icon(is_player_near)
	if  is_player_near && Input.is_action_just_pressed("Interact"):
		_interact()
		
func _interact() -> void:
	UtilsManager.get_dialog_manager().show_end_dialog()

func _check_is_player_near() -> bool:
	var player_pos = Player.Instance.global_position
	var interact_radius = Player.Instance.interact_radius
	return global_position.distance_to(player_pos) <= interact_radius
	
func show_interact_icon(is_player_near: bool):
	if is_player_near:
		interact_icon.show()
	else:
		interact_icon.hide()
