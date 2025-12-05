class_name Ship extends CharacterBody2D

@export var data : Ship_Data

@export var ship_player_anchor : Node2D

var player_is_near : bool = false

var player_is_in : bool = false

var associated_player : Player

func _process(delta: float) -> void:
	_update_inputs_interact()
	_update_clamp_player_to_anchor()
	
func _physics_process(delta: float) -> void:
	_update_inputs_movements(delta)
		
func _update_inputs_interact() -> void:
	if Input.is_action_just_pressed("Interact"):
		if player_is_in:
			if associated_player != null:
				if place_player_outside_collision(associated_player.global_position):
					associated_player.exit_ship(self)  
		elif player_is_near:
			Player.Instance.enter_ship(self)
		
func _update_inputs_movements(delta : float) -> void:
	if player_is_in:
		var dir = Input.get_vector("Left", "Right", "Up", "Down")
		if dir.length() > 0:
			velocity = dir * data.speed
		else:
			velocity *= 0.5
			if velocity.length() < 1:
				velocity = Vector2.ZERO
		move_and_slide()
	else:
		velocity = Vector2.ZERO
				
func _update_clamp_player_to_anchor() -> void:
	if !player_is_in:
		return
	if player_is_in && associated_player == null:
		Player.Instance.exit_ship(self)
		call_deferred("_set_player_out", Player.Instance)
		return
	associated_player.global_position = ship_player_anchor.global_position
		
				
func _set_player_in(player: Player) -> void:
	player_is_in = true
	associated_player = player
	
func _set_player_out(player : Player) -> void:
	player_is_in = false
	associated_player = null
	player_is_near = false
	
func place_player_outside_collision(start_pos: Vector2, radius : int = 22.0, steps : int = 30) -> bool:
	var space_state = get_world_2d().direct_space_state

	var collision_shape : CollisionShape2D = associated_player._get_shape()

	var params : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = collision_shape.shape
	params.collision_mask = associated_player.collision_mask

	for i in range(steps):
		var angle = (TAU / steps) * i
		var pos = start_pos + Vector2(cos(angle), sin(angle)) * radius
		
		params.transform = Transform2D(0, pos)
		
		var result = space_state.intersect_shape(params, 1)
		if result.is_empty():
			print("set position")
			associated_player.global_position = pos
			return true
	return false


func _on_enter_area_body_entered(body: Node2D) -> void:
	if player_is_near || body is Player:
		player_is_near = true


func _on_enter_area_body_exited(body: Node2D) -> void:
	if !player_is_near || body is Player:
		player_is_near = false


func _on_damage_area_area_entered(area: Area2D) -> void:
	if area is Shark:
		if associated_player != null:
			associated_player.apply_hit(null)


func _on_damage_area_area_exited(area: Area2D) -> void:
	pass
