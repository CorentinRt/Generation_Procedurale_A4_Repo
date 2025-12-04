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
		startingRoomInstance.initRoom()
		add_child(startingRoomInstance)
		_startingRoomDirections = startingRoomInstance.directions.duplicate()
		
		_currentRoom = startingRoomInstance
		#var currentRoomPossibleDirs:Array[LevelGenerationUtils.Directions] = startingRoomInstance.directions
				
		#Créer toujours au moins une salle pour chaque direction de la salle de départ
		for i in range(_startingRoomDirections.size()):
			_create_room(_startingRoomDirections[i], false, 0)
			_roomsMaxCount -= 1
		
		for i in _roomsMaxCount:
			_currentRoom = _get_random_room_from_availables()
			var randDir:LevelGenerationUtils.Directions = _random_dir(_currentRoom.directions)
			_create_room(randDir, true, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _random_dir(dirList:Array) -> LevelGenerationUtils.Directions:
	var dir:LevelGenerationUtils.Directions = dirList[randi() % dirList.size()] as LevelGenerationUtils.Directions
	return dir

func _create_room(creationDir:LevelGenerationUtils.Directions, updateCurrentRoom:bool, minimumDoorsCount:int) -> Node2D:
	#Direction que la room créée doit avoir
	#Elle correspond a la direction inverse de celle de création pour connecter les portes
	var restrictionDir:LevelGenerationUtils.Directions
	
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			restrictionDir = LevelGenerationUtils.Directions.SOUTH
		LevelGenerationUtils.Directions.SOUTH:
			restrictionDir = LevelGenerationUtils.Directions.NORTH
		LevelGenerationUtils.Directions.EAST:
			restrictionDir = LevelGenerationUtils.Directions.WEST			
		LevelGenerationUtils.Directions.WEST:
			restrictionDir = LevelGenerationUtils.Directions.EAST			
	
	#On créer la room et on l'ajoute a la hiérarchie
	var createdRoom:Node2D = _randomRoomBase.instantiate()
	createdRoom.initRoom(restrictionDir)
	
	#On reroll la salle jusqu'a en avoir une qui corresponde a ce qu'on veut (probablement a rework si le temps)
	while(createdRoom.directions.size() < minimumDoorsCount):
		print(createdRoom.directions.size())
		createdRoom = _randomRoomBase.instantiate()
		createdRoom.initRoom(restrictionDir)
	
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

func _get_random_room_from_availables() -> Node2D:
	var room:Node2D = _roomsWithAvailableDoors[randi() % _roomsWithAvailableDoors.size()]
	return room
