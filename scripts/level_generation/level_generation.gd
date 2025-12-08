class_name LevelGeneration extends Node2D

@export_group("Starting room")
@export var _startingRoom:RoomData
@export var _possibleStartingRoomDirections:Array[LevelGenerationUtils.Directions]

@export_group("Other rooms base")
@export var _roomsList:Dictionary[RoomData, int]

@export_group("Generation parameters")
@export var _door:PackedScene
@export var _roomsMaxCount:int
@export var _maxLevelHeight:int
@export var _maxLevelWidth:int
@export var _roomSize:Vector2i

var _roomMap:Dictionary[Vector2i, RoomData]

var _roomsWithAvailableDoors:Array[RoomData]
var _currentRoom:RoomData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		var startingRoomDataInstance:RoomData = RoomData.new()
		startingRoomDataInstance.tilemap = _startingRoom.roomScene.instantiate() as TileMapLayer
		add_child(startingRoomDataInstance.tilemap)
		
		var startingRoomDirections:Array[LevelGenerationUtils.Directions] = _selectRandomDirFromArray(_possibleStartingRoomDirections)
		_currentRoom = startingRoomDataInstance
				
		#Créer toujours au moins une salle pour chaque direction de la salle de départ
		for i in range(startingRoomDirections.size()):
			_spawn_room(startingRoomDirections[i])
			_roomsMaxCount -= 1
		
		for i in _roomsMaxCount:
			_currentRoom = _get_random_room()
			while(_currentRoom.directions.size() >= 4):
				_currentRoom = _get_random_room()	
			var randDir:LevelGenerationUtils.Directions = _random_dir(_currentRoom)
			_spawn_room(randDir)
		
		_add_doors()

func _random_dir(room:RoomData) -> LevelGenerationUtils.Directions:
	var dir:LevelGenerationUtils.Directions = LevelGenerationUtils.Directions.values()[randi() % LevelGenerationUtils.Directions.size()] as LevelGenerationUtils.Directions
	
	while(room.directions.has(dir) || dir == LevelGenerationUtils.Directions.NONE):
		dir = LevelGenerationUtils.Directions.values()[randi() % LevelGenerationUtils.Directions.size()] as LevelGenerationUtils.Directions
		
	return dir
	
func _selectRandomDirFromArray(dirs:Array[LevelGenerationUtils.Directions]) -> Array[LevelGenerationUtils.Directions]:
		var dirsCopy = dirs.duplicate()
		var returnedArray:Array[LevelGenerationUtils.Directions]
		var randomCount:int = randi_range(1, dirs.size())
		
		while returnedArray.size() != randomCount:
			var randomIndex:int = randi_range(0, dirsCopy.size() - 1)
			var addedDir:LevelGenerationUtils.Directions = dirsCopy[randomIndex]
			if(!returnedArray.has(addedDir)):
				returnedArray.append(addedDir)
				dirsCopy.erase(addedDir)
		return returnedArray

func _spawn_room(creationDir:LevelGenerationUtils.Directions) -> void:
	var selectedRoomData:RoomData = _pickRandomElementFromDict(_roomsList).duplicate()
	selectedRoomData.tilemap = selectedRoomData.roomScene.instantiate()
	selectedRoomData.directions.clear()
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			print("North")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y - 1)
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.SOUTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.NORTH)
			
		LevelGenerationUtils.Directions.SOUTH:
			print("South")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y + 1)
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.NORTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.SOUTH)
			
		LevelGenerationUtils.Directions.EAST:
			print("East")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x + 1, _currentRoom.coordinates.y)
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.WEST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.EAST)
	
		LevelGenerationUtils.Directions.WEST:
			print("West")
			selectedRoomData.coordinates = Vector2( _currentRoom.coordinates.x - 1, _currentRoom.coordinates.y)
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.EAST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.WEST)
	
	selectedRoomData.tilemap.position = Vector2(selectedRoomData.coordinates.x * _roomSize.x, selectedRoomData.coordinates.y * _roomSize.y)
	_roomMap[selectedRoomData.coordinates] = selectedRoomData
	add_child(selectedRoomData.tilemap)

func _add_doors() -> void:
	for i in _roomMap:
		for dir in _roomMap[i].directions:
			var roomBounds:Rect2 = _roomMap[i].tilemap.get_used_rect()
			var tileSize:Vector2i = _roomMap[i].tilemap.tile_set.tile_size
			var isWidthEven:bool = false
			var isHeightEven:bool = false
			
			if(int(roomBounds.size.x) % 2 == 0): isWidthEven = true
			if(int(roomBounds.size.y) % 2 == 0): isHeightEven = true
			
			roomBounds.size *= tileSize.x
			var offset:Vector2 = Vector2.ZERO
			offset = tileSize / 2
			match dir:
				LevelGenerationUtils.Directions.NORTH:
					#var yCoord:float = roomBounds.position.y - roomBounds.size.y / 2 + offset.y
					if(isWidthEven):
						_create_door(_roomMap[i], Vector2(offset.x, -roomBounds.size.y / 2))
						_create_door(_roomMap[i], Vector2(-offset.x, -roomBounds.size.y / 2))
					else:
						_create_door(_roomMap[i], Vector2(0, -roomBounds.size.y / 2))
					
				LevelGenerationUtils.Directions.SOUTH:
					#var yCoord:float = roomBounds.position.y + roomBounds.size.y / 2 - offset.y
					if(isWidthEven):
						_create_door(_roomMap[i], Vector2(offset.x, roomBounds.size.y / 2))
						_create_door(_roomMap[i], Vector2(-offset.x,  roomBounds.size.y / 2))
					else:
						_create_door(_roomMap[i], Vector2(0,  roomBounds.size.y / 2))
						
				LevelGenerationUtils.Directions.EAST:
					#var xCoord:float = roomBounds.position.x + roomBounds.size.x / 2 - offset.x
					if(isHeightEven):
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, -offset.y))
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, offset.y))
					else:
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, 0))
						
				LevelGenerationUtils.Directions.WEST:
					#var xCoord:float = roomBounds.position.x - roomBounds.size.x / 2 + offset.x
					if(isHeightEven):
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, -offset.y))
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, offset.y))
					else:
						_create_door(_roomMap[i], Vector2(-roomBounds.size.x / 2, 0))

func roomHasNeighboorInDir(coordinates:Vector2i, dir:LevelGenerationUtils.Directions) -> bool:
	match dir:
		LevelGenerationUtils.Directions.NORTH:
			if(_roomMap.keys().has(Vector2i(coordinates.x, coordinates.y - 1))):
				return true;
		LevelGenerationUtils.Directions.SOUTH:
			if(_roomMap.keys().has(Vector2i(coordinates.x, coordinates.y + 1))):
				return true;
		LevelGenerationUtils.Directions.EAST:
			if(_roomMap.keys().has(Vector2i(coordinates.x + 1, coordinates.y))):
				return true;
		LevelGenerationUtils.Directions.WEST:
			if(_roomMap.keys().has(Vector2i(coordinates.x - 1, coordinates.y))):
				return true;
	return false

func _create_door(roomData:RoomData, coord:Vector2) -> void:
	var createdDoor:Node2D = _door.instantiate()
	createdDoor.global_position = coord
	roomData.tilemap.add_child(createdDoor)

func _pickRandomElementFromDict(dictionary: Dictionary[RoomData, int]) -> RoomData:
	var totalWeight:int = 0
	
	for i in dictionary.values().size():
		totalWeight += dictionary.values()[i]
	
	var randomDictionaryWeight:int = randi_range(0, totalWeight)
	
	var weight:int = 0
	var count:int = 0
	for i in dictionary.values().size():
		weight += dictionary.values()[i]
		if(weight >= randomDictionaryWeight):
			break
		count += 1
	
	return dictionary.keys()[count]

#func _create_room(creationDir:LevelGenerationUtils.Directions, updateCurrentRoom:bool, minimumDoorsCount:int) -> RoomData:
	##Directions que la room créée doit avoir
	##Elles correspondent aux direction inverse de celles qu'elle aura autour d'elle si elles ont des portes
	#var restrictionDir:Array[LevelGenerationUtils.Directions]
	#
	#match creationDir:
		#LevelGenerationUtils.Directions.NORTH:
			#restrictionDir.append(LevelGenerationUtils.Directions.SOUTH)
		#LevelGenerationUtils.Directions.SOUTH:
			#restrictionDir.append(LevelGenerationUtils.Directions.NORTH)
		#LevelGenerationUtils.Directions.EAST:
			#restrictionDir.append(LevelGenerationUtils.Directions.WEST)	
		#LevelGenerationUtils.Directions.WEST:
			#restrictionDir.append(LevelGenerationUtils.Directions.EAST)		
	#
	#var createdRoomPosition:Vector2
	#var createdRoomCoordinates:Vector2i
	#var directionToErase:LevelGenerationUtils.Directions
	##On positionne la room créée en fonction de la direction que l'on a et on supprime les directions utilisées par chaque room
	#match creationDir:
		#LevelGenerationUtils.Directions.NORTH:
			#print("North")
			#createdRoomPosition = Vector2(_currentRoom.position.x, _currentRoom.position.y - _roomSize.y)
			#createdRoomCoordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y - 1)
			#
			#directionToErase = LevelGenerationUtils.Directions.SOUTH
			#_currentRoom.directions.erase(LevelGenerationUtils.Directions.NORTH)
	#
		#LevelGenerationUtils.Directions.SOUTH:
			#print("South")
			#createdRoomPosition = Vector2(_currentRoom.position.x, _currentRoom.position.y + _roomSize.y)
			#createdRoomCoordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y + 1)
			#
			#directionToErase = LevelGenerationUtils.Directions.NORTH
			#_currentRoom.directions.erase(LevelGenerationUtils.Directions.SOUTH)
	#
		#LevelGenerationUtils.Directions.EAST:
			#print("East")
			#createdRoomPosition = Vector2(_currentRoom.position.x + _roomSize.x, _currentRoom.position.y)
			#createdRoomCoordinates = Vector2(_currentRoom.coordinates.x + 1, _currentRoom.coordinates.y)
			#
			#directionToErase = LevelGenerationUtils.Directions.WEST
			#_currentRoom.directions.erase(LevelGenerationUtils.Directions.EAST)
	#
		#LevelGenerationUtils.Directions.WEST:
			#print("West")
			#createdRoomPosition = Vector2(_currentRoom.position.x - _roomSize.x, _currentRoom.position.y)
			#createdRoomCoordinates = Vector2( _currentRoom.coordinates.x - 1, _currentRoom.coordinates.y)
			#
			#directionToErase = LevelGenerationUtils.Directions.EAST
			#_currentRoom.directions.erase(LevelGenerationUtils.Directions.WEST)
	#
	##UPDATE LA ROOM CREER AVEC LES NOUVELLES DATAS PUIS FINIR LA BOUCLE
	##POUR CHECK LES SALLES ALENTOUR AVEC DES CONNEXIONS POSSIBLES
	#
	#for room in _roomMap:
		#if (room != _currentRoom.coordinates):
			##if((room.coordinates.x == createdRoomCoordinates.x && room.coordinates.y == createdRoomCoordinates.y + 1) || (room.coordinates.x == createdRoomCoordinates.x && room.coordinates.y == createdRoomCoordinates.y - 1) || (room.coordinates.y == createdRoomCoordinates.y && room.coordinates.x == createdRoomCoordinates.x - 1) || (room.coordinates.y == createdRoomCoordinates.y && room.coordinates.x == createdRoomCoordinates.x + 1)) :
			#if(createdRoomCoordinates.x == room.x && createdRoomCoordinates.y + 1 == room.y):
				#if(_roomMap[room].directions.has(LevelGenerationUtils.Directions.NORTH)):
					#restrictionDir.append(LevelGenerationUtils.Directions.SOUTH)
					#
			#elif(createdRoomCoordinates.x == room.x && createdRoomCoordinates.y - 1 == room.y):
				#if(_roomMap[room].directions.has(LevelGenerationUtils.Directions.SOUTH)):
					#restrictionDir.append(LevelGenerationUtils.Directions.NORTH)
					#
			#elif(createdRoomCoordinates.x + 1 == room.x && createdRoomCoordinates.y == room.y):
				#if(_roomMap[room].directions.has(LevelGenerationUtils.Directions.WEST)):
					#restrictionDir.append(LevelGenerationUtils.Directions.EAST)
					#
			#elif(createdRoomCoordinates.x - 1 == room.x && createdRoomCoordinates.y == room.y):
				#if(_roomMap[room].directions.has(LevelGenerationUtils.Directions.EAST)):
					#restrictionDir.append(LevelGenerationUtils.Directions.WEST)
					#
	##On créer la room
	#var createdRoom:RoomData = _pickRandomElementFromDict(_roomsList).instantiate()
	##createdRoom.initRoom(restrictionDir)
	#
	##On reroll la salle jusqu'a en avoir une qui corresponde a ce qu'on veut (probablement a rework si le temps)
	#while(createdRoom.directions.size() < minimumDoorsCount):
		#print(createdRoom.directions.size())
		#createdRoom = _pickRandomElementFromDict(_roomsList).instantiate()
		##createdRoom.initRoom(restrictionDir)
		#
	#
	##On l'initialise et on la place au bon endroit
	#createdRoom.directions.erase(directionToErase)
	#createdRoom.position = createdRoomPosition
	#createdRoom.coordinates = createdRoomCoordinates
	#
	##On l'ajoute a la hiérarchie
	#add_child(createdRoom.tilemap)		
	#
	#_roomsWithAvailableDoors.append(createdRoom)
	##On vérifie si il reste encore des directions possibles sur les 2 rooms et on ajoute ou supprime de la liste de rooms utilisables en fonction
	#for room in _roomsWithAvailableDoors:
		#if(room.directions.size() <= 0):
			#_roomsWithAvailableDoors.erase(room)
	#
	##On actualise la room courante
	#if(updateCurrentRoom):
		#_currentRoom = createdRoom
	#return createdRoom

func _get_random_room() -> RoomData:
	var room:RoomData = _roomMap.values()[randi() % _roomMap.values().size()]
	return room
