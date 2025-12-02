extends Node2D

enum DialogState {
	NONE,
	FIRST_INTERACTION,
	QUEST_PROGRESS,
	QUESTION_COMPLETED,
	COMPLETED,
}

@export var json : JSON
var has_been_init : bool = false;

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")
var grammar: TraceryScript.Grammar

var current_dialog_state = DialogState.NONE
@export var has_quest: bool = true

func _ready():
	_setup_dialog()

func _setup_dialog():
	var rules = json.data
	
	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Save
	grammar.flatten("#setupSaves#")
	
	current_dialog_state = DialogState.NONE

func show_dialog():
	var dialog_manager = get_dialog_manager()
	if dialog_manager:
		dialog_manager.show_dialog(self)
		has_been_init = true
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")

func get_dialog_manager():
	var managers = get_tree().get_nodes_in_group("dialog_manager")
	if managers.size() > 0:
		return managers[0]
	return null
