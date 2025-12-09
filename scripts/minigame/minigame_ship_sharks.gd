class_name Minigame_Ship_Sharks extends Room_Minigame

var sharks_paths : Array[Shark_Path]

var chest : Chest_Item

@export var north_potentials : Array[Node2D]
@export var south_potentials : Array[Node2D]
@export var west_potentials : Array[Node2D]
@export var east_potentials : Array[Node2D]

func _setup_minigame() -> void:
	super()
	_disable_all_potentials()
	
	_score = _scores_datas._minigame_completed_ship_sharks
	for i in get_parent().get_children():
		if i is Shark_Path:
			sharks_paths.append(i)
		
func _disable_all_potentials() -> void:
	for i in north_potentials:
		i.visible = false
	for i in south_potentials:
		i.visible = false
	for i in west_potentials:
		i.visible = false
	for i in east_potentials:
		i.visible = false
			
func _receive_on_enter_room_zone_callback(player_pos : Vector2) -> void:
	super(player_pos)
		# enable some items depending on where the player entered
	match(_first_direction_player_entered):
		DIRECTION_ROOM.NONE:
			push_error("potentials ship shark direction not computed in time ! Please check you have a zone room detector or call a programmer !")
		DIRECTION_ROOM.EAST:
			_setup_potentials_items(east_potentials)
		DIRECTION_ROOM.WEST:
			_setup_potentials_items(west_potentials)
		DIRECTION_ROOM.NORTH:
			_setup_potentials_items(north_potentials)
		DIRECTION_ROOM.SOUTH:
			_setup_potentials_items(south_potentials)
	

# enable right items with direction
func _setup_potentials_items(potentials : Array[Node2D]) -> void:
	for i in potentials:
		i.visible = true
		if !i.is_in_group("item_minigame"):
			continue
		if chest == null && i is Chest_Item:
			chest = i
			chest.on_chest_opened.connect(receive_chest_opened_callback)
	
			
func receive_chest_opened_callback() -> void:
	_set_state(MINIGAME_STATE.COMPLETED)
	
	if chest != null:
		chest.on_chest_opened.disconnect(receive_chest_opened_callback)
