class_name CustomTimer extends Node

@export var timer_label : Label
@export var timer : Timer

signal timer_finished

var is_counting: bool = false

func show_and_start_timer(time : float):
	timer_label.show()
	timer.wait_time = time
	timer.start()
	is_counting = true
	
func hide_and_stop_timer():
	timer.stop()
	hide_timer()
	
func hide_timer():
	timer_label.hide()
	is_counting = false
	
func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	if is_counting:
		timer_label.text = String.num(timer.time_left, 1)
		
func _on_timer_timeout():
	emit_signal("timer_finished")
	hide_timer()
	
