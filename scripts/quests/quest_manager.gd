class_name QuestManager extends Control

static var Instance : QuestManager

@export_group("UI")
@export var quest_text: RichTextLabel

var current_quest: Quest = null

func _init() -> void:
	Instance = self
	
func _ready() -> void:
	quest_text.bbcode_enabled = true
	
func start_quest(quest : Quest):
	print("Start quest : ", quest.quest_data.quest_name)
	current_quest = quest
	
func has_already_a_quest() -> bool:
	return current_quest != null	

func complete_current_quest():
	ScoreManager._add_score(current_quest.quest_data.add_score_on_completed)
	current_quest = null
	
func fail_current_quest(): # todo : call
	ScoreManager._add_score(current_quest.quest_data.remove_score_on_failed)
	current_quest = null
	
func _process(_delta: float) -> void:
	update_ui()
	
func update_ui():
	if (current_quest):
		quest_text.text = format_quest_name()
	else:
		quest_text.text = ""
		
	
func format_quest_name() -> String:
	# Format with variables
	var formatted := current_quest.quest_data.quest_name
	formatted = formatted.replace("<target>", str(current_quest.target_value))
	formatted = formatted.replace("<current>", str(current_quest.current_value))

	# Add color
	if current_quest.is_quest_completed:
		return "[color=green]" + formatted + "[/color]"
	else:
		return "[color=cyan]" + formatted + "[/color]"
