class_name AudioManager
extends Node

static var Instance : AudioManager

@export_group("Sounds")
@export var sounds: Array[SoundData]

var looping_sounds : Dictionary[String, AudioStreamPlayer]

var volume_tweens : Dictionary[String, Tween]

@export_group("Dialog")
@export var dialog_beep: SoundData
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
		beep_player.stream = dialog_beep.audiostream
		beep_player.volume_db = dialog_beep.volume_db
		beep_player.pitch_scale = randf_range(0.9, 1.3)
		beep_player.play()
		
func play_sound(sound_name : String):
	var sound_data: SoundData = get_sound_data_from_sound_name(sound_name)
	if sound_data == null:
		return
		
	if sound_data.looping && looping_sounds.has(sound_data.sound_name):
		return
		
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound_data.audiostream
	player.volume_db = sound_data.volume_db
	player.play()

	if sound_data.looping:
		looping_sounds[sound_data.sound_name] = player
		return
	# Delete player after sound
	player.finished.connect(func():
		player.queue_free()
	)
	
func get_sound_data_from_sound_name(sound_name : String) -> SoundData:
	for sound_data in sounds:
		if sound_data.sound_name == sound_name:
			return sound_data
			
	return null

func stop_sound_with_name(sound_name : String) -> void:
	var sound : AudioStreamPlayer = looping_sounds.find_key(sound_name)
	if sound != null:
		looping_sounds.erase(sound_name)
		sound.stop()
		sound.queue_free()
		
func set_volume_with_name(sound_name : String, volume : float, duration : float = 0) -> void:
	if !looping_sounds.has(sound_name):
		return
	var sound : AudioStreamPlayer = looping_sounds[sound_name]
	if sound == null:
		return
		
	if duration <= 0:
		sound.volume_db = volume
		
	# get already existing tween for this sound -> rease it
	if volume_tweens.has(sound_name) && volume_tweens[sound_name] != null:
		var old_tween : Tween = volume_tweens[sound_name]
		if old_tween.is_valid():
			old_tween.kill()
		volume_tweens.erase(sound_name)
		
	var tween : Tween = create_tween()
	tween.tween_property(sound, "volume_db", volume, duration)
	volume_tweens[sound_name] = tween

	#when finished -> out of dictionary
	tween.finished.connect(func():
		volume_tweens.erase(sound_name))
