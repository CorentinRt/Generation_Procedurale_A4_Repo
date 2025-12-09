@abstract class_name CharacterBase extends CharacterBody2D

signal life_changed(current_life : int)

enum ORIENTATION {FREE, DPAD_8, DPAD_4}
enum STATE {IDLE, ATTACKING, STUNNED, DEAD}

@export_group("Life")
@export var life : int = 3 :
	set(value) :
		life = value
		life_changed.emit(life)
@export var invincibility_duration : float = 1.0
@export var invincibility_blink_period : float = 0.2
@export var dead_color : Color = Color.GRAY
@export var sprites : Array[Sprite2D] = []
@export var invincibility_alpha : float = 0.7
@export var cannot_die : bool
@export var hit_decrease_score : bool

@export_group("Movement")
@export var default_movement : MovementParameters
@export var stunned_movemement : MovementParameters

@export_group("Attack")
@export var attack_scene : PackedScene
@export var attack_spawn_point : Node2D
@export var attack_cooldown : float = 0.3
@export var orientation : ORIENTATION = ORIENTATION.FREE
@export var attack_offset : float = 3

@export var kockback_strength = 50

var direction_attack : Vector2 = Vector2.ZERO

@export_group("Interact")
@export var interact_radius: float = 25.0

@export_group("Scores")
@export var _scores_datas : Scores_Datas

var npcs : Array[Node]
var simple_dialogs : Array[Node]
var item_quests : Array[Node]

var is_in_dialog: bool = false
var is_in_ship : bool = false
var is_in_casino : bool = false
var is_in_shop : bool = false

# Life
var _last_hit_time : float

# Movement
var _direction : Vector2
var _current_movement : MovementParameters

# Attack
var _last_attack_time : float
var _has_to_apply_knockback : bool
var _knockback_value : Vector2

# State
var _state : STATE = STATE.IDLE
var _is_blinking : bool

# Dungeon position
var _room #: Room

var knockback_time: float = 0.0

@onready var main_sprite : Sprite2D = $"BodySprite"

func _ready() -> void:
	# Get npcs & dialogs
	npcs = get_tree().get_nodes_in_group("NPC")
	simple_dialogs = get_tree().get_nodes_in_group("simple_dialog")
	call_deferred("get_item_quests")

func get_item_quests():
	item_quests = get_tree().get_nodes_in_group("item_quest")
	
func _process(delta: float) -> void:
	_update_state(delta)

func _physics_process(_delta: float) -> void:
	if _state == STATE.STUNNED:
		velocity = _knockback_value
		_knockback_value *= 0.95
		move_and_slide()
		return

	if _direction.length() > 0.000001:
		velocity += _direction * _current_movement.acceleration * get_physics_process_delta_time()
		velocity = velocity.limit_length(_current_movement.speed_max)
		#main_sprite.rotation = _compute_orientation_angle(_direction)
	else:
		## If direction length == 0, Apply friction
		var friction_length = _current_movement.friction * get_physics_process_delta_time()
		if velocity.length() > friction_length:
			velocity -= velocity.normalized() * friction_length
		else:
			velocity = Vector2.ZERO
	move_and_slide()
	for i in get_slide_collision_count():
		var collision : KinematicCollision2D = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Door:
			collider.try_unlock()


func apply_hit(attack : Attack) -> void:
	if Time.get_unix_time_from_system() - _last_hit_time < invincibility_duration:
		return
	_last_hit_time = Time.get_unix_time_from_system()

	if !cannot_die:
		life -= attack.damages if attack != null else 1
	
	if hit_decrease_score:
		if Player.Instance._has_bonus_attack_effect():
			ScoreManager._remove_score(_scores_datas._player_hit_with_bonus_defense)
		else:
			ScoreManager._remove_score(_scores_datas._player_hit)
		
	if life <= 0 and _state != STATE.DEAD:
		if !cannot_die:
			_set_state(STATE.DEAD)
	else:
		if attack != null && attack.knockback_duration > 0.0:
			apply_knockback(attack.knockback_duration, (position - attack.position).normalized() * attack.knockback_speed)
		_end_blink()
		blink()

func apply_knockback(duration : float, velocity : Vector2) -> void:
	if _state == STATE.STUNNED:
		return
	
	_set_state(STATE.STUNNED)
	
	_knockback_value = velocity
	knockback_time = duration
	
	await get_tree().create_timer(knockback_time).timeout.connect(reset_knockback)

func reset_knockback() -> void:
	_knockback_value = Vector2.ZERO
	_set_state(STATE.IDLE)

@abstract func _update_state(delta : float)


func _set_state(state : STATE) -> void:
	_state = state


func blink() -> void:
	_is_blinking = true
	var invincibility_timer : float = 0.0
	while invincibility_timer < invincibility_duration:
		if !_is_blinking or not is_inside_tree():
			return

		invincibility_timer += get_process_delta_time()
		var isVisible : bool = (int)(invincibility_timer/ invincibility_blink_period) % 2 == 1
		
		for sprite in sprites:
			if sprite == null or not is_instance_valid(sprite):
				continue
			if isVisible:
				sprite.self_modulate.a = 1
			else:
				sprite.self_modulate.a = invincibility_alpha
		
		if get_tree() != null:
			await get_tree().process_frame

	_end_blink()


func _end_blink() -> void:
	if !_is_blinking:
		return

	for sprite in sprites:
		sprite.visible = true

	_is_blinking = false


func _set_color(color : Color) -> void:
	for sprite in sprites:
		sprite.self_modulate = color


func _compute_orientation_angle(direction : Vector2) -> float:
	var angle = direction.angle()
	match orientation:
		ORIENTATION.DPAD_8:
			return Utils.DiscreteAngle(angle, 45)
		ORIENTATION.DPAD_4:
			return Utils.DiscreteAngle(angle, 90)
	return angle


func _attack() -> void:
	if (is_in_dialog || is_in_ship || is_in_casino || is_in_shop):
		return
	
	if Time.get_unix_time_from_system() - _last_attack_time < attack_cooldown:
		return

	_last_attack_time = Time.get_unix_time_from_system()
	_set_state(STATE.ATTACKING)


func _spawn_attack_scene() -> void:
	if attack_scene == null:
		return

	var spawn_position = attack_spawn_point.global_position if attack_spawn_point != null else global_position
	var spawn_rotation = attack_spawn_point.global_rotation if attack_spawn_point != null else global_rotation
	var spawned_attack = attack_scene.instantiate() as Attack
	var angle := _compute_orientation_angle(direction_attack)
	angle = angle + 90
	attack_spawn_point.add_child(spawned_attack)

	spawned_attack.rotation = angle
	spawned_attack.position = direction_attack.normalized() * attack_offset
	
	#get_tree().root.add_child(spawned_attack)
	#spawned_attack.global_position = spawn_position
	#spawned_attack.global_rotation = spawn_rotation
	spawned_attack.attack_owner = self

func _interact() -> void:
	if (is_in_dialog || is_in_ship || is_in_casino || is_in_shop): 
		return
	
	var player_pos: Vector2 = global_position
	
	if (item_quests.size() == 0):
		get_item_quests()
	
	# check items destroyed before interact
	for item in item_quests.duplicate():
		if not is_instance_valid(item):
			item_quests.erase(item)
			continue
		if item.global_position.distance_to(player_pos) <= interact_radius:
			if item.has_method("interact"):
				item.interact()
				return
	
	for npc in npcs:
		if npc.global_position.distance_to(player_pos) <= interact_radius:
			if npc.has_method("show_dialog"):
				npc.show_dialog()
				return 
				
	for s_d in simple_dialogs:
		if s_d.global_position.distance_to(player_pos) <= interact_radius:
			if s_d.has_method("show_dialog"):
				s_d.show_dialog()
				return 

func _can_move() -> bool:
	return !is_in_dialog && _state == STATE.IDLE && !is_in_ship && !is_in_casino && !is_in_shop

func set_is_in_dialog(in_dialog : bool):
	is_in_dialog = in_dialog
	
func _nextDialog():
	UtilsManager.get_dialog_manager()._on_dialog_pressed()
