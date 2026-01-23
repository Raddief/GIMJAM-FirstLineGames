extends Control

@onready var end_turn_button: Button = $EndTurnButton
@onready var currency_label: Label = $CurrencyLabel

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	CurrencyManager.currency_changed.connect(_on_currency_changed)

	# init text
	_on_currency_changed(CurrencyManager.currency)

func _on_end_turn_pressed():
	TurnManager.next_turn()

func _on_currency_changed(value: int):
	currency_label.text = "💰 " + str(value)
