class_name Minigame_Box_Interruptor extends Room_Minigame

var _box : Node

var _interruptor : Node


func _setup_minigame() -> void:
	super()
	for child in get_node("../Props").get_children():
		if _box == null && child is Box_Item:
			_box = child
			continue
		if _interruptor == null && child is Interruptor_Item:
			_interruptor = child
			continue
	
		
	
	
