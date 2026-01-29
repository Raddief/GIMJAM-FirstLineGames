extends Control
class_name UI

@onready var end_turn_button: Button = $EndTurnButton
@onready var currency_label: Label = $Progress/MarginCurrent/CurrencyLabel
@onready var quota : Label = $Progress/MarginQuota/Quota
@onready var progress_bar : ProgressBar = $Money
@onready var money_label: Label = $Money/CenterContainer/MoneyLabel
@onready var turn_bar : TextureProgressBar = $"Pen Lights/TextureProgressBar"

signal on_end_turn

var target_money := 0
signal NewDay(condition:bool)

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed():
	emit_signal("on_end_turn")

func on_day_started(day: DayData):
	# day_label.text = str(day.day_name)
	target_money = day.money_target
	on_money_changed(CurrencyManager.currency)
	progress_bar.max_value = target_money;

func on_day_ended(day: DayData):
	# day_label.text = str(day.day_name) + " (Ended)"
	print(str(day.day_name) + " (Ended)");

func on_turn_changed(turn: int, max_turns: int):
	match turn:
		1: turn_bar.set_value(25)
		2: turn_bar.set_value(41)
		3: turn_bar.set_value(57)
		4: turn_bar.set_value(100)
		_: turn_bar.set_value(0)
			
	# switch case. Turn 1: 25, Turn 2: 41, Turn 3: 37, Turn 4: 100

func on_money_changed(money: int):
	money_label.text = " Credits : " + str(money) + " / " + str(target_money)
	# quota.text = str(target_money)
	progress_bar.set_value(money)
	
