class_name QuestCombat extends Quest

func _ready() -> void:
	# Setup data
	quest_data = load("res://resources/quests/qd_combat.tres")
	target_value = 5
