extends Control

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")

@export var text_label: RichTextLabel
@export var name_label: RichTextLabel
@export var dialog_btn: Button

var current_npc : Node

var sentences_cut : PackedStringArray
var current_sentence_id: int = 0

func _ready():
	hide_dialog()
	
func _get_and_show_current_state_text():
	_get_current_state()
	
	# Get origin
	var origin : String = ""
	match current_npc.current_dialog_state:
		current_npc.DialogState.FIRST_INTERACTION:
			origin = "#firstInteraction#"
		current_npc.DialogState.QUEST_PROGRESS:
			origin = "#questInProgress#"
		current_npc.DialogState.QUESTION_COMPLETED:
			origin = "#questJustCompleted#"
		current_npc.DialogState.COMPLETED:
			origin = "#completed#"
			
	print("Current state origin : ", origin)
	
	# Get sentences
	var sentences = current_npc.grammar.flatten(origin)
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	var selected_name = current_npc.grammar.get_variable("savedName")
	name_label.text = selected_name
	
func _get_array_sentences(sentences : String):
	# Cut at next
	sentences_cut = sentences.split("<next>", false)
	
	for i in range(sentences_cut.size()):
		sentences_cut[i] = sentences_cut[i].strip_edges()
	
func _show_current_sentence_text():
	var current_sentence = sentences_cut[current_sentence_id]
	text_label.text = current_sentence
	pass
	
func _next_sentence():
	current_sentence_id += 1
	if (current_sentence_id <= sentences_cut.size() - 1):
		_show_current_sentence_text()
	else:
		current_sentence_id = 0
		hide_dialog()
	
func _get_current_state():
	match current_npc.current_dialog_state:
		current_npc.DialogState.NONE:
			current_npc.current_dialog_state = current_npc.DialogState.FIRST_INTERACTION
		
		current_npc.DialogState.FIRST_INTERACTION:
			if (current_npc.has_quest):
				current_npc.current_dialog_state = current_npc.DialogState.QUEST_PROGRESS
			else:
				current_npc.current_dialog_state = current_npc.DialogState.COMPLETED

		# voir pour check quest progress et potentiellement mettre completed direct
		
		# Completed : don't change
		
func _check_quest_progress():
	pass
	
func _on_dialog_pressed() -> void:
	_next_sentence()
	
func show_dialog(npc : Node) -> void:
	current_npc = npc
	_get_and_show_current_state_text()
	dialog_btn.show()
	
func hide_dialog() -> void:
	dialog_btn.hide()
