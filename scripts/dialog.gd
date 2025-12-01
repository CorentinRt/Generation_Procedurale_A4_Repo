extends Control

const Tracery = preload("res://scripts/tracery.gd")

@export var text_label: RichTextLabel

var grammar: Tracery.Grammar

func _ready():
	# test rules, todo: load json
	var rules := {
		"origin": [
			"Bonjour, je suis #adj# #animal#.",
            "Aujourd’hui, j’ai vu #a.animal# dans #place#."
		],
		"adj": ["petit", "grand", "joli", "effrayant"],
		"animal": ["chat", "chien", "hibou", "renard"],
		"place": ["la forêt", "le jardin", "la rue", "le studio"]
	}

	grammar = Tracery.Grammar.new(rules)
	grammar.add_modifiers(Tracery.UniversalModifiers.get_modifiers())

	var sentence = grammar.flatten("#origin#")
	text_label.text = sentence
