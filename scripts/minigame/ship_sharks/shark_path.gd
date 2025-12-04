class_name Shark_Path extends Path2D

@export var shark : Shark
@export var followPath : PathFollow2D

@export var speed : float

var dir : int = 1

func _ready() -> void:
	followPath.progress_ratio = randf_range(0, 1)
	var randDir : int = randi_range(0, 1)
	if randDir == 1:
		dir = 1
	else:
		dir = -1
	
	
func _process(delta: float) -> void:
	followPath.progress += delta * speed * dir
	followPath.progress_ratio = clampf(followPath.progress_ratio, 0, 1)
	if followPath.progress_ratio >= 1:
		dir = -1
	elif followPath.progress_ratio <= 0:
		dir = 1
