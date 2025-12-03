class_name LevelGeneration extends Node2D

@export_group("Starting room")
@export var _startingRoom:PackedScene
var _startingRoomDirections:Array[LevelGenerationUtils.Directions]

@export_group("Other rooms base")
@export var _randomRoomBase:PackedScene

@export_group("Generation parameters")
@export var _roomsMaxCount:int
@export var _maxLevelHeight:int
@export var _maxLevelWidth:int
@export var _roomSize:Vector2i

var _roomsWithAvailableDoors:Array[Node2D]
var _currentRoom:Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		var startingRoomInstance:Node2D = _startingRoom.instantiate()
		add_child(startingRoomInstance)
		_startingRoomDirections = startingRoomInstance.directions.duplicate()
		
		_currentRoom = startingRoomInstance
		var currentRoomPossibleDirs:Array[LevelGenerationUtils.Directions] = startingRoomInstance.directions
				
		#Créer toujours au moins une salle pour chaque direction de la salle de départ
		for i in range(_startingRoomDirections.size()):
			_create_room(_startingRoomDirections[i], false)
			_roomsMaxCount -= 1
		
		for i in _roomsMaxCount:
			var randDir:LevelGenerationUtils.Directions = _random_dir(currentRoomPossibleDirs)
			_create_room(randDir, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _random_dir(dirList:Array) -> LevelGenerationUtils.Directions:
	var dir:LevelGenerationUtils.Directions = dirList[randi() % dirList.size()] as LevelGenerationUtils.Directions
	return dir

func _create_room(creationDir:LevelGenerationUtils.Directions, updateCurrentRoom:bool) -> Node2D:
	#On créer la room et on l'ajoute a la hiérarchie
	var createdRoom:Node2D = _randomRoomBase.instantiate()
	add_child(createdRoom)		
	
	#On positionne la room créée en fonction de la direction que l'on a et on supprime les directions utilisées par chaque room
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			print("North")
			createdRoom.position += Vector2(_currentRoom.position.x, _currentRoom.position.y - _roomSize.y)
			createdRoom.coordinates.y = _currentRoom.coordinates.y - 1
			
			createdRoom.directions.erase(LevelGenerationUtils.Directions.SOUTH)
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.NORTH)
	
		LevelGenerationUtils.Directions.SOUTH:
			print("South")
			createdRoom.position += Vector2(_currentRoom.position.x, _currentRoom.position.y + _roomSize.y)
			createdRoom.coordinates.y = _currentRoom.coordinates.y + 1
			
			createdRoom.directions.erase(LevelGenerationUtils.Directions.NORTH)
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.SOUTH)
	
		LevelGenerationUtils.Directions.EAST:
			print("East")
			createdRoom.position += Vector2(_currentRoom.position.x + _roomSize.x, _currentRoom.position.y)
			createdRoom.coordinates.x = _currentRoom.coordinates.x + 1
			
			createdRoom.directions.erase(LevelGenerationUtils.Directions.WEST)
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.EAST)
	
		LevelGenerationUtils.Directions.WEST:
			print("West")
			createdRoom.position += Vector2(_currentRoom.position.x - _roomSize.x, _currentRoom.position.y)
			createdRoom.coordinates.x = _currentRoom.coordinates.x - 1
			
			createdRoom.directions.erase(LevelGenerationUtils.Directions.EAST)
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.WEST)
	
	#On vérifie si il reste encore des directions possibles sur les 2 rooms et on ajoute ou supprime de la liste de rooms utilisables en fonction
	if(createdRoom.directions.size() > 0 && !_roomsWithAvailableDoors.has(createdRoom)) :
		_roomsWithAvailableDoors.append(createdRoom)
	if(_currentRoom.directions.size() <= 0 && _roomsWithAvailableDoors.has(_currentRoom)):
		_roomsWithAvailableDoors.erase(_currentRoom)
	
	#On actualise la room courante
	if(updateCurrentRoom):
		_currentRoom = createdRoom
	return createdRoom
