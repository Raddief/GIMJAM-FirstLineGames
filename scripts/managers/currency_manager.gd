extends Node

signal currency_changed(value: int)

var currency := 0

func add(amount: int):
	currency += amount
	emit_signal("currency_changed", currency)

func spend(amount: int) -> bool:
	if currency < amount:
		return false
	currency -= amount
	emit_signal("currency_changed", currency)
	return true
