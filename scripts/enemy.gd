class_name Enemy extends CharacterBase

static var all_enemies : Array[Enemy]

signal on_killed();

@export var attack_warm_up : float = 0.5
@export var attack_distance : float = 0.5

@export var _scores_datas : Scores_Datas

@export_group("Animation")
@export var running_animation_player : AnimationPlayer
@export var hit_animation_player : AnimationPlayer

var _state_timer : float = 0.0


func _ready() -> void:
	all_enemies.push_back(self)
	for room in Room.all_rooms:
		if room.contains(global_position):
			_room = room
			break
	_set_state(STATE.IDLE)


func _process(delta: float) -> void:
	super(delta)
	update_AI()
	_update_anim()


func _exit_tree() -> void:
	all_enemies.erase(self)

func _update_anim() -> void:
	if velocity.length() <= 0.3:
		if running_animation_player.current_animation != "idle":
			running_animation_player.play("idle", 0.3)
	else:
		if running_animation_player.current_animation != "run":
			running_animation_player.play("run")

func apply_hit(attack : Attack) -> void:
	super(attack)
	hit_animation_player.play("hit")

func update_AI() -> void:
	_update_attack_direction()
	if _can_move() && Player.Instance._room == _room:
		var enemy_to_player = Player.Instance.global_position - global_position
		if enemy_to_player.length() < attack_distance:
			_attack()
		else:
			_direction = enemy_to_player.normalized()
	else:
		_direction = Vector2.ZERO

func _update_attack_direction() -> void:
	var enemy_to_player = Player.Instance.global_position - global_position
	direction_attack = enemy_to_player.normalized()
	

func _set_state(state : STATE) -> void:
	var oldState : STATE = _state
	super(state)
	_state_timer = 0.0

	match _state:
		STATE.STUNNED:
			_current_movement = stunned_movemement
		STATE.DEAD:
			if oldState != state:
				_end_blink()
				queue_free()
				_give_score()
				GameManager._notify_kill_enemy()
				on_killed.emit()
		_:
			_current_movement = default_movement

	if !_can_move():
		_direction = Vector2.ZERO

func _give_score() -> void:
	ScoreManager._add_score(_scores_datas._enemy_death)

func _update_state(delta : float) -> void:
	_state_timer += delta
	match _state:
		STATE.ATTACKING:
			if _state_timer >= attack_warm_up:
				_spawn_attack_scene()
				_set_state(STATE.IDLE)
