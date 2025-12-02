extends CollectibleBase

@export var _scores_datas : Scores_Datas

func on_collect() -> void:
	super()
	Player.Instance.life += 1
	ScoreManager._add_score(_scores_datas._heart_collect)
