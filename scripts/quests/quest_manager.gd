class_name QuestManager extends Control

static var Instance : QuestManager

@export_group("UI")
@export var quest_text: RichTextLabel

var current_quest: Quest = null

func _init() -> void:
	Instance = self
	
func start_quest(quest : Quest):
	print("Start quest : ", quest.quest_data.quest_name)
	current_quest = quest
	
func _process(_delta: float) -> void:
	update_ui()
	
func update_ui():
	if (current_quest):
		quest_text.text = format_quest_name()
	else:
		quest_text.text = ""
	
func format_quest_name() -> String:
	var formatted := current_quest.quest_data.quest_name
	formatted = formatted.replace("<target>", str(current_quest.target_value))
	formatted = formatted.replace("<current>", str(current_quest.current_value))

	return formatted
