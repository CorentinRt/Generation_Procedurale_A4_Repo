class_name Minigame_Battle extends Room_Minigame

var enemies : Array[Enemy]

var enemy_killed : int = -1

func _setup_minigame() -> void:
	super()
	
	for i in propsTileMapLayer.get_children():
		if !i.is_in_group("enemy"):
			continue
		
		enemies.append(i)
		
	for i in enemies:
		i.on_killed.connect(receive_interruptor_activated_callback)
		
	enemy_killed = 0
		
		
func receive_interruptor_activated_callback() -> void:
	enemy_killed += 1		

func _check_completed_condition() -> bool:
	if _state == MINIGAME_STATE.RUNNING:
		if enemy_killed < 0:
			return false
			
		if enemy_killed >= enemies.size():
			return true
			
	return false
