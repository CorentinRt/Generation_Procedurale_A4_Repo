extends Node

enum ItemType{
	ANCHOR,
	CANNON_BALLS,
	FISH,
	KEY,
	CANNON
}

var created_items: Dictionary = {}
var containers: Array[ItemContainer] = []

func _ready():
	_init_created_items()
	_find_all_containers()

func _init_created_items():
	for key in ItemType.keys():
		created_items[ItemType[key]] = false

func _find_all_containers():
	for node in get_tree().get_nodes_in_group("item_quest_container"):
		if node is ItemContainer:
			containers.append(node)
	print("Item containers found : ", containers.size())

func get_random_uncreated_item_type():
	# Get not created types
	var available_types: Array[ItemType] = []
	for item_type in created_items:
		if not created_items[item_type]:
			available_types.append(item_type)
	
	if available_types.is_empty():
		return null
			
	# Get random
	return available_types[randi() % available_types.size()]

func spawn_item(item_type : ItemType):
	print("Spawn item : ", item_type)
	
	if item_type == null:
		print("Tous les items sont déjà créés")
		return

	for container in containers:
		if not container.has_created_item:
			container.create_item(item_type)
			created_items[item_type] = true
			return
	
	print("Aucun container libre !")
