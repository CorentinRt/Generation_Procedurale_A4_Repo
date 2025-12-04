class_name DialogButton extends Control

@export var text: RichTextLabel
var _is_right_answer: bool = false

func setup_btn(answerText : String, is_right_answer : bool):
	text.text = answerText
	_is_right_answer = is_right_answer
	
func on_btn_clicked():
	var dialog_manager = UtilsManager.get_dialog_manager()
	if dialog_manager:
		if _is_right_answer:
			print("Click on right answer")
			ScoreManager._add_score(dialog_manager.add_score_right_answer)
		else:
			print("Click on wrong answer")
			ScoreManager._remove_score(dialog_manager.remove_score_wrong_answer)
			
		dialog_manager._on_answer_pressed(_is_right_answer)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")
