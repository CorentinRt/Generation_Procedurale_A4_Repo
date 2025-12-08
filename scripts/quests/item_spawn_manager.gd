extends Node

enum ItemType{
	ANCHOR,
	CANNON_BALLS,
	FISH,
	KEY,
	CANNON
}

var created_items: Dictionary = {}

func _ready():
	# Init dict
	for key in ItemType.keys():
		created_items[ItemType[key]] = false

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

func set_item_type_created(created_item_type : ItemType):
	created_items[created_items] = true
