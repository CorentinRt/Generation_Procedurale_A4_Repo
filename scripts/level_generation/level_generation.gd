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

var _roomList:Array[Node2D]

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
			_roomList.append(_create_room(_startingRoomDirections[i], false, 0))
			_roomsMaxCount -= 1
		
		for i in _roomsMaxCount:
			_currentRoom = _get_random_room_from_availables()
			var randDir:LevelGenerationUtils.Directions = _random_dir(_currentRoom.directions)
			_roomList.append(_create_room(randDir, true, 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _random_dir(dirList:Array) -> LevelGenerationUtils.Directions:
	var dir:LevelGenerationUtils.Directions = dirList[randi() % dirList.size()] as LevelGenerationUtils.Directions
	return dir

func _create_room(creationDir:LevelGenerationUtils.Directions, updateCurrentRoom:bool, minimumDoorsCount:int) -> Node2D:
	#Directions que la room créée doit avoir
	#Elles correspondent aux direction inverse de celles qu'elle aura autour d'elle si elles ont des portes
	var restrictionDir:Array[LevelGenerationUtils.Directions]
	
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			restrictionDir.append(LevelGenerationUtils.Directions.SOUTH)
		LevelGenerationUtils.Directions.SOUTH:
			restrictionDir.append(LevelGenerationUtils.Directions.NORTH)
		LevelGenerationUtils.Directions.EAST:
			restrictionDir.append(LevelGenerationUtils.Directions.WEST)	
		LevelGenerationUtils.Directions.WEST:
			restrictionDir.append(LevelGenerationUtils.Directions.EAST)		
	
	var createdRoomPosition:Vector2
	var createdRoomCoordinates:Vector2i
	var directionToErase:LevelGenerationUtils.Directions
	#On positionne la room créée en fonction de la direction que l'on a et on supprime les directions utilisées par chaque room
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			print("North")
			createdRoomPosition = Vector2(_currentRoom.position.x, _currentRoom.position.y - _roomSize.y)
			createdRoomCoordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y - 1)
			
			directionToErase = LevelGenerationUtils.Directions.SOUTH
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.NORTH)
	
		LevelGenerationUtils.Directions.SOUTH:
			print("South")
			createdRoomPosition = Vector2(_currentRoom.position.x, _currentRoom.position.y + _roomSize.y)
			createdRoomCoordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y + 1)
			
			directionToErase = LevelGenerationUtils.Directions.NORTH
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.SOUTH)
	
		LevelGenerationUtils.Directions.EAST:
			print("East")
			createdRoomPosition = Vector2(_currentRoom.position.x + _roomSize.x, _currentRoom.position.y)
			createdRoomCoordinates = Vector2(_currentRoom.coordinates.x + 1, _currentRoom.coordinates.y)
			
			directionToErase = LevelGenerationUtils.Directions.WEST
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.EAST)
	
		LevelGenerationUtils.Directions.WEST:
			print("West")
			createdRoomPosition = Vector2(_currentRoom.position.x - _roomSize.x, _currentRoom.position.y)
			createdRoomCoordinates = Vector2( _currentRoom.coordinates.x - 1, _currentRoom.coordinates.y)
			
			directionToErase = LevelGenerationUtils.Directions.EAST
			_currentRoom.directions.erase(LevelGenerationUtils.Directions.WEST)
	
	#UPDATE LA ROOM CREER AVEC LES NOUVELLES DATAS PUIS FINIR LA BOUCLE
	#POUR CHECK LES SALLES ALENTOUR AVEC DES CONNEXIONS POSSIBLES
	
	for room in _roomList:
		if (room != _currentRoom):
			#if((room.coordinates.x == createdRoomCoordinates.x && room.coordinates.y == createdRoomCoordinates.y + 1) || (room.coordinates.x == createdRoomCoordinates.x && room.coordinates.y == createdRoomCoordinates.y - 1) || (room.coordinates.y == createdRoomCoordinates.y && room.coordinates.x == createdRoomCoordinates.x - 1) || (room.coordinates.y == createdRoomCoordinates.y && room.coordinates.x == createdRoomCoordinates.x + 1)) :
			if(createdRoomCoordinates.x == room.coordinates.x && createdRoomCoordinates.y + 1 == room.coordinates.y):
				if(room.directions.has(LevelGenerationUtils.Directions.NORTH)):
					restrictionDir.append(LevelGenerationUtils.Directions.SOUTH)
					
			elif(createdRoomCoordinates.x == room.coordinates.x && createdRoomCoordinates.y - 1 == room.coordinates.y):
				if(room.directions.has(LevelGenerationUtils.Directions.SOUTH)):
					restrictionDir.append(LevelGenerationUtils.Directions.NORTH)
					
			elif(createdRoomCoordinates.x + 1 == room.coordinates.x && createdRoomCoordinates.y == room.coordinates.y):
				if(room.directions.has(LevelGenerationUtils.Directions.WEST)):
					restrictionDir.append(LevelGenerationUtils.Directions.EAST)
					
			elif(createdRoomCoordinates.x - 1 == room.coordinates.x && createdRoomCoordinates.y == room.coordinates.y):
				if(room.directions.has(LevelGenerationUtils.Directions.EAST)):
					restrictionDir.append(LevelGenerationUtils.Directions.WEST)
					
					
	#On créer la room
	var createdRoom:Node2D = _randomRoomBase.instantiate()
	createdRoom.initRoom(restrictionDir)
	
	#On reroll la salle jusqu'a en avoir une qui corresponde a ce qu'on veut (probablement a rework si le temps)
	while(createdRoom.directions.size() < minimumDoorsCount):
		print(createdRoom.directions.size())
		createdRoom = _randomRoomBase.instantiate()
		createdRoom.initRoom(restrictionDir)
		
	
	#On l'initialise et on la place au bon endroit
	createdRoom.directions.erase(directionToErase)
	createdRoom.position = createdRoomPosition
	createdRoom.coordinates = createdRoomCoordinates
	
	#On l'ajoute a la hiérarchie
	add_child(createdRoom)		
	
	_roomsWithAvailableDoors.append(createdRoom)
	#On vérifie si il reste encore des directions possibles sur les 2 rooms et on ajoute ou supprime de la liste de rooms utilisables en fonction
	for room in _roomsWithAvailableDoors:
		if(room.directions.size() <= 0):
			_roomsWithAvailableDoors.erase(room)
	
	#On actualise la room courante
	if(updateCurrentRoom):
		_currentRoom = createdRoom
	return createdRoom

func _get_random_room_from_availables() -> Node2D:
	var room:Node2D = _roomsWithAvailableDoors[randi() % _roomsWithAvailableDoors.size()]
	return room
