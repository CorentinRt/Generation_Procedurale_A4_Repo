class_name QuestAddScore extends Quest

func _ready() -> void:
	# Setup data
	quest_data = load("res://resources/quests/qd_add_score.tres")
	target_value = 100000
	
	ScoreManager._on_add_score.connect(add_current_value)

func format_target_value() -> String:
	return str(target_value)
