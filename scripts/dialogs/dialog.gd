extends Control

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")

@export_group("JSON")
@export var start_json: JSON
@export var taunt_json: JSON
@export var questions_answers_json: JSON 

@export_group("UI")
@export var text_label: RichTextLabel
@export var name_label: RichTextLabel
@export var name_panel: Panel
@export var dialog_btn: Button
@export var button_style: StyleBoxFlat
@export var type_speed:float = 0.02

@export_group("Questions")
@export var questions_btn: Array[DialogButton]
@export var questions_data: Array[Question]
@export var no_question_pos: Vector2
@export var questions_pos: Vector2
@export var add_score_right_answer: int = 100000
@export var remove_score_wrong_answer: int = 100000
@export var custom_timer: CustomTimer
@export var question_time: float = 5.0

var start_grammar: TraceryScript.Grammar
var questions_grammar: TraceryScript.Grammar
var taunt_grammar: TraceryScript.Grammar

var is_in_dialog: bool = false

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

func _ready():
	hide_dialog()
	_setup_grammars()
	show_start_dialog()
	
	# Timer
	custom_timer.timer_finished.connect(_on_timer_end)
	custom_timer.hide_timer()

#region Setup
func _setup_grammars():
	# Questions
	var questions_rules = questions_answers_json.data
	
	questions_grammar = TraceryScript.Grammar.new(questions_rules)
	questions_grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Start
	var start_rules = start_json.data
	
	start_grammar = TraceryScript.Grammar.new(start_rules)
	start_grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Taunt
	var taunt_rules = taunt_json.data
	
	taunt_grammar = TraceryScript.Grammar.new(taunt_rules)
	taunt_grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
#endregion
	
#region Show dialog JSON
func show_start_dialog():
	show_dialog_json(start_json, start_grammar)
	
func show_taunt_dialog():
	if is_in_dialog:
		return
		
	show_dialog_json(taunt_json, taunt_grammar)
	
func show_dialog_json(json : JSON, grammar : TraceryScript.Grammar):
	is_in_dialog = true
	Player.Instance.set_is_in_dialog(is_in_dialog)
	
	grammar.flatten("#setupSaves#", json)
	
	var sentences = grammar.flatten("#firstInteraction#", json)
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	_set_name(grammar)
	
	dialog_btn.show()
	hide_questions_btn()
	var saved_color = grammar.get_variable("savedColor")
	var color : Color = _get_color_from_string(saved_color)
	set_button_color(dialog_btn, color)
#endregion	

#region Setup Name
func _set_name(grammar : TraceryScript.Grammar):
	name_label.show()
	var saved_name = grammar.get_variable("savedName")
	name_label.text = saved_name
		
func _hide_name():
	name_label.show()
	name_label.text = "???"
#endregion
	
#region Get Sentences
func _get_and_show_current_state_text():
	# Get origin
	_check_quest_progress()
	
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
	var sentences = current_npc.grammar.flatten(origin, current_npc.json)
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	_set_name(current_npc.grammar)

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
			return Color(0.882, 0.882, 0.882, 1.0)
		"gray":
			return Color(0.537, 0.537, 0.537, 1.0)
		"black":
			return Color(0.074, 0.12, 0.188, 1.0)
		"pink":
			return Color(0.966, 0.565, 0.866, 1.0)
		"cyan":
			return Color(0.23, 0.624, 0.602, 1.0)
		"red":
			return Color(0.946, 0.414, 0.373, 1.0)
	
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
	print("full sentence : ", full_sentence)
	
	if full_sentence == "<question>":
		print("start question")
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
	
	# ----- AUDIO ----- #
	AudioManager.Instance.play_dialog_beep()
	# ----- AUDIO ----- #

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
				# Start quest
				current_npc.start_quest()
				current_npc.current_dialog_state = current_npc.DialogState.QUEST_PROGRESS
			else:
				current_npc.current_dialog_state = current_npc.DialogState.COMPLETED

		current_npc.DialogState.QUEST_PROGRESS:
			if current_npc.is_quest_completed():
				current_npc.current_dialog_state = current_npc.DialogState.QUEST_COMPLETED
		
		current_npc.DialogState.QUEST_COMPLETED:
			current_npc.current_dialog_state = current_npc.DialogState.COMPLETED

		# Completed : don't change
	
	current_npc.on_state_changed()
		
func _check_quest_progress():
	if current_npc:
		if current_npc.current_dialog_state == current_npc.DialogState.QUEST_PROGRESS:
			if current_npc.is_quest_completed():
				current_npc.current_dialog_state = current_npc.DialogState.QUEST_COMPLETED
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
		
func _on_answer_pressed(is_right_answer : bool):
	_end_questions_ui()
	stop_question_timer()
	is_in_questions = false
	if (is_right_answer):
		full_sentence = questions_grammar.flatten("#rightAnswer#", questions_answers_json)
	else:
		full_sentence = questions_grammar.flatten("#wrongAnswer#", questions_answers_json)
	revealed_characters = 0
	text_label.text = ""
	
	_set_name(current_npc.grammar) # Reset if name = "???"
	ScoreManager._show(true) # Reset if score hidden
	is_typing = true
	_start_typing()
		
func show_dialog(npc : Node) -> void:
	if is_in_dialog:
		return
	
	is_in_dialog = true
	Player.Instance.set_is_in_dialog(is_in_dialog)
	
	current_npc = npc
	_get_and_show_current_state_text()
	dialog_btn.show()
	hide_questions_btn()
	set_saved_color()
	
func hide_dialog() -> void:
	dialog_btn.hide()
	if current_npc:
		_get_current_state()
		
	is_in_dialog = false
	Player.Instance.set_is_in_dialog(is_in_dialog)
		
func show_questions_btn():
	for btn in questions_btn:
		btn.show()
		
func hide_questions_btn():
	for btn in questions_btn:
		btn.hide()
#endregion

#region Questions	
func _start_questions_ui():
	dialog_btn.set_global_position(questions_pos)
	show_questions_btn()
	start_question_timer()
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
	var right_answerText: String = ""
	right_answerText = QuestionManager.get_text_answer_from_type(random_question.right_answer_type, random_question.static_answer_for_type_not_saved)
	random_answers.append(right_answerText)
	print(random_answers[0])
	
	# i = 1, 2, 3 : Wrong answer
	var temp = random_question.wrong_answers_text.duplicate()
	var needed = 3
	while random_answers.size() < needed + 1: # +1 car random_answers[0] est la bonne
		if temp.is_empty():
			break # pas assez de réponses différentes
		var index = randi() % temp.size()
		if temp[index] == random_answers[0]:
			print("same answer wrong & right, retrying")
			temp.remove_at(index) # on l'enlève pour éviter de boucler infiniment
			continue
		random_answers.append(temp[index])
		temp.remove_at(index)
	
	# Question answers
	questions_btn.shuffle()
	for i in questions_btn.size():
		if i == 0: # Right
			questions_btn[i].setup_btn(first_letter_upper(random_answers[i]), true);
		else: # Wrong
			questions_btn[i].setup_btn(first_letter_upper(random_answers[i]), false);
	
	return random_question.title
	
func first_letter_upper(s: String) -> String:
	if s == "":
		return s
	var first = s.substr(0, 1).to_upper()
	return first + s.substr(1, s.length() - 1)
#endregion

#region Timer
func start_question_timer():
	custom_timer.show_and_start_timer(question_time)
	
func stop_question_timer():
	custom_timer.hide_and_stop_timer()
	
func _on_timer_end():
	ScoreManager._remove_score(remove_score_wrong_answer)
	_end_questions_ui()
	is_in_questions = false
	
	full_sentence = questions_grammar.flatten("#timerAnswer#", questions_answers_json)
	revealed_characters = 0
	text_label.text = ""
	
	_set_name(current_npc.grammar) # Reset if name = "???"
	ScoreManager._show(true) # Reset if score hidden
	is_typing = true
	_start_typing()
#endregion

#region Simple Dialog (only text, no tracery except <next> + no name)
func start_simple_dialog(dialog_text: String, color : Color):
	is_in_dialog = true
	Player.Instance.set_is_in_dialog(is_in_dialog)
	
	var sentences = dialog_text
	_get_array_sentences(sentences)
	
	_show_current_sentence_text()
	
	name_label.hide()
	name_panel.hide()
	
	dialog_btn.show()
	hide_questions_btn()

	set_button_color(dialog_btn, color)
	pass
#endregion
