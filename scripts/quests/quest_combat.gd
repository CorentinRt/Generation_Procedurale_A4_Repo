class_name QuestCombat extends Quest

func _ready() -> void:
	# Setup data
	quest_data = load("res://resources/quests/qd_combat.tres")
	target_value = 2 # temp fixe, random à mettre
	
	GameManager.on_kill_enemy.connect(add_one_target_value)
