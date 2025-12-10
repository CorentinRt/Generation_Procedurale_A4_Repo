class_name Transition_Screen_UI extends Control

@export var block_inputs : Control

@export var black_screen_fade : TextureRect

@export var black_screen_color : Color

@export var fade_duration : float = 2

var black_fade_tween : Tween

func _ready() -> void:
	black_screen_fade.visible = true
	black_screen_fade.modulate = black_screen_color
	block_inputs.visible = false
	_set_active_fade_black(true)

func _set_block_inputs_active(value : bool) -> void:
	block_inputs.visible = value
	
func _set_active_fade_black(fade_in : bool) -> void:
	if black_fade_tween != null && black_fade_tween.is_running():
		black_fade_tween.kill()
		
	black_fade_tween = create_tween()
	
	if fade_in:
		black_fade_tween.tween_property(black_screen_fade, 
			"modulate", 
			Color.TRANSPARENT, 
			fade_duration)
	else:
		black_fade_tween.tween_property(black_screen_fade, 
			"modulate",
			black_screen_color,
			fade_duration)
