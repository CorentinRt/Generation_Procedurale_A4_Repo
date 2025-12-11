class_name LevelGeneration extends Node2D

@export var _player:Player

@export_group("Unique rooms")
@export var _startingRoom:RoomData
@export var _treasureRoom:RoomData

@export_group("Other rooms base")
@export var _roomsList:Dictionary[RoomData, float]

@export_group("Generation parameters")
@export var _door:PackedScene
@export var _wall:PackedScene
@export var _possibleStartingRoomDirections:Array[LevelGenerationUtils.Directions]
@export var _roomsMaxCount:int
@export var _roomSize:Vector2i 

@export_group("Debug")
@export var _spriteDebug:Sprite2D

var _roomMap:Dictionary[Vector2i, RoomData]

var _availableRooms:Dictionary[Vector2i, RoomData]
var _currentRoom:RoomData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		var startingRoomDataInstance:RoomData = RoomData.new()
		startingRoomDataInstance.roomNode = _startingRoom.roomScene.instantiate() as Room
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
				#print("Rolling room : ")
				_currentRoom = _get_random_room_from_Availables()
				#print("Rolling Dir = ")
				randDir = _random_dir(_currentRoom)
				
			#print("Spawning Room =")
			_spawn_room(randDir)
			t+=1;
			if t > 100:
				t = 0
				await get_tree().create_timer(0.1).timeout
		
		_add_doors_and_walls()
		
		_player.enter_room(_roomMap[Vector2i(0, 0)].roomNode)

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
	if(_roomsMaxCount - _roomMap.size() == 2):
		selectedRoomData = _treasureRoom

	selectedRoomData.roomNode = selectedRoomData.roomScene.instantiate() as Room
	
	selectedRoomData.directions.clear()
	match creationDir:
		LevelGenerationUtils.Directions.NORTH:
			#print("North")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y - 1)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.SOUTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.NORTH)
			
		LevelGenerationUtils.Directions.SOUTH:
			#print("South")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x, _currentRoom.coordinates.y + 1)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.NORTH)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.SOUTH)
			
		LevelGenerationUtils.Directions.EAST:
			#print("East")
			selectedRoomData.coordinates = Vector2(_currentRoom.coordinates.x + 1, _currentRoom.coordinates.y)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.WEST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.EAST)
	
		LevelGenerationUtils.Directions.WEST:
			#print("West")
			selectedRoomData.coordinates = Vector2( _currentRoom.coordinates.x - 1, _currentRoom.coordinates.y)
			selectedRoomData.roomNode.room_pos = selectedRoomData.coordinates
			selectedRoomData.directions.append(LevelGenerationUtils.Directions.EAST)
			_currentRoom.directions.append(LevelGenerationUtils.Directions.WEST)
	
	selectedRoomData.roomNode.position = Vector2(selectedRoomData.coordinates.x * _roomSize.x, selectedRoomData.coordinates.y * _roomSize.y)
	_roomMap[selectedRoomData.coordinates] = selectedRoomData
	_update_available_rooms(selectedRoomData)
	
	_update_available_rooms(_currentRoom)
	add_child(selectedRoomData.roomNode)

func _add_doors_and_walls() -> void:
	for i in _roomMap:
		var unusedDirections:Array[LevelGenerationUtils.Directions] = [LevelGenerationUtils.Directions.NORTH, LevelGenerationUtils.Directions.SOUTH, LevelGenerationUtils.Directions.EAST, LevelGenerationUtils.Directions.WEST]
		
		var roomBounds:Rect2 = _roomMap[i].roomNode.get_world_bounds()
		print(roomBounds)
		var tileSize:Vector2i = _roomMap[i].roomNode.tilemap_layers[0].tile_set.tile_size
		var isWidthEven:bool = false
		var isHeightEven:bool = false
		
		if(int(roomBounds.size.x / tileSize.x) % 2 == 0): isWidthEven = true
		if(int(roomBounds.size.y / tileSize.y) % 2 == 0): isHeightEven = true
		
		#print("\n")
		#print("Room name : " + _roomMap[i].roomNode.name)
		#print("Room bounds size : {" + str(roomBounds.size.x) + ";" + str(roomBounds.size.y) + "}")
		#print("is Width even : " + str(isWidthEven))
		#print("Width size : " + str(roomBounds.size.x/ tileSize.x))
		#print("is Height even : " + str(isHeightEven))
		#print("Height size : " + str(roomBounds.size.y/ tileSize.y))
		
		var offset:Vector2 = Vector2.ZERO
		offset = tileSize / 2
		
		#Put doors in desired directions
		for dir in _roomMap[i].directions:
			match dir:
				LevelGenerationUtils.Directions.NORTH:
					if(isWidthEven):
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x / 2 + offset.x, offset.y))
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x / 2 - offset.x, offset.y))
					else:
						_create_object_in_room(_door ,_roomMap[i], Vector2(roomBounds.size.x / 2, offset.y))
					
					unusedDirections.erase(LevelGenerationUtils.Directions.NORTH)
					
				LevelGenerationUtils.Directions.SOUTH:
					if(isWidthEven):
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x / 2 + offset.x, roomBounds.size.y - offset.y))
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x / 2 - offset.x, roomBounds.size.y - offset.y))
					else:
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x / 2, roomBounds.size.y - offset.y))
					
					unusedDirections.erase(LevelGenerationUtils.Directions.SOUTH)
						
				LevelGenerationUtils.Directions.EAST:
					if(isHeightEven):
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2 - offset.y))
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2 + offset.y))
					else:
						_create_object_in_room(_door, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2))
						
					unusedDirections.erase(LevelGenerationUtils.Directions.EAST)
						
				LevelGenerationUtils.Directions.WEST:
					if(isHeightEven):
						_create_object_in_room(_door, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2 - offset.y))
						_create_object_in_room(_door, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2 + offset.y))
					else:
						_create_object_in_room(_door, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2))
						
					unusedDirections.erase(LevelGenerationUtils.Directions.WEST)
		
		#Put walls in unsed directions
		for dir in unusedDirections:
			match dir:
				LevelGenerationUtils.Directions.NORTH:
					if(isWidthEven):
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x / 2 + offset.x, offset.y))
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x / 2 - offset.x, offset.y))
					else:
						_create_object_in_room(_wall ,_roomMap[i], Vector2(roomBounds.size.x / 2, offset.y))
					
					#unusedDirections.erase(LevelGenerationUtils.Directions.NORTH)
					
				LevelGenerationUtils.Directions.SOUTH:
					if(isWidthEven):
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x / 2 + offset.x, roomBounds.size.y - offset.y))
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x / 2 - offset.x, roomBounds.size.y - offset.y))
					else:
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x / 2, roomBounds.size.y - offset.y))
					
					#unusedDirections.erase(LevelGenerationUtils.Directions.SOUTH)
						
				LevelGenerationUtils.Directions.EAST:
					if(isHeightEven):
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2 - offset.y)).rotation = deg_to_rad(90.0)
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2 + offset.y)).rotation = deg_to_rad(90.0)
					else:
						_create_object_in_room(_wall, _roomMap[i], Vector2(roomBounds.size.x - offset.x, roomBounds.size.y / 2)).rotation = deg_to_rad(90.0)
						
					#unusedDirections.erase(LevelGenerationUtils.Directions.EAST)
						
				LevelGenerationUtils.Directions.WEST:
					if(isHeightEven):
						_create_object_in_room(_wall, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2 - offset.y)).rotation = deg_to_rad(90.0)
						_create_object_in_room(_wall, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2 + offset.y)).rotation = deg_to_rad(90.0)
					else:
						_create_object_in_room(_wall, _roomMap[i], Vector2(offset.x, roomBounds.size.y / 2)).rotation = deg_to_rad(90.0)
						
					#unusedDirections.erase(LevelGenerationUtils.Directions.WEST)
		

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

func _create_object_in_room(object:PackedScene, roomData:RoomData, coord:Vector2) -> Node2D:
	var createdObject:Node2D = object.instantiate()
	createdObject.global_position = coord
	roomData.roomNode.add_child(createdObject)
	return createdObject

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
