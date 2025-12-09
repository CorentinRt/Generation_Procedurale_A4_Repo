class_name Minigame_Question extends Room_Minigame

var npc : NPC

func _setup_minigame() -> void:
	super()
	for i in get_parent().get_children():
		if !i.is_in_group("NPC"):
			continue
		if i is NPC:
			npc = i
			
	npc.on_question_answered.connect(receive_question_answered_callback)
	
func receive_question_answered_callback(right_answer : bool) -> void:
	if right_answer:
		_score = _scores_datas._minigame_completed_question_right_answer
	else:
		_score = _scores_datas._minigame_completed_question_wrong_answer
	
	_set_state(MINIGAME_STATE.COMPLETED)
