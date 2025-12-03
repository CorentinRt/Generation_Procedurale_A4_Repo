class_name Interruptor_Item extends Area2D

@export var time_to_activate : float = 3
@export var interruptor_sprite : Sprite2D

var box_in_interruptor : bool = false

var current_time_activating = 0

var activated : bool

signal on_interruptor_activated()

func _on_body_entered(body: Node2D) -> void:
	box_in_interruptor = true
	if activated:
		return
	interruptor_sprite.modulate = Color.BLUE


func _on_body_exited(body: Node2D) -> void:
	box_in_interruptor = false
	if activated :
		return
	current_time_activating = 0
	interruptor_sprite.modulate = Color.RED

func _process(delta: float) -> void:
	if activated || !box_in_interruptor:
		return
	current_time_activating += delta
	if current_time_activating >= time_to_activate:
		_activate_interruptor()
	
func _activate_interruptor() -> void:
	if activated:
		return
	activated = true
	interruptor_sprite.modulate = Color.GREEN
	on_interruptor_activated.emit()
