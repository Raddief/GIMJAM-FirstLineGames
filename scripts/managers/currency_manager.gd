extends Node

signal currency_changed(value: int)

var currency := 0
var TotalGold := 0
var Tutorial:int = 1 #1 = belum tutorial, 2 = step2, 3 = step3,etc 8 = selesai

signal TutorialNext()
signal AlienPurchased(bool)

func add(amount: int):
	currency += amount
	TotalGold += amount
	emit_signal("currency_changed", currency)

func spend(amount: int) -> bool:
	if currency < amount:
		return false
	currency -= amount
	emit_signal("currency_changed", currency)
	return true
