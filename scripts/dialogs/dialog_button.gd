class_name DialogButton extends Button

var is_right_answer: bool = false
var is_end_type: EndManager.EndType = EndManager.EndType.NONE 

func setup_btn(answerText : String, right_answer : bool, end_type : EndManager.EndType = EndManager.EndType.NONE):
	text = answerText
	is_right_answer = right_answer
	is_end_type = end_type
	
func on_btn_clicked():
	var dialog_manager = UtilsManager.get_dialog_manager()
	if dialog_manager:
		if is_end_type != EndManager.EndType.NONE:
			# End answer
			EndManager.on_click_on_end_type(is_end_type)
		else:
			# Question answer
			if is_right_answer:
				print("right answer")
			else:
				print("wrong answer")
				
			dialog_manager._on_answer_pressed(is_right_answer)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")
