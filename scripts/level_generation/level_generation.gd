class_name LevelGeneration extends Node2D

@export var _playerScene:PackedScene

@export_group("Starting room")
@export var _startingRoom:RoomData
@export var _possibleStartingRoomDirections:Array[LevelGenerationUtils.Directions]

@export_group("Other rooms base")
@export var _roomsList:Dictionary[RoomData, float]

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
		startingRoomDataInstance.roomNode = _startingRoom.roomScene.instantiate() as Room
		startingRoomDataInstance.tilemaps = startingRoomDataInstance.roomNode.tilemap_layers
		startingRoomDataInstance.mergedTilemapsRect = _merge_tilemaps(startingRoomDataInstance.tilemaps)
		add_child(startingRoomDataInstance.roomNode)
		
		var startingRoomDirections:Array[LevelGenerationUtils.Directions] = _selectRandomDirFromArray(_possibleStartingRoomDirections)
		_currentRoom = startingRoomDataInstance
		_roomMap[startingRoomDataInstance.coordinates] = startingRoomDataInstance
				
		#Créer toujours au moins une salle pour chaque direction de la salle de départ
		for i in range(startingRoomDirections.size()):
			_spawn_room(startingRoomDirections[i])
			_roomsMaxCount -= 1
		
		var t = 0;
		for i in _roomsMaxCount:
			_currentRoom = _get_random_room_from_Availables()
			var randDir:LevelGenerationUtils.Directions = _random_dir(_currentRoom)
			
			while(_currentRoom.directions.size() >= 4 || _currentRoom.coordinates == Vector2i.ZERO || roomHasNeighboorInDir(_currentRoom.coordinates, randDir)):
				print("Rolling room : ")
				_currentRoom = _get_random_room_from_Availables()
				print("Rolling Dir = ")
				randDir = _random_dir(_currentRoom)
				
			print("Spawning Room =")
			_spawn_room(randDir)
			t+=1;
			if t > 100:
				t = 0
				await get_tree().create_timer(0.1).timeout
		
		_add_doors()
		var player:Player = _playerScene.instantiate() as Player
		add_child(player)
		player._room = _roomMap[Vector2i(0, 0)].roomNode

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
	selectedRoomData.roomNode = selectedRoomData.roomScene.instantiate() as Room
	selectedRoomData.tilemaps = selectedRoomData.roomNode.tilemap_layers
	selectedRoomData.mergedTilemapsRect = _merge_tilemaps(selectedRoomData.tilemaps)
	selectedRoomData.directions.clear()
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			print("North")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y - 1)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.SOUTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.NORTH)
			
		LevelGenerationUtils.Directions.SOUTH:
			print("South")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y + 1)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.NORTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.SOUTH)
			
		LevelGenerationUtils.Directions.EAST:
			print("East")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x + 1, _currentRoom.coordinates.y)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.WEST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.EAST)
	
		LevelGenerationUtils.Directions.WEST:
			print("West")
			selectedRoomData.coordinates = Vector2( _currentRoom.coordinates.x - 1, _currentRoom.coordinates.y)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.EAST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.WEST)
	
	selectedRoomData.roomNode.position = Vector2(selectedRoomData.coordinates.x * _roomSize.x, selectedRoomData.coordinates.y * _roomSize.y)
	_roomMap[selectedRoomData.coordinates] = selectedRoomData
	_update_available_rooms(selectedRoomData)
	
	_update_available_rooms(_currentRoom)
	add_child(selectedRoomData.roomNode)

func _add_doors() -> void:
	for i in _roomMap:
		for dir in _roomMap[i].directions:
			var roomBounds:Rect2 = _roomMap[i].mergedTilemapsRect
			print(roomBounds)
			var tileSize:Vector2i = _roomMap[i].tilemaps[0].tile_set.tile_size
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
	roomData.roomNode.add_child(createdDoor)

func _pickRandomElementFromDict(dictionary: Dictionary[RoomData, float]) -> RoomData:
	var totalWeight:float = 0
	
	for i in dictionary.values().size():
		totalWeight += dictionary.values()[i]
	
	var randomDictionaryWeight:float = randf_range(0, totalWeight)
	
	var weight:float = 0
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
	var temp = _availableRooms.keys()
	for i in temp:
		if(_availableRooms[i].directions.size() >= 4 || (roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.NORTH) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.SOUTH) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.EAST) && roomHasNeighboorInDir(_availableRooms[i].coordinates, LevelGenerationUtils.Directions.WEST))):
			_availableRooms.erase(i)

func _merge_tilemaps(tilemapArray:Array[TileMapLayer]) -> Rect2:
	var rect:Rect2
	for i in tilemapArray.size():
		rect.merge(tilemapArray[i].get_used_rect())
	return rect
