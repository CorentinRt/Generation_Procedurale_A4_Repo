class_name CustomTimer extends Node

@export var timer_label : Label
@export var timer_slider: HSlider
@export var timer : Timer
@export var smoothing_speed : float = 50.0

signal timer_finished

var total_time := 0.0
var displayed_value := 0.0
var is_counting: bool = false

func show_and_start_timer(time : float):
	total_time = time
	displayed_value = 0
	
	timer.wait_time = time
	
	if timer_label:
		timer_label.show()
		
	if timer_slider:
		timer_slider.show()
		timer_slider.max_value = time
		timer_slider.min_value = 0
		timer_slider.value = 0
		
	timer.start()
	is_counting = true
	
func hide_and_stop_timer():
	timer.stop()
	hide_timer()
	
func hide_timer():
	if timer_label:
		timer_label.hide()
	if timer_slider:
		timer_slider.hide()
		
	is_counting = false
	
func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if not is_counting:
		return

	var elapsed := total_time - timer.time_left  # 0 -> time
	displayed_value = move_toward(displayed_value, elapsed, smoothing_speed * delta)

	if timer_label:
		var smooth_time_left := total_time - displayed_value
		timer_label.text = String.num(smooth_time_left, 1)

	if timer_slider:
		timer_slider.value = displayed_value
		
func _on_timer_timeout():
	emit_signal("timer_finished")
	hide_and_stop_timer()
	
