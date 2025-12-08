class_name Item extends Node2D

@export var item_visual: Sprite2D
@export var interact_icon : Sprite2D = null

var item_type: ItemSpawnManager.ItemType

func _process(_delta: float) -> void:
	_show_player_interact_indication()
	
func _show_player_interact_indication():
	var player_pos = Player.Instance.global_position
	var interact_radius = Player.Instance.interact_radius
	
	if global_position.distance_to(player_pos) <= interact_radius:
		# show img
		interact_icon.show()
	else:
		# hide img
		interact_icon.hide()

func setup_item(new_item_type : ItemSpawnManager.ItemType):
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

func interact():
	print("interact with item")
	# check if current quest + current quest is item + current quest id is the same
		# -> get item
	# else
		# dialog cant get item
