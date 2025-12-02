extends Control

const TraceryScript = preload("res://scripts/tracery.gd")

@export var json: JSON
@export var text_label: RichTextLabel
@export var name_label: RichTextLabel
@export var dialog_btn: Button

var grammar: TraceryScript.Grammar

enum DialogState {
	NONE,
	FIRST_INTERACTION,
	QUEST_PROGRESS,
	QUESTION_COMPLETED,
	COMPLETED,
}

var current_dialog_state = DialogState.NONE
@export var has_quest: bool = true

@export var debug_at_start: bool = false

var sentences_cut : PackedStringArray
var current_sentence_id: int = 0

func _ready():
	_setup_dialog()

	if (debug_at_start):
		_show_dialog()
		_get_current_state_text()
	else:
		_hide_dialog()
	
func _setup_dialog():
	var rules = json.data

	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Save
	grammar.flatten("#setupSaves#")

func _get_current_state_text():
	print("Show current state text")
	_get_current_state()
	
	# Get origin
	var origin : String = ""
	match current_dialog_state:
		DialogState.FIRST_INTERACTION:
			origin = "#firstInteraction#"
		DialogState.QUEST_PROGRESS:
			origin = "#questInProgress#"
		DialogState.QUESTION_COMPLETED:
			origin = "#questJustCompleted#"
		DialogState.COMPLETED:
			origin = "#completed#"
			
	# Get sentences
	var sentences = grammar.flatten(origin)
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	var selected_name = grammar.get_variable("savedName")
	name_label.text = selected_name
	
	pass

func _get_array_sentences(sentences : String):
	# Cut at next
	sentences_cut = sentences.split("<next>", false)
	
	print("Senteces cut size : ", sentences_cut.size())
	
	for i in range(sentences_cut.size()):
		sentences_cut[i] = sentences_cut[i].strip_edges()
		print("Cut sentence :", sentences_cut[i])
	
func _show_current_sentence_text():
	var current_sentence = sentences_cut[current_sentence_id]
	text_label.text = current_sentence
	pass

func _next_sentence():
	current_sentence_id += 1
	if (current_sentence_id <= sentences_cut.size() - 1):
		_show_current_sentence_text()
	else:
		_hide_dialog()
	
func _get_current_state():
	match current_dialog_state:
		DialogState.NONE:
			current_dialog_state = DialogState.FIRST_INTERACTION
		
		DialogState.FIRST_INTERACTION:
			if (has_quest):
				current_dialog_state = DialogState.QUEST_PROGRESS
			else:
				current_dialog_state = DialogState.COMPLETED

		# voir pour check quest progress et potentiellement mettre completed direct
		
		# Completed : don't change
		
func _check_quest_progress():
	pass


func _on_dialog_pressed() -> void:
	print("Dialog button pressed")
	_next_sentence()
	
func _show_dialog() -> void:
	dialog_btn.show()
	
func _hide_dialog() -> void:
	dialog_btn.hide()
	
