extends Node

signal turn_passed

var turn := 0

func next_turn():
	turn += 1
	emit_signal("turn_passed")
