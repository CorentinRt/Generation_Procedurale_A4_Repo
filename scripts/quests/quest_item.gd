class_name QuestItem extends Quest

func _ready() -> void:
	# Setup data 
	quest_data = load("res://resources/quests/qd_item.tres")

func setup_item(avoid_room: Room = null):
	target_value = ItemSpawnManager.get_random_uncreated_item_type() # enum id of item type
	
	# Create random item in different room
	ItemSpawnManager.spawn_item(target_value, avoid_room)

func format_target_value() -> String:
	match target_value:
		ItemSpawnManager.ItemType.ANCHOR:
			return "l'ancre"
		ItemSpawnManager.ItemType.CANNON_BALLS:
			return "les boulets de cannons"
		ItemSpawnManager.ItemType.FISH:
			return "le poisson"
		ItemSpawnManager.ItemType.KEY:
			return "la clé"
		ItemSpawnManager.ItemType.CANNON:
			return "le canon"
		_:
			return "inconnu"
