class_name Shop_UI extends Control

static var Instance : Shop_UI

@export var data_shop : Shop_Data

@export_group("Buttons")
@export var btn_bonus_attack : Button
@export var btn_bonus_defense : Button
@export var btn_potion_attack : Button
@export var btn_potion_defense : Button
@export var btn_coin : Button

func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
		
	_hide_shop_ui()
	
func _bind_btns() -> void:
	btn_bonus_attack.pressed.connect(_buy_bonus_attack)
	btn_bonus_defense.pressed.connect(_buy_bonus_defense)
	btn_potion_attack.pressed.connect(_buy_potion_attack)
	btn_potion_defense.pressed.connect(_buy_potion_defense)
	btn_coin.pressed.connect(_buy_coin)
	
func _buy_bonus_attack() -> void:
	if ScoreManager._score > data_shop.bonus_attack_price:
		ScoreManager._remove_score(data_shop.bonus_attack_price)
		Player.Instance.bonus_attack_count += 1
	
func _buy_bonus_defense() -> void:
	if ScoreManager._score > data_shop.bonus_defense_price:
		ScoreManager._remove_score(data_shop.bonus_defense_price)
		Player.Instance.bonus_defense_count += 1
	
func _buy_potion_attack() -> void:
	if ScoreManager._score > data_shop.potion_attack_price:
		ScoreManager._remove_score(data_shop.potion_attack_price)
		Player.Instance.potion_attack_count += 1
	
func _buy_potion_defense() -> void:
	if ScoreManager._score > data_shop.potion_defense_price:
		ScoreManager._remove_score(data_shop.potion_defense_price)
		Player.Instance.potion_defense_count += 1
	
func _buy_coin() -> void:
	if ScoreManager._score > data_shop.coin_price:
		ScoreManager._remove_score(data_shop.coin_price)
		Player.Instance.coins_count += 1
	
func _show_shop_ui() -> void:
	$Container.visible = true
	
func _hide_shop_ui() -> void:
	$Container.visible = false
