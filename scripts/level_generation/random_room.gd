class_name RandomRoom extends Node2D

@export var coordinates:Vector2i
@export var doorsCount:int 

@export var _roomsInteriorsDict:Dictionary[PackedScene, int] = {}
@export var _roomsExteriorsDict:Dictionary[PackedScene, int] = {}

var _north:RandomRoom
var _south:RandomRoom
var _east:RandomRoom
var _west:RandomRoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var selectedInterior:PackedScene = _pickRandomElementFromDict(_roomsInteriorsDict)
	var selectedExterior:PackedScene = _pickRandomElementFromDict(_roomsExteriorsDict)
	
	var interiorInstance = selectedInterior.instantiate()
	var exteriorInstance = selectedExterior.instantiate()
	add_child(interiorInstance)
	add_child(exteriorInstance)
	
	doorsCount = exteriorInstance.get_meta("doorsCount")

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
