class_name DialogButton extends Control

@export var text: RichTextLabel
var _is_right_answer: bool = false

func setup_btn(answerText : String, is_right_answer : bool):
	text.text = answerText
	_is_right_answer = is_right_answer
	
func on_btn_clicked():
	if _is_right_answer:
		print("Click on right answer")
	else:
		print("Click on wrong answer")
		
	# event on right / wrong answer
	
	var dialog_manager = get_dialog_manager()
	if dialog_manager:
		dialog_manager._on_answer_pressed(_is_right_answer)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")
	
func get_dialog_manager(): # todo : mettre dans uen class utils
	var managers = get_tree().get_nodes_in_group("dialog_manager")
	if managers.size() > 0:
		return managers[0]
	return null
