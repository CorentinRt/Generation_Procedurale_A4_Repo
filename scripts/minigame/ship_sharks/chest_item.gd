class_name Chest_Item extends StaticBody2D

@export_group("Sprites")
@export var closed_sprite : Sprite2D
@export var open_sprite : Sprite2D
@export var interaction_sprite : Sprite2D

var is_open : bool = false

var player_is_near : bool = false

var can_interact : bool = true

signal on_chest_opened()

func _ready() -> void:
	_close_chest()
	interaction_sprite.hide()

func _process(delta: float) -> void:
	if !visible:
		return
	if player_is_near && Input.is_action_just_pressed("Interact"):
		_interact()
		
func _interact() -> void:
	_open_chest()

func _open_chest() -> void:
	if is_open:
		return
	is_open = true
	_update_chest_visuals()
	on_chest_opened.emit()
	can_interact = false
	interaction_sprite.hide()
	AudioManager.Instance.play_sound("open_chest")
		
func _close_chest() -> void:
	if !is_open:
		return
	is_open = false
	_update_chest_visuals()
	can_interact = true
	

func _update_chest_visuals() -> void:
	open_sprite.visible = is_open
	closed_sprite.visible = !is_open


func _on_area_2d_body_entered(body: Node2D) -> void:
	if player_is_near:
		return
	if body is Player:
		player_is_near = true
		if can_interact:
			interaction_sprite.show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if !player_is_near:
		return
	if body is Player:
		interaction_sprite.hide()
		player_is_near = false
