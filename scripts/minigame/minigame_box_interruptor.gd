class_name Minigame_Box_Interruptor extends Room_Minigame

var _box : Box_Item

var _interruptor : Interruptor_Item

func _setup_minigame() -> void:
	super()
	
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("item_minigame"):
			continue
			
		if _box == null && i is Box_Item:
			_box = i
		elif _interruptor == null && i is Interruptor_Item:
			_interruptor = i
			
	_interruptor.on_interruptor_activated.connect(receive_interruptor_activated_callback)
	
	
func receive_interruptor_activated_callback() -> void:
	_set_state(MINIGAME_STATE.COMPLETED)
	_interruptor.on_interruptor_activated.disconnect(receive_interruptor_activated_callback)
