@abstract class_name Room_Minigame extends Node

var _is_completed : bool = false

func _setup_minigame() -> void:
	pass
	
	
func _minigame_completed() -> void:
	if _is_completed:
		pass
	_is_completed = true
	_unlock_doors()
	
	
func _unlock_doors() -> void:
	pass
	

func _lock_doors() -> void:
	pass
	
