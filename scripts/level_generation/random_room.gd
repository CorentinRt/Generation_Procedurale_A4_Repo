class_name RandomRoom extends Node2D

@export var _isStartingRoom:bool

@export var coordinates:Vector2i
var directions:Array[LevelGenerationUtils.Directions]

@export var _startingInterior:PackedScene
@export var _startingExteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsInteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsExteriorsDict:Dictionary[RoomExteriorData, int] = {}
@export var _door:PackedScene

var _room:TileMapLayer

func initRoom(dir:Array[LevelGenerationUtils.Directions] = []):
	if(_isStartingRoom):
		var selectedExterior:PackedScene = _pickRandomElementFromDict(_startingExteriorsDict)
		
		var interiorInstance = _startingInterior.instantiate()
		var exteriorInstance = selectedExterior.instantiate()
		add_child(interiorInstance)
		add_child(exteriorInstance)
		#directions = exteriorInstance.directions
		
	else:
		var selectedInterior:PackedScene = _pickRandomElementFromDict(_roomsInteriorsDict)
		var selectedExterior:PackedScene
		if(dir.size() == LevelGenerationUtils.Directions.NONE):
			selectedExterior = _pickRandomElementFromDictData(_roomsExteriorsDict)
		else :
			selectedExterior = _pickRandomCompatibleElementFromDictDataWithDir(_roomsExteriorsDict, dir)
			
		
		var interiorInstance = selectedInterior.instantiate()
		var exteriorInstance = selectedExterior.instantiate()
		_room = exteriorInstance
		
		add_child(interiorInstance)
		add_child(exteriorInstance)
		#directions = exteriorInstance.directions

func _pickRandomElementFromDict(dictionary: Dictionary[PackedScene, int]) -> PackedScene:
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
	
func _pickRandomElementFromDictData(dictionary: Dictionary[RoomExteriorData, int]) -> PackedScene:
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
	
	return dictionary.keys()[count].roomExteriorScene
	
func _pickRandomCompatibleElementFromDictDataWithDir(dictionary: Dictionary[RoomExteriorData, int], dirArray:Array[LevelGenerationUtils.Directions]) -> PackedScene:
	var totalWeight:int = 0
	
	var elementWithDir:Dictionary[RoomExteriorData, int]
	
	for i in dictionary.keys().size():		
		#Regarder si il contient au moins toutes les directions qu'on veut
		for dir in dirArray:
			var countDir:int = 0
			if(!dictionary.keys()[i].directions.has(dir)):
				break;
			countDir += 1
			if(countDir == dirArray.size()):
				elementWithDir[dictionary.keys()[i]] = dictionary.values()[i]
	
	for i in elementWithDir.values().size():
		totalWeight += elementWithDir.values()[i]
	
	var randomDictionaryWeight:int = randi_range(0, totalWeight)
	
	var weight:int = 0
	var count:int = 0
	for i in elementWithDir.values().size():
		weight += elementWithDir.values()[i]
		if(weight >= randomDictionaryWeight):
			break
		count += 1
	
	return elementWithDir.keys()[count].roomExteriorScene


func _add_doors(doorsDirections:Array[LevelGenerationUtils.Directions]):
	var roomBounds:Rect2 = _room.get_used_rect()
	var tileSize:Vector2i = _room.tile_set.tile_size
	var isWidthEven:bool = false
	var isHeightEven:bool = false
	
	#Placer correctement la door en fonction de si la size de la tilemap est pair ou impair
	
	if(int(roomBounds.size.x) % 2 == 0): isWidthEven = true
	if(int(roomBounds.size.y) % 2 == 0): isHeightEven = true
	
	var offset:Vector2 = Vector2.ZERO
	offset = tileSize / 2
	
	for dir in doorsDirections:
		match dir:
			LevelGenerationUtils.Directions.NORTH:
				var yCoord:float = roomBounds.position.y - roomBounds.size.y / 2 + offset.y
				if(isWidthEven):
					_create_door(Vector2(roomBounds.position.x + offset.x, yCoord))
					_create_door(Vector2(roomBounds.position.x - offset.x, yCoord))
				else:
					_create_door(Vector2(roomBounds.position.x, yCoord))
				
				directions.append(LevelGenerationUtils.Directions.NORTH)
			LevelGenerationUtils.Directions.SOUTH:
				var yCoord:float = roomBounds.position.y + roomBounds.size.y / 2 - offset.y
				if(isWidthEven):
					_create_door(Vector2(roomBounds.position.x + offset.x, yCoord))
					_create_door(Vector2(roomBounds.position.x - offset.x, yCoord))
				else:
					_create_door(Vector2(roomBounds.position.x, yCoord))
					
				directions.append(LevelGenerationUtils.Directions.SOUTH)
			LevelGenerationUtils.Directions.EAST:
				var xCoord:float = roomBounds.position.x + roomBounds.size.x / 2 - offset.x
				if(isHeightEven):
					_create_door(Vector2(xCoord, roomBounds.position.y - offset.y))
					_create_door(Vector2(xCoord, roomBounds.position.y + offset.y))
				else:
					_create_door(Vector2(xCoord, roomBounds.position.y))
					
				directions.append(LevelGenerationUtils.Directions.EAST)
			LevelGenerationUtils.Directions.WEST:
				var xCoord:float = roomBounds.position.x - roomBounds.size.x / 2 + offset.x
				if(isHeightEven):
					_create_door(Vector2(xCoord, roomBounds.position.y - offset.y))
					_create_door(Vector2(xCoord, roomBounds.position.y + offset.y))
				else:
					_create_door(Vector2(xCoord, roomBounds.position.y))
					
				directions.append(LevelGenerationUtils.Directions.WEST)

func _create_door(coord:Vector2) -> void:
	var createdDoor:Node2D = _door.instantiate()
	createdDoor.global_position = coord
	add_child(createdDoor)
