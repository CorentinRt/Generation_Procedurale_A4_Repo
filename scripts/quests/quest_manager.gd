class_name QuestManager extends Control

static var Instance : QuestManager

@export_group("UI")
@export var quest_text: RichTextLabel
@export var custom_timer: CustomTimer

var current_quest: Quest = null

func _init() -> void:
	Instance = self
	
func _ready() -> void:
	quest_text.bbcode_enabled = true
	custom_timer.hide_timer()
	QuestManager.Instance.custom_timer.timer_finished.connect(_on_timer_end)
	

func _on_timer_end():
	current_quest.fail_quest()
	fail_current_quest()

	
func start_quest(quest : Quest):
	current_quest = quest
	if (current_quest.quest_data.timer_time > 0):
		custom_timer.show_and_start_timer(current_quest.quest_data.timer_time)
	
func has_already_a_quest() -> bool:
	return current_quest != null	

func complete_current_quest():
	if (current_quest.quest_data.timer_time > 0):
		custom_timer.hide_and_stop_timer()
		
	ScoreManager._add_score(current_quest.quest_data.add_score_on_completed)
	current_quest = null
	
func fail_current_quest(): 
	ScoreManager._remove_score(current_quest.quest_data.remove_score_on_failed)
	current_quest = null
	
func _process(_delta: float) -> void:
	update_ui()
	
func update_ui():
	if (current_quest):
		quest_text.text = format_quest_name() + "\n" + format_quest_reward() + "\n" + format_quest_loss()
	else:
		quest_text.text = "Aucune quête en cours."
		
	
func format_quest_name() -> String:
	# Format with variables
	var formatted := current_quest.quest_data.quest_name
	formatted = formatted.replace("<target>", current_quest.format_target_value())
	formatted = formatted.replace("<current>", str(current_quest.current_value))

	# Add color
	if current_quest.is_quest_completed:
		return "[color=green]" + formatted + "[/color]"
	else:
		return "[color=cyan]" + formatted + "[/color]"

func format_quest_reward() -> String:
	return "[color=yellow]Reward : +" + str(current_quest.quest_data.add_score_on_completed) + "[/color]"

func format_quest_loss() -> String:
	if current_quest.quest_data.can_fail:
		return "[color=red]Failed : -" + str(current_quest.quest_data.remove_score_on_failed) + "[/color]"
	return ""
