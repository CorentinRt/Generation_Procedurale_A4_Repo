class_name Player extends CharacterBase

static var Instance : Player

@export var impulse_force : float = 5

@export var collision_shape : CollisionShape2D

@export_group("Input")
@export_range (0.0, 1.0) var controller_dead_zone : float = 0.3

@export_group("Animation")
@export var running_animation_player : AnimationPlayer
@export var hit_animation_player : AnimationPlayer

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
		if running_animation_player.current_animation != "idle":
			running_animation_player.play("idle", 0.3)
	else:
		if running_animation_player.current_animation != "run":
			running_animation_player.play("run")
		

func _physics_process(_delta: float) -> void:
	super(_delta)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var rb = collision.get_collider()
		if rb is RigidBody2D:
			var dir : Vector2
			dir = rb.global_position - global_position
			rb.apply_central_impulse(dir.normalized() * impulse_force)
			
func _get_shape() -> CollisionShape2D:
	return collision_shape
			
func apply_hit(attack : Attack) -> void:
	super(attack)
	hit_animation_player.play("hit")

func enter_room(room : Room) -> void:
	var previous = _room
	_room = room
	_room.on_enter_room(previous)

#region Ship Enter/Exit
func enter_ship(ship : Ship) -> void:
	if _state == STATE.DEAD || !_can_move() || ship == null:
		return
	is_in_ship = true
	ship._set_player_in(self)
	collision_shape.disabled = true
	
func exit_ship(ship : Ship) -> void:
	if _state == STATE.DEAD || ship == null:
		return
	is_in_ship = false
	ship._set_player_out(self)
	collision_shape.disabled = false
#endregion

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
	direction_attack = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
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
