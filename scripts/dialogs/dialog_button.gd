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
