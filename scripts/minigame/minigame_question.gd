class_name Minigame_Final_Room extends Room_Minigame


func _setup_minigame() -> void:
	super()
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("item_minigame"):
			continue
			
	
func receive_question_answered_callback() -> void:
	_set_state(MINIGAME_STATE.COMPLETED)
