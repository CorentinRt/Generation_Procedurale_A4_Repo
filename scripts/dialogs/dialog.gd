extends Control

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")

# UI
@export var text_label: RichTextLabel
@export var name_label: RichTextLabel
@export var dialog_btn: Button
@export var type_speed:float = 0.02
@export var button_style: StyleBoxFlat

# Questions
@export var questions_btn: Array[DialogButton]
@export var questions_data : Array[Question]
@export var no_question_pos : Vector2
@export var questions_pos : Vector2

# NPC
var current_npc : Node

# Cut des phrases
var sentences_cut : PackedStringArray
var current_sentence_id: int = 0

# Affichage progressif
var is_typing: bool = false
var full_sentence: String = ""
var revealed_characters: int = 0

# Questions
var is_in_questions: bool = false
# current question
# list resource questions

func _ready():
	hide_dialog()
	
#region Get Sentences
func _get_and_show_current_state_text():
	# Get origin
	var origin : String = ""
	match current_npc.current_dialog_state:
		current_npc.DialogState.FIRST_INTERACTION:
			origin = "#firstInteraction#"
		current_npc.DialogState.QUEST_PROGRESS:
			origin = "#questInProgress#"
		current_npc.DialogState.QUEST_COMPLETED:
			origin = "#questJustCompleted#"
		current_npc.DialogState.COMPLETED:
			origin = "#completed#"
			
	print("Current state origin : ", origin)
	
	# Get sentences
	var sentences = current_npc.grammar.flatten(origin)
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	# Get name
	var saved_name = current_npc.grammar.get_variable("savedName")
	name_label.text = saved_name

func _get_array_sentences(sentences : String):
	print("Get array sentences")
	# Cut at next
	sentences_cut = sentences.split("<next>", false)
	
	for i in range(sentences_cut.size()):
		sentences_cut[i] = sentences_cut[i].strip_edges()
#endregion

#region Color
func _get_color_from_string(colorStr : String) -> Color:
	match(colorStr):
		"white":
			return Color(1.0, 1.0, 1.0, 1.0)
		"gray":
			return Color(0.501, 0.501, 0.501, 1.0)
		"black":
			return Color(0.0, 0.0, 0.0, 1.0)
		"pink":
			return Color(0.931, 0.352, 1.0, 1.0)
		"cyan":
			return Color(0.0, 0.945, 0.867, 1.0)
		"red":
			return Color(1.0, 0.0, 0.0, 1.0)
	
	return Color(1,1,1)
	
func set_button_color(btn: Button, color: Color) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = btn.get_theme_stylebox(state)
		if style == null:
			style = StyleBoxFlat.new()
		# Ici on modifie directement
		style.bg_color = color
		btn.add_theme_stylebox_override(state, style)

func set_saved_color():
	print("Set saved color")
	
	var saved_color = current_npc.grammar.get_variable("savedColor")
	var color : Color = _get_color_from_string(saved_color)
	set_button_color(dialog_btn, color)

#endregion

#region Show text
func _show_current_sentence_text():
	full_sentence = sentences_cut[current_sentence_id]
	
	if full_sentence == "<questions>":
		print("start questions")
		full_sentence = _get_and_setup_random_question()
		if (!is_in_questions):
			is_in_questions = true
			_start_questions_ui()
	else:
		if (is_in_questions):
			is_in_questions = false
			_end_questions_ui()
	
	revealed_characters = 0
	text_label.text = ""
	
	is_typing = true
	_start_typing()
	
func _start_typing():
	# End typing
	if revealed_characters >= full_sentence.length() or not is_typing:
		text_label.text = full_sentence
		is_typing = false
		return

	# Add character
	revealed_characters += 1
	text_label.text = full_sentence.substr(0, revealed_characters)

	# Wait & recursive
	await get_tree().create_timer(type_speed).timeout
	_start_typing()  

func _next_sentence():
	current_sentence_id += 1
	if (current_sentence_id <= sentences_cut.size() - 1):
		_show_current_sentence_text()
	else:
		current_sentence_id = 0
		hide_dialog()
#endregion

#region Current State & Quest
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
	
	current_npc.on_state_changed()
		
func _check_quest_progress():
	pass
#endregion

#region Show / Hide & Pressed
func _on_dialog_pressed() -> void:
	if is_in_questions:
		return
	
	if is_typing:
		# Skip typing
		is_typing = false
	else:
		# Next
		_next_sentence()
		
func show_dialog(npc : Node) -> void:
	current_npc = npc
	_get_and_show_current_state_text()
	dialog_btn.show()
	hide_questions_btn()
	set_saved_color()
	
func hide_dialog() -> void:
	dialog_btn.hide()
	if current_npc:
		_get_current_state()
		
func show_questions_btn():
	for btn in questions_btn:
		btn.show()
		
func hide_questions_btn():
	for btn in questions_btn:
		btn.hide()
#endregion

#region Questions
func _start_questions():
	pass
	
func _start_questions_ui():
	dialog_btn.set_global_position(questions_pos)
	show_questions_btn()
	pass
	
func _end_questions_ui():
	dialog_btn.set_global_position(no_question_pos)
	hide_questions_btn()
	pass
	
func _get_and_setup_random_question() -> String:
	# Question title
	var random_question = questions_data.pick_random()
	questions_data.erase(random_question)
	print("Random question : ", random_question.title)
	
	var random_answers: Array[String]
	
	# i = 0 : Right 
	random_answers.append(random_question.right_answer_text)
	print(random_answers[0])
	
	# i = 1, 2, 3 : Wrong answer
	var temp = random_question.wrong_answers_text.duplicate()
	for i in 3:
		var index = randi() % temp.size()
		random_answers.append(temp[index])
		temp.remove_at(index)
	
	# Question answers
	questions_btn.shuffle()
	for i in questions_btn.size():
		if i == 0: # Right
			questions_btn[i].setup_btn(random_answers[i], true);
		else: # Wrong
			questions_btn[i].setup_btn(random_answers[i], false);
	
	return random_question.title
	
func on_click_on_button():
	# todo : class btn qui set le texte + bool is good et qui renvoie ici
	pass
#endregion
