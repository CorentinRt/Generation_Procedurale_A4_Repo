extends Node

func get_dialog_manager():
	var managers = get_tree().get_nodes_in_group("dialog_manager")
	if managers.size() > 0:
		return managers[0]
	else:
		print("didn't find dialog manager")
	return null
