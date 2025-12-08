class_name QuestCombat extends Quest

# A mettre à 5 - 10 apres tests
var target_min_value: int = 1
var target_max_value: int = 2

func _ready() -> void:
	# Setup data
	quest_data = load("res://resources/quests/qd_combat.tres")
	target_value = randi_range(target_min_value, target_max_value)
	
	GameManager.on_kill_enemy.connect(add_one_target_value)
