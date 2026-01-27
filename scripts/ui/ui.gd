extends Control
class_name UI

@onready var end_turn_button: Button = $EndTurnButton
@onready var currency_label: Label = $CurrencyLabel
@onready var day_label: Label = $TurnProgress/CenterContainer/DayLabel
@onready var turn_progress: ProgressBar = $TurnProgress

signal on_end_turn

var target_money := 0

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed():
	emit_signal("on_end_turn")

func on_day_started(day: DayData):
	day_label.text = str(day.day_name)
	target_money = day.money_target
	on_money_changed(CurrencyManager.currency)

func on_day_ended(day: DayData):
	day_label.text = str(day.day_name) + " (Ended)"

func on_turn_changed(turn: int, max_turns: int):
	turn_progress.set_value((turn-1)*25)

func on_money_changed(money: int):
	currency_label.text = " Credits : " + str(money) + "/" + str(target_money)
