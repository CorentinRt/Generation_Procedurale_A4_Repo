class_name Minigame_Box_Interruptor extends Room_Minigame

var _box : Box_Item

var _interruptor : Interruptor_Item


func _setup_minigame() -> void:
	super()
	for child in get_parent().get_children():
		if _box == null && child is Box_Item:
			_box = child
			continue
		if _interruptor == null && child is Interruptor_Item:
			_interruptor = child
			continue
			
	_interruptor.on_interruptor_activated.connect(receive_interruptor_activated_callback)
	
	
func receive_interruptor_activated_callback() -> void:
	_set_state(MINIGAME_STATE.COMPLETED)
	_interruptor.on_interruptor_activated.disconnect(receive_interruptor_activated_callback)
