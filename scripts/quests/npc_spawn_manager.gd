extends Node2D

enum NpcType{
	COMBAT,
	QUESTION,
	ADD_SCORE,
	ITEM
}

var npc_combat: NpcSpawnData = preload("res://resources/npc_spawn/nsd_combat.tres")
var npc_question: NpcSpawnData = preload("res://resources/npc_spawn/nsd_question.tres")
var npc_add_score: NpcSpawnData = preload("res://resources/npc_spawn/nsd_add_score.tres")
var npc_item: NpcSpawnData = preload("res://resources/npc_spawn/nsd_item.tres")

var npc_data_list: Array[NpcSpawnData] = [npc_combat, npc_question, npc_add_score, npc_item]

var containers: Array[NpcContainer] = []

var current_spawns := {
	NpcType.COMBAT: 0,
	NpcType.QUESTION: 0,
	NpcType.ADD_SCORE: 0,
	NpcType.ITEM: 0
}

var spawn_probability: float = .5

func _ready() -> void:
	init_npcs() # a mettre apres la gen du monde
	
func init_npcs():	# appelé lors du load de la scene de jeu dans GameManager
	containers.clear()
	get_spawn_containers()
	spawn_npcs()
	
func get_spawn_containers():
	for node in get_tree().get_nodes_in_group("npc_container"):
		if node is NpcContainer:
			containers.append(node)
	
	print("found npc container : ", containers.size())

func spawn_npcs():
	# If spawn proba
	if randf() > spawn_probability:
		print("cant spawn npc with spawn proba")
		return  

	# Get random npc
	var roll = randf()
	var cumulative = 0.0
	var selected: NpcSpawnData = null

	for data in npc_data_list:
		cumulative += data.spawn_proba
		if roll <= cumulative:
			selected = data
			break

	if selected == null:
		return

	# Check npc max spawn
	if current_spawns[selected.npc_type] >= selected.max_spawn:
		return

	# Get random container
	if containers.size() == 0:
		return

	var container = containers[randi() % containers.size()]
	
	# Spawn npc
	var npc = selected.prefab.instantiate()
	container.add_child(npc)

	current_spawns[selected.npc_type] += 1
	containers.erase(container) # container cant be used
