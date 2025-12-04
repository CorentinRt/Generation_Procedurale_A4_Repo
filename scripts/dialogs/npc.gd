extends Node2D

enum DialogState {
	NONE,
	FIRST_INTERACTION,
	QUEST_PROGRESS,
	QUEST_COMPLETED,
	COMPLETED,
}

@export var json : JSON

const TraceryScript = preload("res://scripts/dialogs/tracery.gd")
var grammar: TraceryScript.Grammar

@export var has_quest: bool = true
var current_dialog_state: DialogState = DialogState.FIRST_INTERACTION

@export var interact_icon : Sprite2D = null
@export var marker_animation : AnimatedSprite2D = null

func _ready():
	_setup_dialog()
	_set_marker_color()
	marker_animation.play()

func _process(delta: float) -> void:
	_show_player_interact_indication()

func _setup_dialog():
	var rules = json.data
	
	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Save
	grammar.flatten("#setupSaves#", json)
	
	current_dialog_state = DialogState.FIRST_INTERACTION

func show_dialog():
	var dialog_manager = UtilsManager.get_dialog_manager()
	if dialog_manager:
		dialog_manager.show_dialog(self)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")


	
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

func on_state_changed():
	_set_marker_color()
	
func _set_marker_color():
	match current_dialog_state:
		DialogState.NONE:
			marker_animation.modulate = Color(2.454, 2.249, 0.0) # Yellow
		DialogState.FIRST_INTERACTION:
			marker_animation.modulate = Color(2.454, 2.249, 0.0) # Yellow
		DialogState.QUEST_PROGRESS:
			marker_animation.modulate = Color(0.206, 2.249, 2.454) # Blue
		DialogState.QUEST_COMPLETED:
			marker_animation.modulate = Color(0.813, 2.249, 0.477) # Green
		DialogState.COMPLETED:
			marker_animation.modulate = Color(0.682, 0.687, 0.734) # Gray
