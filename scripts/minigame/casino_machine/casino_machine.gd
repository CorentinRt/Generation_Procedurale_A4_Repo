class_name Casino_Machine extends Area2D

enum CASINO_RESULT
{
	FAILED = 0,
	LITTLE_WIN = 1,
	BINGO = 2
}

@export var interaction_sprite : Sprite2D

@export var _scores_datas : Scores_Datas

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
	if !can_interact:
		return
	if _check_and_spend_coin():
		_open_casino_display()
		can_interact = false
		interaction_count += 1
	
func _check_and_spend_coin() -> bool:
	if interaction_count == 0:	# first try is free
		return true
		
	return true
	
func _open_casino_display() -> void:
	UI_Casino.Instance._show_casino_ui(self)
	Player.Instance.is_in_casino = true
	
func _close_casino_display() -> void:
	UI_Casino.Instance._hide_casino_ui()
	Player.Instance.is_in_casino = false
		
func _trigger_casino_result(result : CASINO_RESULT) -> void:
	var score : int = 0
	
	match (result):
		Casino_Machine.CASINO_RESULT.FAILED:
			pass
		Casino_Machine.CASINO_RESULT.LITTLE_WIN:
			score = _scores_datas._minigame_completed_casino_little
		Casino_Machine.CASINO_RESULT.BINGO:
			score = _scores_datas._minigame_completed_casino_jackpot
			
	ScoreManager._add_score(score)
	
	on_casino_send_result.emit(result)
	_close_casino_display()
	can_interact = true
	
