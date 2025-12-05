class_name SimpleDialogManager extends Node2D

@export var skulls_json: JSON
@export var letters_json: JSON

var skulls_text: Array[String]
var letters_text: Array[String]

var simple_dialogs: Array[Node]

func _ready() -> void:
	_get_skulls_texts()
	_get_letters_texts()
	
	_get_simple_dialogs()
	_setup_dialogs()

func _get_simple_dialogs():
	simple_dialogs = get_tree().get_nodes_in_group("simple_dialog") 

func _get_skulls_texts():
	skulls_text = _get_strings(skulls_json)
	
func _get_letters_texts():
	skulls_text = _get_strings(skulls_json)

func _get_strings(json: JSON) -> Array[String]:
	print("get strings")
	if json == null:
		push_error("json null")
		return []

	var data = json.data
	if data is Array:
		var string_array: Array[String] = []
		for item in data:
			string_array.append(str(item))  
		return string_array

	push_error("JSON.data n'est pas un Array !")
	return []

func _setup_dialogs():
	pass
	# get dialog
	# switch type
	# set text random skull or letter and remove from list
	
	
