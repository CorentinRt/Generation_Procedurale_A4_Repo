class_name Item extends Node2D

@export var item_visual: Sprite2D

var item_type: ItemSpawnManager.ItemType

func setup_item(new_item_type : ItemSpawnManager.ItemType):
	print("setup item : ", new_item_type)
	
	item_type = new_item_type
	
	# Set visuals
	match item_type:
		ItemSpawnManager.ItemType.ANCHOR:
			item_visual.texture = load("res://sprites/imports/kenney_monochrome-pirates/Default/Tiles/tile_anchor.png")
		ItemSpawnManager.ItemType.CANNON_BALLS:
			item_visual.texture = load("res://sprites/imports/kenney_monochrome-pirates/Default/Tiles/tile_cannonballs.png")
		ItemSpawnManager.ItemType.FISH:
			item_visual.texture = load("res://sprites/imports/kenney_monochrome-pirates/Default/Tiles/tile_fish.png")
		ItemSpawnManager.ItemType.KEY:
			item_visual.texture = load("res://sprites/imports/kenney_monochrome-pirates/Default/Tiles/tile_key.png")
		ItemSpawnManager.ItemType.CANNON:
			item_visual.texture = load("res://sprites/imports/kenney_monochrome-pirates/Default/Tiles/tile_cannon.png")
