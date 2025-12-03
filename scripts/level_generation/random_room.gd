class_name RandomRoom extends Node2D

@export var _isStartingRoom:bool

@export var coordinates:Vector2i
var directions:Array[LevelGenerationUtils.Directions]

@export var _startingInterior:PackedScene
@export var _startingExteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsInteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsExteriorsDict:Dictionary[PackedScene, int] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if(_isStartingRoom):
		var selectedExterior:PackedScene = _pickRandomElementFromDict(_startingExteriorsDict)
		
		var interiorInstance = _startingInterior.instantiate()
		var exteriorInstance = selectedExterior.instantiate()
		add_child(interiorInstance)
		add_child(exteriorInstance)
		directions = exteriorInstance.directions
		
	else:
		var selectedInterior:PackedScene = _pickRandomElementFromDict(_roomsInteriorsDict)
		var selectedExterior:PackedScene = _pickRandomElementFromDict(_roomsExteriorsDict)
		
		var interiorInstance = selectedInterior.instantiate()
		var exteriorInstance = selectedExterior.instantiate()
		
		add_child(interiorInstance)
		add_child(exteriorInstance)
		directions = exteriorInstance.directions
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pickRandomElementFromDict(dictionary: Dictionary[PackedScene, int] = {}) -> PackedScene:
	var returnedElement:PackedScene
	var dictionaryKeys = dictionary.keys()
	var dictionaryValues = dictionary.values()
	var totalWeight:int = 0
	
	for i in dictionaryValues.size():
		totalWeight += dictionaryValues.get(i)
	
	var randomDictionaryWeight:int = randi_range(0, totalWeight)
	
	var weight:int = 0
	var count:int = 0
	for i in dictionaryValues.size():
		weight += dictionaryValues[i]
		if(weight >= randomDictionaryWeight):
			break
		count += 1
	
	returnedElement = dictionaryKeys.get(count)
	
	return returnedElement
