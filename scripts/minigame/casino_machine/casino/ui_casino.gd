class_name UI_Casino extends Control

static var Instance : UI_Casino

func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
		
func _show_casino_ui() -> void:
	pass
	
func _hide_casino_ui() -> void:
	pass
