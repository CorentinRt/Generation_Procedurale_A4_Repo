class_name Chest_Item extends StaticBody2D

@export_group("Sprites")
@export var closed_sprite : Sprite2D
@export var open_sprite : Sprite2D

var is_open : bool = false

var player_is_near : bool = false

signal on_chest_opened()

func _ready() -> void:
	_close_chest()

func _process(delta: float) -> void:
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
		
func _close_chest() -> void:
	if !is_open:
		return
	is_open = false
	_update_chest_visuals()
	

func _update_chest_visuals() -> void:
	open_sprite.visible = is_open
	closed_sprite.visible = !is_open


func _on_area_2d_body_entered(body: Node2D) -> void:
	if player_is_near:
		return
	if body is Player:
		player_is_near = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if !player_is_near:
		return
	if body is Player:
		player_is_near = false
