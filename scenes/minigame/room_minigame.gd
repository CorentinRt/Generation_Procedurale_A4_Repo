@abstract class_name Room_Minigame extends Node

var _is_completed : bool = false

var _doors : Array[Door]

func _ready() -> void:
	call_deferred("_setup_minigame")

func _setup_minigame() -> void:
	for child in get_node("../Props").get_children():
		if child is Door:
			_doors.append(child)
			
	_unlock_doors()
	
	
func _minigame_completed() -> void:
	if _is_completed:
		pass
	_is_completed = true
	_unlock_doors()
	
	
func _unlock_doors() -> void:
	for door in _doors:
		door.force_unlock()
	

func _lock_doors() -> void:
	for door in _doors:
		door.force_lock()
	
