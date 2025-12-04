class_name Question extends Resource

enum RightAnswerType {
	NOT_SAVED,
	PLAYER_NAME,
	PLAYER_AGE
}

@export var title: String = ""
@export var right_answer_type: RightAnswerType
@export var static_answer_for_type_not_saved: String = ""
@export var wrong_answers_text: Array[String] 
