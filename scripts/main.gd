extends Node2D

@export var ui : UI
@export var shop: Shop
@export var day_manager: DayManager
@export var alien_manager: AlienManager
@export var popups: CenterContainer

func _ready():
	CurrencyManager.currency = 0
	CurrencyManager.TotalGold = 0
	shop.buyAlien.connect(buy_alien)
	
	CurrencyManager.currency_changed.connect(day_manager.on_money_changed)
	CurrencyManager.currency_changed.connect(ui.on_money_changed)

	day_manager.connect("day_started", ui.on_day_started)
	day_manager.connect("day_ended", ui.on_day_ended)
	day_manager.connect("day_ended", _on_day_ended)
	day_manager.connect("day_fail", _on_day_fail)
	day_manager.connect("turn_changed", ui.on_turn_changed)
	day_manager.connect("turn_consumed", _on_turn_passed)
	ui.on_end_turn.connect(day_manager.consume_turn)
	shop.connect("Forfeit", _on_forfeit)

	
	day_manager.start_day(0)
	CurrencyManager.add(500) # starting money

func buy_alien(alien_data: AlienData) -> void:
	if CurrencyManager.spend(alien_data.price):
		alien_manager.spawn_alien(alien_data)
		shop.TotalAliens += 1

func _on_turn_passed(turn: int, max_turns: int):
	alien_manager.on_turn_passed()

func _on_day_ended(day: DayData):
	alien_manager.on_day_ended()

func _on_day_fail():
	popups.GameOver(CurrencyManager.TotalGold, shop.TotalAliens)

func _on_forfeit():
	popups.Forfeit()
