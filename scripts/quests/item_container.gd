class_name ItemContainer extends Node2D

var has_created_item: bool = false
const ITEM_SCENE := preload("res://scenes/quests/quest_item.tscn")

var room: Node = null

func create_item(item_type : ItemSpawnManager.ItemType):
	var item = ITEM_SCENE.instantiate()
	add_child(item)
	
	if item.has_method("setup_item"):
		item.setup_item(item_type)
	
	has_created_item = true
