extends Node
class_name DayManager

@export var days: Array[DayData]
@export var starting_money: int = 0

var current_day_index := 0
var current_turn := 0
var money := 0
var current_day: DayData

var active_modifiers: Array[Resource] = []

signal day_started(day: DayData)
signal day_ended(day: DayData)
signal turn_changed(turn_left: int, max_turns: int)

# ===== DAY FLOW =====
func start_day(index: int):
	if index >= days.size():
		print("ALL DAYS CLEARED!")
		return

	current_day_index = index
	current_day = days[index]
	current_turn = 0

	for modifier in current_day.day_modifiers:
		active_modifiers.append(modifier)

	emit_signal("day_started", current_day)
	emit_signal("turn_changed", current_turn, current_day.total_turns)

	print("Start", current_day.day_name)

func end_day():
	var success := money >= current_day.money_target
	emit_signal("day_ended", current_day)

	active_modifiers.clear()

	if success:
		start_day(current_day_index + 1)
	else:
		print("DAY FAILED")

# ===== TURN FLOW =====
func consume_turn():
	current_turn += 1
	emit_signal("turn_changed", current_turn, current_day.total_turns)

	if current_turn >= current_day.total_turns:
		end_day()

# ===== MONEY API =====
func on_money_changed(value: int):
	money = value
