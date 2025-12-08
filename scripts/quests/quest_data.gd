class_name QuestData extends Resource

enum QuestType{
	COMBAT,
	ITEM
}

@export var quest_type: QuestType
@export var is_completed: bool = false
@export var custom_value: int = 0
@export var quest_name: String = "QuestName"
