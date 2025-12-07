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
		directions = exteriorInstance.directions
		
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
		directions = exteriorInstance.directions

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
	var createdDoor:Node2D = _door.instantiate()
	var isWidthEven:bool = false
	var isHeightEven:bool = false
	
	#Placer correctement la door en fonction de si la size de la tilemap est pair ou impair
	
	if(int(roomBounds.size.x) % 2 == 0): isWidthEven = true
	if(int(roomBounds.size.y) % 2 == 0): isHeightEven = true
	
	for dir in doorsDirections:
		match dir:
			LevelGenerationUtils.Directions.NORTH:
				if(isWidthEven):
					pass
				else:
					pass
					createdDoor.position = Vector2(roomBounds.position.x, roomBounds.position.y - roomBounds.size.y / 2)
			LevelGenerationUtils.Directions.SOUTH:
				if(isWidthEven):
					pass
				else:
					pass
				createdDoor.position = Vector2(roomBounds.position.x, roomBounds.position.y + roomBounds.size.y / 2)
			LevelGenerationUtils.Directions.EAST:
				if(isHeightEven):
					pass
				else:
					pass
				createdDoor.position = Vector2(roomBounds.position.x + roomBounds.size.x / 2, roomBounds.position.y)
			LevelGenerationUtils.Directions.WEST:
				if(isHeightEven):
					pass
				else:
					pass
				createdDoor.position = Vector2(roomBounds.position.x - roomBounds.size.x / 2, roomBounds.position.y)
