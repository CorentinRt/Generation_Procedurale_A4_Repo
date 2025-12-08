#class_name RandomRoom extends Node2D
#
#@export var _isStartingRoom:bool
#
#@export var coordinates:Vector2i
#var directions:Array[LevelGenerationUtils.Directions]
#
##@export var _startingRoom:PackedScene
##@export var _startingExteriorsDict:Dictionary[PackedScene, int] = {}
##@export var _roomsDict:Dictionary[PackedScene, int] = {}
##@export var _roomsExteriorsDict:Dictionary[RoomExteriorData, int] = {}
#@export var _door:PackedScene
#
#var _room:TileMapLayer
#
##func initRoom(dir:Array[LevelGenerationUtils.Directions] = []):
	##if(_isStartingRoom):
		###var selectedExterior:PackedScene = _pickRandomElementFromDict(_startingExteriorsDict)
		##var startingRoomInstance = _startingRoom.instantiate()
		##var possibleDirections:Array[LevelGenerationUtils.Directions] = [LevelGenerationUtils.Directions.EAST, LevelGenerationUtils.Directions.WEST]
		##_room = startingRoomInstance
		###var exteriorInstance = selectedExterior.instantiate()
		##add_child(startingRoomInstance)
		##_add_doors(_selectRandomDirFromArray(possibleDirections))
		###add_child(exteriorInstance)
		###directions = exteriorInstance.directions
	##else:
		##var roomInstance = _pickRandomElementFromDict(_roomsDict).instantiate()
		##_room = roomInstance
		##add_child(roomInstance)
		###directions = exteriorInstance.directions
		##_add_doors(dir)
#
	#
#func _add_doors(doorsDirections:Array[LevelGenerationUtils.Directions]):
	#var roomBounds:Rect2 = _room.get_used_rect()
	#var tileSize:Vector2i = _room.tile_set.tile_size
	#var isWidthEven:bool = false
	#var isHeightEven:bool = false
	#
	##Faire en sorte que si les directions sont vides, en selectionner aléatoirement
	#
	#if(int(roomBounds.size.x) % 2 == 0): isWidthEven = true
	#if(int(roomBounds.size.y) % 2 == 0): isHeightEven = true
	#
	#var offset:Vector2 = Vector2.ZERO
	#offset = tileSize / 2
	#
	#for dir in doorsDirections:
		#match dir:
			#LevelGenerationUtils.Directions.NORTH:
				#var yCoord:float = roomBounds.position.y - roomBounds.size.y / 2 + offset.y
				#if(isWidthEven):
					#_create_door(Vector2(roomBounds.position.x + offset.x, yCoord))
					#_create_door(Vector2(roomBounds.position.x - offset.x, yCoord))
				#else:
					#_create_door(Vector2(roomBounds.position.x, yCoord))
				#
				#directions.append(LevelGenerationUtils.Directions.NORTH)
			#LevelGenerationUtils.Directions.SOUTH:
				#var yCoord:float = roomBounds.position.y + roomBounds.size.y / 2 - offset.y
				#if(isWidthEven):
					#_create_door(Vector2(roomBounds.position.x + offset.x, yCoord))
					#_create_door(Vector2(roomBounds.position.x - offset.x, yCoord))
				#else:
					#_create_door(Vector2(roomBounds.position.x, yCoord))
					#
				#directions.append(LevelGenerationUtils.Directions.SOUTH)
			#LevelGenerationUtils.Directions.EAST:
				#var xCoord:float = roomBounds.position.x + roomBounds.size.x / 2 - offset.x
				#if(isHeightEven):
					#_create_door(Vector2(xCoord, roomBounds.position.y - offset.y))
					#_create_door(Vector2(xCoord, roomBounds.position.y + offset.y))
				#else:
					#_create_door(Vector2(xCoord, roomBounds.position.y))
					#
				#directions.append(LevelGenerationUtils.Directions.EAST)
			#LevelGenerationUtils.Directions.WEST:
				#var xCoord:float = roomBounds.position.x - roomBounds.size.x / 2 + offset.x
				#if(isHeightEven):
					#_create_door(Vector2(xCoord, roomBounds.position.y - offset.y))
					#_create_door(Vector2(xCoord, roomBounds.position.y + offset.y))
				#else:
					#_create_door(Vector2(xCoord, roomBounds.position.y))
					#
				#directions.append(LevelGenerationUtils.Directions.WEST)
#
#func _create_door(coord:Vector2) -> void:
	#var createdDoor:Node2D = _door.instantiate()
	#createdDoor.global_position = coord
	#add_child(createdDoor)
#
#func _selectRandomDirFromArray(dirs:Array[LevelGenerationUtils.Directions]) -> Array[LevelGenerationUtils.Directions]:
		#var dirsCopy = dirs.duplicate()
		#var returnedArray:Array[LevelGenerationUtils.Directions]
		#var randomCount:int = randi_range(1, dirs.size())
		#
		#while returnedArray.size() != randomCount:
			#var randomIndex:int = randi_range(0, dirsCopy.size() - 1)
			#var addedDir:LevelGenerationUtils.Directions = dirsCopy[randomIndex]
			#if(!returnedArray.has(addedDir)):
				#returnedArray.append(addedDir)
				#dirsCopy.erase(addedDir)
		#return returnedArray
