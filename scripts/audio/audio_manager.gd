class_name AudioManager
extends Node

static var Instance : AudioManager

@export_group("Dialog")
@export var dialog_beep: AudioStream
@export var beep_player: AudioStreamPlayer
@export var beep_interval := 0.07   

var beep_cooldown := 0.0

func _enter_tree() -> void:
	Instance = self

func _process(delta):
	if beep_cooldown > 0:
		beep_cooldown -= delta

func play_dialog_beep():
	# empêche le spam
	if beep_cooldown > 0:
		return
	
	beep_cooldown = beep_interval
	
	if beep_player and dialog_beep:
		beep_player.stream = dialog_beep
		beep_player.pitch_scale = randf_range(0.9, 1.3)
		beep_player.play()
