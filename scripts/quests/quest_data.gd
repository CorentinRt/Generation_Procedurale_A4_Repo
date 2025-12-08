class_name QuestData extends Resource

enum QuestType{
	COMBAT,
	ITEM,
	ADD_SCORE
}

@export var quest_type: QuestType
@export var quest_name: String = "QuestName"
@export var quest_name_after_target: String = "QuestName"
@export var add_score_on_completed: int = 30000
@export var can_fail: bool = false
@export var remove_score_on_failed: int = 10000
@export var timer_time: int = 0
