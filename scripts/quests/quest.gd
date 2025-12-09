class_name Quest extends Node

@export var quest_data: QuestData

var is_quest_started: bool = false
var is_quest_completed: bool = false
var is_quest_failed: bool = false

var target_value: int = 0
var current_value: int = 0

func start_quest():
	is_quest_started = true
	
func end_quest():
	is_quest_started = false
	
func fail_quest():
	is_quest_started = false
	is_quest_failed = true

# ennemy killed, item found...
func add_one_current_value():
	add_current_value(1)
		
func add_current_value(value : int):
	if !is_quest_started:
		return
	
	current_value += value
	if current_value >= target_value:
		is_quest_completed = true
		
func set_completed():
	is_quest_completed = true

# To override in children
func format_target_value() -> String:
	assert(false, "use() must be overridden in child class")
	return ""
