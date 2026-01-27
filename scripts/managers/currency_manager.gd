extends Node

signal currency_changed(value: int)

var currency := 0
var GoldGainDay := 0
var GoldSpendDay := 0
var TotalGold := 0

signal AlienPurchased(bool)

func add(amount: int):
	currency += amount
	TotalGold += amount
	GoldGainDay += amount
	emit_signal("currency_changed", currency)

func spend(amount: int) -> bool:
	if currency < amount:
		return false
	currency -= amount
	GoldSpendDay += amount
	emit_signal("currency_changed", currency)
	return true
