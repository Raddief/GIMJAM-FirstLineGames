extends Node2D

@export var ui : UI
@export var day_manager: DayManager
@export var alien_manager: AlienManager

func _ready():
	CurrencyManager.currency_changed.connect(day_manager.on_money_changed)
	CurrencyManager.currency_changed.connect(ui.on_money_changed)

	day_manager.connect("day_started", ui.on_day_started)
	day_manager.connect("day_ended", ui.on_day_ended)
	day_manager.connect("day_ended", _on_day_ended)
	day_manager.connect("turn_changed", ui.on_turn_changed)
	day_manager.connect("turn_changed", _on_turn_passed)

	ui.on_end_turn.connect(day_manager.consume_turn)

	
	day_manager.start_day(0)
	CurrencyManager.add(10) # starting money

func _on_turn_passed(turn: int, max_turns: int):
	alien_manager.on_turn_passed()

func _on_day_ended(day: DayData):
	alien_manager.on_day_ended()