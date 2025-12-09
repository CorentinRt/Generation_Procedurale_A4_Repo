class_name RoomData extends Resource

@export var roomScene:PackedScene
var directions:Array[LevelGenerationUtils.Directions]
var tilemaps:Array[TileMapLayer]
var coordinates:Vector2i
var mergedTilemap:TileMapLayer
var roomNode:Room
