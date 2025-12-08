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

# Quest
@export var has_quest: bool = true
var savedQuest: String = ""
var quest: Quest = null

var current_dialog_state: DialogState = DialogState.FIRST_INTERACTION

@export var interact_icon : Sprite2D = null
@export var marker_animation : AnimatedSprite2D = null

@export var sprite_animation_player : AnimationPlayer
@export var notif_animation_player : AnimationPlayer

func _ready():
	_setup_dialog()
	_set_marker_color()
	marker_animation.play()
	notif_animation_player.play("idle")

func _process(_delta: float) -> void:
	_show_player_interact_indication()

func _setup_dialog():
	var rules = json.data
	
	grammar = TraceryScript.Grammar.new(rules)
	grammar.add_modifiers(TraceryScript.UniversalModifiers.get_modifiers())
	
	# Save
	grammar.flatten("#setupSaves#", json)
	
	current_dialog_state = DialogState.FIRST_INTERACTION
	
	# Quest
	savedQuest = QuestionManager.get_variable_text_from_json(json, "savedQuest");
	print("Saved quest : ", savedQuest)
	if (savedQuest != ""):
		has_quest = true
		_add_quest_script()
	else:
		has_quest = false
	
func _add_quest_script():
	if savedQuest != "Combat":
		return
	
	match(savedQuest):
		"Combat":
			var quest_node := Node.new()
			quest_node.name = "Quest_Combat"
			var quest_script := load("res://scripts/quests/quest_combat.gd")
			quest_node.set_script(quest_script)

			add_child(quest_node)

			quest = quest_node as Quest
			print("Quest script added : ", quest)
			
func start_quest():
	if has_quest && quest != null:
		QuestManager.Instance.start_quest(quest)
		
func is_quest_completed() -> bool:
	return quest.is_quest_completed

func show_dialog():
	var dialog_manager = UtilsManager.get_dialog_manager()
	if dialog_manager:
		dialog_manager.show_dialog(self)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")
	
	sprite_animation_player.play("interact")
	
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
			if (quest.is_quest_completed):
				marker_animation.modulate = Color(0.206, 2.249, 2.454) # Blue
			else:
				marker_animation.modulate = Color(0.813, 2.249, 0.477) # Green
		DialogState.QUEST_COMPLETED:
			marker_animation.modulate = Color(0.813, 2.249, 0.477) # Green
		DialogState.COMPLETED:
			marker_animation.modulate = Color(0.682, 0.687, 0.734) # Gray
