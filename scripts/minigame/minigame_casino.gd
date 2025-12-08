class_name Minigame_Casino extends Room_Minigame

var casino_machine : Casino_Machine

func _setup_minigame() -> void:
	super()
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("item_minigame"):
			continue
			
	casino_machine.on_casino_send_result.connect(receive_casino_result_callback)
	
	
func receive_casino_result_callback(result : Casino_Machine.CASINO_RESULT) -> void:
	match result:
		Casino_Machine.CASINO_RESULT.FAILED:
			_score = 0
		Casino_Machine.CASINO_RESULT.LITTLE_WIN:
			_score = _scores_datas._minigame_completed_casino_little
		Casino_Machine.CASINO_RESULT.BINGO:
			_score = _scores_datas._minigame_completed_casino_jackpot

	_set_state(MINIGAME_STATE.COMPLETED)
