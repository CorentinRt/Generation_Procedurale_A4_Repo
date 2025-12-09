@abstract class_name Room_Minigame extends Node

enum MINIGAME_STATE
{
	NONE = 0,
	NOT_STARTED = 1,
	RUNNING = 2,
	COMPLETED = 3
}

enum DIRECTION_ROOM
{
	NONE = 0,
	EAST = 1,
	WEST = 2,
	NORTH = 3,
	SOUTH = 4
}

var _state : MINIGAME_STATE = MINIGAME_STATE.NONE

var _doors : Array[Door]

var _first_direction_player_entered : DIRECTION_ROOM = DIRECTION_ROOM.NONE

@export var _room_zone_detector : Room_Zone_Detector

@export var _scores_datas : Scores_Datas

@onready var propsTileMapLayer : TileMapLayer = $"../Props"

var _score : int

func _ready() -> void:
	_score = _scores_datas._minigame_completed_default
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
	
func _receive_on_enter_room_zone_callback(player_pos : Vector2) -> void:
	
	if _first_direction_player_entered == DIRECTION_ROOM.NONE:
		_first_direction_player_entered = _compute_player_enters_direction(player_pos)
	
	if _state == MINIGAME_STATE.NOT_STARTED:
		_set_state(MINIGAME_STATE.RUNNING)
		
func _receive_on_exit_room_zone_callback(player_pos : Vector2) -> void:
	pass
	
	
func _compute_player_enters_direction(pos : Vector2) -> DIRECTION_ROOM:
	var dir : Vector2 = pos - _room_zone_detector.global_position
	dir = dir.normalized()
	
	if (absf(dir.y) > absf(dir.x)):
		if dir.y > 0:
			return DIRECTION_ROOM.SOUTH
		else:
			return DIRECTION_ROOM.NORTH
	else:
		if dir.x > 0:
			return DIRECTION_ROOM.EAST
		else:
			return DIRECTION_ROOM.WEST
			
	
func _minigame_not_started() -> void:
	_unlock_doors()
	
func _minigame_running() -> void:
	_lock_doors()
	
func _minigame_completed() -> void:
	_unlock_doors()
	ScoreManager._add_score(_score)
	
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
	
