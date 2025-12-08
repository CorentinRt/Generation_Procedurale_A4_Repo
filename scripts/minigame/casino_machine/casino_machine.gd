class_name Casino_Machine extends Area2D

enum CASINO_RESULT
{
	FAILED = 0,
	LITTLE_WIN = 1,
	BINGO = 2
}

@export var interaction_sprite : Sprite2D

var can_interact : bool = true

var player_is_near : bool = false

var interaction_count : int = 0

signal on_casino_send_result(result : CASINO_RESULT)

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
	can_interact = false
	interaction_count += 1
	
func _open_casino_display() -> void:
	UI_Casino.Instance._show_casino_ui()
	
func _close_casino_display() -> void:
	UI_Casino.Instance._hide_casino_ui()
	
func _trigger_casino_result(result : CASINO_RESULT) -> void:
	on_casino_send_result.emit(result)
	_close_casino_display()
	can_interact = true
	
