class_name Quest extends Node

@export var quest_data: QuestData

var is_quest_started: bool = false
var is_quest_completed: bool = false
var is_quest_failed: bool = false

var target_value: int = 0
var current_value: int = 0

var current_timer: float = 0

func _process(delta: float) -> void:
	if is_quest_started && quest_data.timer_time > 0:
		current_timer += delta
		if current_timer >= quest_data.timer_time:
			is_quest_started = false
			is_quest_failed = true
			QuestManager.Instance.fail_current_quest()
			print("Quest failed")

func start_quest():
	current_timer = 0
	is_quest_started = true
	
func end_quest():
	is_quest_started = false

# ennemy killed, item found...
func add_one_target_value():
	if !is_quest_started:
		return
	
	print("Add one target value to quest")
	current_value += 1
	if current_value >= target_value:
		is_quest_completed = true
