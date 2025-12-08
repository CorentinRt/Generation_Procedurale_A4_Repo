class_name SimpleDialog extends Node2D

@export var dialog_type: SimpleDialogType
@export var can_be_interacted_more_than_once: bool = false
@export var interact_icon: Sprite2D

var dialog_text: String = ""
var dialog_color: Color
var has_been_interacted: bool = false

enum SimpleDialogType{
	SKULL,
	LETTER
}
	
func _process(_delta: float) -> void:
	_show_player_interact_indication()
	
func _show_player_interact_indication():
	var player_pos = Player.Instance.global_position
	var interact_radius = Player.Instance.interact_radius
	
	if global_position.distance_to(player_pos) <= interact_radius && can_be_interacted():
		interact_icon.show()
	else:
		interact_icon.hide()

func setup(text : String, color : Color): 
	print("Setup skull : ", text)
	dialog_text = text
	dialog_color = color

func can_be_interacted() -> bool:
	if !can_be_interacted_more_than_once && has_been_interacted:
		return false
	return true

func show_dialog():
	print("show simple dialog")
	if can_be_interacted():
		UtilsManager.get_dialog_manager().start_simple_dialog(dialog_text, dialog_color)
		has_been_interacted = true
