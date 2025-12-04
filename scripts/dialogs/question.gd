class_name Question extends Resource

enum RightAnswerType {
	PLAYER_NAME,
	PLAYER_AGE
}

@export var title: String = ""
@export var right_answer_type: RightAnswerType
@export var wrong_answers_text: Array[String]
