extends Area2D

var player_is_near : bool = false


func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if !player_is_near && body is Player:
		player_is_near = true


func _on_body_exited(body: Node2D) -> void:
	if player_is_near && body is Player:
		player_is_near = false

func _process(delta: float) -> void:
	if player_is_near && Input.is_action_just_pressed("Interact"):
		_interact()
		
func _interact() -> void:
	_open_casino_display()
	
func _open_casino_display() -> void:
	pass
