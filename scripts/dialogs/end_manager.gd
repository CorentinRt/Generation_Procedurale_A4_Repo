extends Node2D

enum EndType{
	NONE,
	YES,
	NO,
	MAYBE
}

# comme question manager qui renvoie les rep mais par contre voir pour 
# les btn setup autrement

func get_random_answers() -> Array[String]:
	return ["Non", "Oui", "Peut-être", "Je sais pas"]

func on_click_on_end_type(end_type : EndType):
	var leave: bool = false
	
	match(end_type):
		EndType.NO:
			leave = false
		EndType.YES:
			leave = true
		EndType.MAYBE:
			leave = randi() % 2 == 0 # une chance sur 2 de leave
	
	UtilsManager.get_dialog_manager().on_end_answer_pressed(leave)
	
func end_game(): 
	# load scene ended_game
	GameManager._load_menu_scene()
