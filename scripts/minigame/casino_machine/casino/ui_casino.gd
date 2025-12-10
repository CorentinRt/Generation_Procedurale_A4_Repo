class_name UI_Casino extends Control

static var Instance : UI_Casino

var associated_machine : Casino_Machine

@export var animation_player : AnimationPlayer
@export var reels : Array[Casino_Reel]

func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
	_hide_casino_ui()
		
func _show_casino_ui(machine : Casino_Machine) -> void:
	associated_machine = machine
	if associated_machine == null:
		return
	$Container.visible = true
	_start_spin()
	
func _hide_casino_ui() -> void:
	associated_machine = null
	$Container.visible = false
	
func _start_spin() -> void:
	if associated_machine == null:
		return
		
	var result : Casino_Machine.CASINO_RESULT = _select_outcome()
	var result_symbols : Array[int] = _select_symbols_from_outcome(result, 3)
	reels[0].spin_to(result_symbols[0])
	await get_tree().create_timer(0.5).timeout
	reels[1].spin_to(result_symbols[1])
	await get_tree().create_timer(0.5).timeout
	reels[2].spin_to(result_symbols[2])
	await get_tree().create_timer(2.5).timeout
	
	match result:
		Casino_Machine.CASINO_RESULT.BINGO:
			animation_player.play("bingo")
		Casino_Machine.CASINO_RESULT.LITTLE_WIN:
			animation_player.play("little_win")
		Casino_Machine.CASINO_RESULT.FAILED:
			animation_player.play("failed")
			
	await get_tree().create_timer(2).timeout
	associated_machine._trigger_casino_result(result)
	
func _select_outcome() -> Casino_Machine.CASINO_RESULT:
	var result_proba : int = randi() % 10	# get result from 0 to 10 (exclude)
	
	if result_proba == 0:
		return Casino_Machine.CASINO_RESULT.BINGO
		
	if result_proba < 3:
		return Casino_Machine.CASINO_RESULT.LITTLE_WIN
		
	return Casino_Machine.CASINO_RESULT.FAILED
	
func _select_symbols_from_outcome(outcome : Casino_Machine.CASINO_RESULT, symbols_count : int) -> Array[int]:
	if outcome == Casino_Machine.CASINO_RESULT.BINGO:
		var index = randi() % symbols_count
		return [index, index, index]
		
	elif outcome == Casino_Machine.CASINO_RESULT.LITTLE_WIN:
		var index1 = randi() % symbols_count
		var index2 = randi() % symbols_count
		
		while index1 == index2:
			index2 = randi() % symbols_count
			
		var not_duplicated_index : int = randi() % 3
		var result : Array[int] = [index2, index2, index2]
		result[not_duplicated_index] = index1
		return result
		
	else:
		var result : Array[int] = []
		while result.size() < 3:
			var index = randi() % symbols_count
			if not index in result:
				result.append(index)
		return result
		
