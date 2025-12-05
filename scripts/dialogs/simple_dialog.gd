class_name SimpleDialog extends Node2D

@export var dialog_type: SimpleDialogType
@export var can_be_interacted_more_than_one: bool = false
var dialog_text: String = ""
var has_been_interacted: bool = false

enum SimpleDialogType{
	SKULL,
	LETTER
}

func _ready() -> void:
	add_to_group("simple_dialog")

func setup_text(text : String): 
	dialog_text = text

func can_be_interacted() -> bool:
	if !can_be_interacted_more_than_one && has_been_interacted:
		return false
	return true

func interact():
	if !can_be_interacted():
		return
		
	# show simple dialog with text
	
