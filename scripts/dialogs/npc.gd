extends Node2D

enum DialogState {
	NONE,
	FIRST_INTERACTION,
	QUEST_PROGRESS,
	QUESTION_COMPLETED,
	COMPLETED,
}

@export var json : JSON

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")
var grammar: TraceryScript.Grammar

@export var has_quest: bool = true
var current_dialog_state = DialogState.NONE

@export var interact_icon : Sprite2D = null
@export var marker_animation : AnimatedSprite2D = null

func _ready():
	_setup_dialog()
	marker_animation.play()

func _process(delta: float) -> void:
	_show_player_interact_indication()

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
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")

func get_dialog_manager():
	var managers = get_tree().get_nodes_in_group("dialog_manager")
	if managers.size() > 0:
		return managers[0]
	return null
	
func _show_player_interact_indication():
	var player_pos = Player.Instance.global_position
	var interact_radius = Player.Instance.interact_radius
	
	if global_position.distance_to(player_pos) <= interact_radius:
		# show img
		interact_icon.show()
	else:
		# hide img
		interact_icon.hide()
	pass
