class_name Casino_Machine extends Area2D

@export var interaction_sprite : Sprite2D

var can_interact : bool = true

var player_is_near : bool = false


func _ready() -> void:
	interaction_sprite.hide()


func _on_body_entered(body: Node2D) -> void:
	if !player_is_near && body is Player:
		player_is_near = true
		if can_interact:
			interaction_sprite.show()


func _on_body_exited(body: Node2D) -> void:
	if player_is_near && body is Player:
		player_is_near = false
		interaction_sprite.hide()

func _process(delta: float) -> void:
	if player_is_near && Input.is_action_just_pressed("Interact"):
		_interact()
		
func _interact() -> void:
	_open_casino_display()
	
func _open_casino_display() -> void:
	pass
