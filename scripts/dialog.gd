extends Control

const TraceryScript = preload("res://scripts/tracery.gd")

@export var json: JSON
@export var text_label: RichTextLabel
@export var name_label: RichTextLabel

var grammar: TraceryScript.Grammar

func _ready():
	var rules = json.data

	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())

	var sentence = grammar.flatten("#origin#")
	text_label.text = sentence
	
	var selected_name = grammar.get_variable("selected")
	name_label.text = selected_name
