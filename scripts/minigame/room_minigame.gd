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

@export var _room_zone_detector : Room_Zone_Detector

@export var _scores_datas : Scores_Datas

@onready var propsTileMapLayer : TileMapLayer = $"../Props"

func _ready() -> void:
	call_deferred("_setup_minigame")

func _process(delta: float) -> void:
	if _state != MINIGAME_STATE.RUNNING:
		return
		
	if _check_completed_condition():
		_set_state(MINIGAME_STATE.COMPLETED)
	elif Input.is_key_pressed(KEY_L):
		_set_state(MINIGAME_STATE.COMPLETED)
	
func _check_completed_condition() -> bool:
	if _state == MINIGAME_STATE.COMPLETED:
		return true	# in case some mini game has no continuous check condition and force it to completed
	return false

func _setup_minigame() -> void:
	for i in propsTileMapLayer.get_children():
		if i is Door:
			_doors.append(i)
			
	_room_zone_detector._on_player_enters.connect(_receive_on_enter_room_zone_callback)
	_room_zone_detector._on_player_exits.connect(_receive_on_exit_room_zone_callback)
	_set_state(MINIGAME_STATE.NOT_STARTED)
	
func _receive_on_enter_room_zone_callback() -> void:
	if _state == MINIGAME_STATE.NOT_STARTED:
		_set_state(MINIGAME_STATE.RUNNING)
		
func _receive_on_exit_room_zone_callback() -> void:
	pass
	
func _minigame_not_started() -> void:
	_unlock_doors()
	
func _minigame_running() -> void:
	_lock_doors()
	
func _minigame_completed() -> void:
	_unlock_doors()
	ScoreManager._add_score(_scores_datas._minigame_completed)
	
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
	
