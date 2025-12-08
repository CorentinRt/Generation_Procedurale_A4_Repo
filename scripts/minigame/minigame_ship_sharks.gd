class_name Minigame_Ship_Sharks extends Room_Minigame

var sharks_paths : Array[Shark_Path]

var chest : Chest_Item

func _setup_minigame() -> void:
	super()
	_score = _scores_datas._minigame_completed_ship_sharks
	for i in get_parent().get_children():
		if i is Shark_Path:
			sharks_paths.append(i)
			
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("item_minigame"):
			continue
			
		if chest == null && i is Chest_Item:
			chest = i
			break
	
	chest.on_chest_opened.connect(receive_chest_opened_callback)
			
func receive_chest_opened_callback() -> void:
	_set_state(MINIGAME_STATE.COMPLETED)
	chest.on_chest_opened.disconnect(receive_chest_opened_callback)
