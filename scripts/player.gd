class_name Player extends CharacterBase

static var Instance : Player

@export var impulse_force : float = 5

@export_group("Input")
@export_range (0.0, 1.0) var controller_dead_zone : float = 0.3

@export_group("Animation")
@export var animation_player : AnimationPlayer

# Collectible
var key_count : int


func _init() -> void:
	Instance = self


func _ready() -> void:
	super()
	_set_state(STATE.IDLE)


func _process(delta: float) -> void:
	super(delta)
	_update_inputs()
	_update_room()
	_update_anim()

func _update_anim() -> void:
	if velocity.length() <= 0.3:
		if animation_player.current_animation != "idle":
			animation_player.play("idle", 0.3)
	else:
		if animation_player.current_animation != "run":
			animation_player.play("run")
		

func _physics_process(_delta: float) -> void:
	super(_delta)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var rb = collision.get_collider()
		if rb is RigidBody2D:
			var dir : Vector2
			dir = rb.global_position - global_position
			rb.apply_central_impulse(dir.normalized() * impulse_force)
			
func apply_hit(attack : Attack) -> void:
	super(attack)
	animation_player.play("hit")

func enter_room(room : Room) -> void:
	var previous = _room
	_room = room
	_room.on_enter_room(previous)


func _update_room() -> void:
	var room_bounds : Rect2 = _room.get_world_bounds()
	var next_room : Room = null
	if position.x > room_bounds.end.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.EAST, position)
	elif position.x < room_bounds.position.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.WEST, position)
	elif position.y < room_bounds.position.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.NORTH, position)
	elif position.y > room_bounds.end.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.SOUTH, position)

	if next_room != null:
		enter_room(next_room)


func _update_inputs() -> void:
	if _can_move():
		_direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
		if _direction.length() < controller_dead_zone:
			_direction = Vector2.ZERO
		else:
			_direction = _direction.normalized()

		if Input.is_action_pressed("Attack"):
			_attack()
			
		if Input.is_action_just_pressed("Interact"):
			_interact()
			
	else:
		_direction = Vector2.ZERO
		
		if Input.is_action_just_pressed("NextDialog"):
			_nextDialog()


func _set_state(state : STATE) -> void:
	if state == STATE.DEAD and _state == STATE.DEAD:
		return
	super(state)
	match _state:
		STATE.STUNNED:
			_current_movement = stunned_movemement
		STATE.DEAD:
			_end_blink()
			_set_color(dead_color)
			GameManager._reload_game_scene(1.5)
		_:
			_current_movement = default_movement

	if !_can_move():
		_direction = Vector2.ZERO


func _update_state(_delta : float) -> void:
	match _state:
		STATE.ATTACKING:
			_spawn_attack_scene()
			_set_state(STATE.IDLE)
