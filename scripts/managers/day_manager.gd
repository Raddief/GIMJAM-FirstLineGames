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
signal day_fail(condition: bool)
signal turn_changed(turn_left: int, max_turns: int)
signal turn_consumed(current: int, total: int) # Logic only

# ===== DAY FLOW =====
func start_day(index: int):
	if index >= days.size():
		print("ALL DAYS CLEARED!")
		return

	current_day_index = index
	current_day = days[index]
	current_turn = 1

	for modifier in current_day.day_modifiers:
		active_modifiers.append(modifier)

	emit_signal("day_started", current_day)
	emit_signal("turn_changed", current_turn, current_day.total_turns)

	print("Start", current_day.day_name)

func end_day():
	var quota = current_day.money_target
	var success = CurrencyManager.spend(quota)
	emit_signal("day_ended", current_day)

	active_modifiers.clear()

	if success:
		start_day(current_day_index + 1)
	else:
		emit_signal("day_fail")

# ===== TURN FLOW =====
func consume_turn():
	current_turn += 1
	emit_signal("turn_changed", current_turn, current_day.total_turns) # Update UI
	emit_signal("turn_consumed", current_turn, current_day.total_turns) # Triggers Aliens

	if current_turn >= current_day.total_turns:
		end_day()

# ===== MONEY API =====
func on_money_changed(value: int):
	money = value
