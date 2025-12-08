class_name Casino_Reel extends Control

@export var symbols : Array[Texture2D]
@export var reel_speed : float = 800.0
@export var slow_down_time : float = 0.8
@export var total_spin_time : float = 2.0

var symbol_list: VBoxContainer
var final_symbol : int = 0

func _ready():
	symbol_list = $SymbolList
	
	# auto setup symbols
	for symbol in symbols:
		var tex = _create_symbol(symbol)
		symbol_list.add_child(tex)

	# double to create illusion of infinite scroll
	for symbol in symbols:
		var tex = _create_symbol(symbol)
		symbol_list.add_child(tex)

func _create_symbol(texture : Texture2D) -> TextureRect:
	var symbol : TextureRect = TextureRect.new()
	symbol.texture = texture
	symbol.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	symbol.custom_minimum_size = Vector2(128, 128)
	return symbol

func spin_to(symbol_index: int) -> void:
	final_symbol = symbol_index
	_spin()


func _spin() -> void:
	var elapsed : float = 0.0
	var start_speed : float = reel_speed

	while elapsed < total_spin_time:
		var dt = get_process_delta_time()

		# Slow Decrease
		#if elapsed > total_spin_time - slow_down_time:
		#	var t = clamp((elapsed - (total_spin_time - slow_down_time)) / slow_down_time, 0, 1)
		#	reel_speed = lerp(start_speed, 0.0, t)

		# Scroll
		symbol_list.position.y -= reel_speed * dt

		# Infinite loop
		if symbol_list.position.y < -symbol_list.size.y / 2:
			symbol_list.position.y += symbol_list.size.y / 2

		elapsed += dt
		await get_tree().process_frame

	# At the end -> snap to right pre-decided symbol
	_snap_to(final_symbol)


func _snap_to(index: int) -> void:
	var symbol_height : float = symbol_list.get_child(0).size.y
	symbol_list.position.y = -index * symbol_height
