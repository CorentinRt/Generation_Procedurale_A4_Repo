@abstract class_name Room_Minigame extends Node

enum MINIGAME_STATE
{
	NONE = 0,
	NOT_STARTED = 1,
	RUNNING = 2,
	COMPLETED = 3
}

var _state : MINIGAME_STATE = MINIGAME_STATE.NONE

var _doors : Array[Door]

func _ready() -> void:
	call_deferred("_setup_minigame")

func _setup_minigame() -> void:
	for child in get_node("../Props").get_children():
		if child is Door:
			_doors.append(child)
			
	_set_state(MINIGAME_STATE.NOT_STARTED)
	
	var parent : Node = get_parent()
	if parent is Room:
		parent.on_enter_room_event.connect(_receive_on_enter_room_callback)
	
func _receive_on_enter_room_callback() -> void:
	if _state == MINIGAME_STATE.NOT_STARTED:
		_set_state(MINIGAME_STATE.RUNNING)
	
func _minigame_not_started() -> void:
	_unlock_doors()
	
func _minigame_running() -> void:
	_lock_doors()
	
func _minigame_completed() -> void:
	_unlock_doors()
	
func _set_state(state: MINIGAME_STATE) -> void:
	if _state == state:
		return

	_state = state
	
	match state:
		MINIGAME_STATE.NOT_STARTED:
			_minigame_not_started()
			
		MINIGAME_STATE.RUNNING:
			_minigame_running()
			
		MINIGAME_STATE.COMPLETED:
			_minigame_completed()
		
	
func _unlock_doors() -> void:
	for door in _doors:
		door.force_unlock()

func _lock_doors() -> void:
	for door in _doors:
		door.force_lock()
	
