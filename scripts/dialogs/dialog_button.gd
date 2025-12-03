class_name DialogButton extends Control

@export var text: RichTextLabel
var current_answer: Answer

func setup_btn(answer : Answer):
	current_answer = answer
	text.text = current_answer.text
	
func on_btn_clicked():
	print("button clicked")
