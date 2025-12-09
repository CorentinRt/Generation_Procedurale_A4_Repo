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
