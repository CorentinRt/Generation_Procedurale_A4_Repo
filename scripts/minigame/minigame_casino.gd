class_name Minigame_Casino extends Room_Minigame

var casino_machine : Casino_Machine

func _setup_minigame() -> void:
	super()
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("item_minigame"):
			continue
		if i is Casino_Machine:
			casino_machine = i
			
	casino_machine.on_casino_send_result.connect(receive_casino_result_callback)
	
	
func receive_casino_result_callback(result : Casino_Machine.CASINO_RESULT) -> void:
	_score = 0	# set score to 0 cause it's the machine which gives the points and not the room here
	_set_state(MINIGAME_STATE.COMPLETED)
