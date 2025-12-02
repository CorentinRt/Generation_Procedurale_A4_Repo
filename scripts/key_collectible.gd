extends CollectibleBase

@export var _scores_datas : Scores_Datas

func on_collect() -> void:
	super()
	Player.Instance.key_count += 1
	ScoreManager._add_score(_scores_datas._key_collect)


func _on_body_entered(body:Node2D) -> void:
	super(body)
