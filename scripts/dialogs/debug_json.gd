class_name DebugJSON extends Node

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")

@export var json: JSON
@export var origin: String = "#firstInteraction#"
@export var nbr_tests: int = 5
@export var setup_saves: bool = true

var grammar: TraceryScript.Grammar

func _ready() -> void:
	_setup_grammar()
	_debug_json_in_console()
	
func _setup_grammar():
	var rules = json.data
	
	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	if setup_saves:
		grammar.flatten("#setupSaves#", json)
		
func _debug_json_in_console():
	print("------ DEBUG JSON ----- ")
	for i in nbr_tests:
		print("--- TEXT --- ")
		var sentences = grammar.flatten(origin, json)
		var sentences_cut = sentences.split("<next>", false)
		for sentence in sentences_cut:
			print(sentence)
	print("------ DEBUG JSON ----- ")
