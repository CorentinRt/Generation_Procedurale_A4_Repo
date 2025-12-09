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

var _availableRooms:Dictionary[Vector2i, RoomData]
var _currentRoom:RoomData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		var startingRoomDataInstance:RoomData = RoomData.new()
		startingRoomDataInstance.tilemap = _startingRoom.roomScene.instantiate() as TileMapLayer
		add_child(startingRoomDataInstance.tilemap)
		
		var startingRoomDirections:Array[LevelGenerationUtils.Directions] = _selectRandomDirFromArray(_possibleStartingRoomDirections)
		_currentRoom = startingRoomDataInstance
		_roomMap[startingRoomDataInstance.coordinates] = startingRoomDataInstance
				
		#Créer toujours au moins une salle pour chaque direction de la salle de départ
		for i in range(startingRoomDirections.size()):
			_spawn_room(startingRoomDirections[i])
			_roomsMaxCount -= 1
		
		for i in _roomsMaxCount:
			_currentRoom = _get_random_room_from_Availables()
			while(_currentRoom.directions.size() >= 4 || _currentRoom.coordinates == Vector2i.ZERO):
				_currentRoom = _get_random_room_from_Availables()	
			var randDir:LevelGenerationUtils.Directions = _random_dir(_currentRoom)
			while(roomHasNeighboorInDir(_currentRoom.coordinates, randDir)):
				randDir = _random_dir(_currentRoom)
				#Peut avoir une boucle infinie si une seule possibilité de direction mais qu'il y a deja un voisin
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
		print(returnedArray)
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
	_update_available_rooms(selectedRoomData)
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
						_create_door(_roomMap[i], Vector2(roomBounds.size.x / 2, -offset.y))
						_create_door(_roomMap[i], Vector2(roomBounds.size.x / 2, offset.y))
					else:
						_create_door(_roomMap[i], Vector2(roomBounds.size.x / 2, 0))
						
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

func _get_random_room_from_Availables() -> RoomData:
	var room:RoomData = _availableRooms.values()[randi() % _availableRooms.values().size()]
	return room
	
func _update_available_rooms(room:RoomData) -> void:
	_availableRooms[room.coordinates] = room
		
	for i in _availableRooms:
		if(_availableRooms[i].directions.size() >= 4 || (roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.NORTH) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.SOUTH) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.EAST) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.WEST))):
			_availableRooms.erase(i)
