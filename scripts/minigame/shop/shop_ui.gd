class_name Shop_UI extends Control

static var Instance : Shop_UI

var associated_shop : Shop

@export var data_shop : Shop_Data

@export var to_hide : Array[Control]

@export_group("Buttons")
@export var btn_bonus_attack : Button
@export var btn_bonus_defense : Button
@export var btn_potion_attack : Button
@export var btn_potion_defense : Button
@export var btn_coin : Button
@export var btn_exit : Button

func _ready() -> void:
	if Instance == null:
		Instance = self
	else:
		queue_free()
		return
		
	_bind_btns()
	_hide_shop_ui()
	
func _bind_btns() -> void:
	btn_bonus_attack.pressed.connect(_buy_bonus_attack)
	btn_bonus_defense.pressed.connect(_buy_bonus_defense)
	btn_potion_attack.pressed.connect(_buy_potion_attack)
	btn_potion_defense.pressed.connect(_buy_potion_defense)
	btn_coin.pressed.connect(_buy_coin)
	btn_exit.pressed.connect(_exit_shop_ui)
	
func _buy_bonus_attack() -> void:
	if Player.Instance.has_bonus_attack:
		return
	if ScoreManager._score > data_shop.bonus_attack_price:
		ScoreManager._remove_score(data_shop.bonus_attack_price)
		Player.Instance.has_bonus_attack = true
		btn_bonus_attack.visible = false
		print("buy bonus attack")
	
func _buy_bonus_defense() -> void:
	if Player.Instance.has_bonus_defense:
		return
	if ScoreManager._score > data_shop.bonus_defense_price:
		ScoreManager._remove_score(data_shop.bonus_defense_price)
		Player.Instance.has_bonus_defense = true
		btn_bonus_defense.visible = false
		print("buy bonus defense")
	
func _buy_potion_attack() -> void:
	if Player.Instance.has_potion_attack:
		return
	if ScoreManager._score > data_shop.potion_attack_price:
		ScoreManager._remove_score(data_shop.potion_attack_price)
		Player.Instance.has_potion_attack = true
		btn_potion_attack.visible = false
		print("buy potion attack")
	
func _buy_potion_defense() -> void:
	if Player.Instance.has_potion_defense:
		return
	if ScoreManager._score > data_shop.potion_defense_price:
		ScoreManager._remove_score(data_shop.potion_defense_price)
		Player.Instance.has_potion_defense = true
		btn_potion_defense.visible = false
		print("buy potion defense")
	
func _buy_coin() -> void:
	if ScoreManager._score > data_shop.coin_price:
		ScoreManager._remove_score(data_shop.coin_price)
		Player.Instance.coins_count += 1
		print("buy coin")
	
func _show_shop_ui(shop : Shop) -> void:
	associated_shop = shop
	for i in to_hide:
		i.visible = true
		
	btn_potion_attack.visible = false if Player.Instance.has_potion_attack else true
	btn_potion_defense.visible = false if Player.Instance.has_potion_defense else true
	
	
func _hide_shop_ui() -> void:
	for i in to_hide:
		i.visible = false
	associated_shop = null

func _exit_shop_ui() -> void:
	if associated_shop != null:
		associated_shop._close_shop_display()
