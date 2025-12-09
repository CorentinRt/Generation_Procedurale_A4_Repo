class_name Shop extends Area2D

@export var interaction_sprite : Sprite2D

var player_is_near : bool

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if player_is_near && Input.is_action_just_pressed("Interact"):
		_interact()
		
func _on_shop_body_entered(body: Node2D) -> void:
	if !player_is_near && body is Player:
		player_is_near = true
		interaction_sprite.show()


func _on_shop_body_exited(body: Node2D) -> void:
	if player_is_near && body is Player:
		player_is_near = false
		interaction_sprite.hide()
		
func _interact() -> void:
	if Player.Instance.is_in_shop:
		return
	_open_shop_display()

func _open_shop_display() -> void:
	Shop_UI.Instance._show_shop_ui()
	Player.Instance.is_in_shop = true
	
func _close_shop_display() -> void:
	Shop_UI.Instance._hide_shop_ui()
	Player.Instance.is_in_shop = false
