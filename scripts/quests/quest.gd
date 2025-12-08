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
func add_one_target_value():
	if !is_quest_started:
		return
	
	current_value += 1
	if current_value >= target_value:
		is_quest_completed = true
