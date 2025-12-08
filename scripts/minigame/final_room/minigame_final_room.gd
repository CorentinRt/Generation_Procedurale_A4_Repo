class_name Minigame_Final_Room extends Room_Minigame

var chest : Chest_Item

func _setup_minigame() -> void:
	super()
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
	GameManager._notify_open_final_chest()
