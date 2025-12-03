class_name Question extends Resource

# attention au resource name -> utilisé dans json

@export var title: String = ""
@export var right_answer_text: String # todo: changer en nom de variable globale
@export var wrong_answers_text: Array[String]
