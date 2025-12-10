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

func init_quest_items() -> void:
	created_items.clear()
	containers.clear()
	_init_created_items()
	_find_all_containers()

func _init_created_items():
	for key in ItemType.keys():
		created_items[ItemType[key]] = false

func _find_all_containers():
	for node in get_tree().get_nodes_in_group("item_quest_container"):
		if node is ItemContainer:
			node.room = get_room_from_node(node)
			containers.append(node)

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

func spawn_item(item_type: ItemType, avoid_room: Node = null):
	if item_type == null:
		print("Tous les items sont déjà créés")
		return

	for container in containers:
		if not container.has_created_item:
			var container_room = container.room  
			
			# Skip containers with room to avoid (npc room)
			if container_room == avoid_room:
				continue  
				
			container.create_item(item_type)
			created_items[item_type] = true
			return

	print("Aucun container libre !")

func get_room_from_node(node: Node) -> Node:
	var current = node
	while current != null:
		if current is Room:
			return current
		current = current.get_parent()
	return null
