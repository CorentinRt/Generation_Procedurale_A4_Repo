class_name SimpleDialogManager extends Node2D

@export_group("Skulls")
@export var skulls_json: JSON
@export var skulls_color: Color

@export_group("Letters")
@export var letters_json: JSON
@export var letters_color: Color

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
	letters_text = _get_strings(letters_json)

func _get_strings(json: JSON) -> Array[String]:
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
	for dialog in simple_dialogs:
		match dialog.dialog_type:
			SimpleDialog.SimpleDialogType.SKULL:
				if(skulls_text.size() <= 0): #Pour pouvoir générer meme si on a plus de textes de skulls
					continue
				skulls_text.shuffle()
				var random = skulls_text[0]
				dialog.setup(random, skulls_color)
				skulls_text.erase(random)
				
			SimpleDialog.SimpleDialogType.LETTER:
				if(letters_text.size() <= 0): #Pour pouvoir générer meme si on a plus de textes de skulls
					continue
				letters_text.shuffle()
				var random = letters_text[0]
				dialog.setup(letters_text[0], letters_color)
				letters_text.erase(random)
