class_name RandomRoom extends Node2D

@export var _isStartingRoom:bool

@export var coordinates:Vector2i
var directions:Array[LevelGenerationUtils.Directions]

@export var _startingInterior:PackedScene
@export var _startingExteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsInteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsExteriorsDict:Dictionary[RoomExteriorData, int] = {}

func initRoom(dir:LevelGenerationUtils.Directions = LevelGenerationUtils.Directions.NONE):
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
		if(dir == LevelGenerationUtils.Directions.NONE):
			selectedExterior = _pickRandomElementFromDictData(_roomsExteriorsDict)
		else :
			selectedExterior = _pickRandomElementFromDictDataWithDir(_roomsExteriorsDict, dir)
			
		
		var interiorInstance = selectedInterior.instantiate()
		var exteriorInstance = selectedExterior.instantiate()
		
		add_child(interiorInstance)
		add_child(exteriorInstance)
		directions = exteriorInstance.directions

func _pickRandomElementFromDict(dictionary: Dictionary[PackedScene, int]) -> PackedScene:
	var returnedElement:PackedScene
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
	
	returnedElement = dictionary.keys()[count]
	
	return returnedElement
	
func _pickRandomElementFromDictData(dictionary: Dictionary[RoomExteriorData, int]) -> PackedScene:
	var returnedElement:PackedScene
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
	
	returnedElement = dictionary.keys()[count].roomExteriorScene
	
	return returnedElement
	
func _pickRandomElementFromDictDataWithDir(dictionary: Dictionary[RoomExteriorData, int], dir:LevelGenerationUtils.Directions) -> PackedScene:
	var returnedElement:PackedScene
	var totalWeight:int = 0
	
	var elementWithDir:Dictionary[RoomExteriorData, int]
	
	for i in dictionary.keys().size():		
		if(dictionary.keys()[i].directions.has(dir)):
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
	
	returnedElement = elementWithDir.keys()[count].roomExteriorScene
	
	return returnedElement
