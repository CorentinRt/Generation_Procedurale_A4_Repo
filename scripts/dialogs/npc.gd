extends Node2D

@export var dialog_data : JSON

func show_dialog():
	var dm = get_dialog_manager()
	if dm:
		print("Found dialog manager")
		dm.show_dialog(dialog_data)
	else:
		push_warning("Aucun DialogManager trouvé dans la scène !")

func get_dialog_manager():
	var managers = get_tree().get_nodes_in_group("dialog_manager")
	if managers.size() > 0:
		return managers[0]
	return null
