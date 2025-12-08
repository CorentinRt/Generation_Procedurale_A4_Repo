class_name QuestData extends Resource

enum QuestType{
	COMBAT,
	ITEM
}

@export var quest_type: QuestType
@export var quest_name: String = "QuestName"
@export var add_score_on_completed: int = 30000
@export var remove_score_on_failed: int = 10000
@export var can_fail: bool = false
