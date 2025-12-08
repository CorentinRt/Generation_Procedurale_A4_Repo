class_name QuestCombat extends Quest

func _ready() -> void:
	# Setup data
	quest_data = load("res://resources/quests/qd_combat.tres")
	target_value = 1 # temp fixe, random à mettre
	
	# todo : connect to event enemy killed -> add_one_target_value()
	GameManager.on_kill_enemy.connect(add_one_target_value)
