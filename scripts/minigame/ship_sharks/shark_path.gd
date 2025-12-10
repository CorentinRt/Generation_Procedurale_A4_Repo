class_name Shark_Path extends Path2D

@export var shark : Shark
@export var followPath : PathFollow2D

@export var speed : float

var dir : int = 1

var looping : bool = false

func _ready() -> void:
	followPath.progress_ratio = randf_range(0, 1)
	
	if looping:
		dir = 1
		return
	
	dir = randi_range(0, 1)
	if dir == 0:
		dir = -1
	
	
func _process(delta: float) -> void:
	followPath.progress += delta * speed * dir
	
	if looping:
		return
		
	followPath.progress_ratio = clampf(followPath.progress_ratio, 0, 1)
	if followPath.progress_ratio >= 1:
		dir = -1
	elif followPath.progress_ratio <= 0:
		dir = 1
