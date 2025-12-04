extends Node

enum RightAnswerType {
	PLAYER_NAME,
	PLAYER_AGE
}

# todo: changer avec les nouveaux npc
@onready var start_json: JSON = load("res://resources/dialogs/d_start.json")

var saved_dict : Dictionary = {}

func get_text_answer_from_type(answerType : RightAnswerType) -> String:
	var answer: String = ""
	
	match answerType:
		RightAnswerType.PLAYER_NAME:
			answer = get_variable_text_from_json(start_json, "savedPlayerName")
		RightAnswerType.PLAYER_AGE:
			answer = get_variable_text_from_json(start_json, "savedPlayerAge")
	
	return answer
	
func save_variables_for_json(json : JSON, variables : Dictionary):
	var path : String = json.resource_path
	saved_dict[path] = variables
	
func get_variable_text_from_json(json : JSON, variable_name : String) -> String:
	return saved_dict[json.resource_path][variable_name]
