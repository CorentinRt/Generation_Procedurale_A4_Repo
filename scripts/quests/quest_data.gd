class_name QuestData extends Resource

enum QuestType{
	COMBAT,
	ITEM
}

@export var quest_type: QuestType
@export var quest_name: String = "QuestName"
