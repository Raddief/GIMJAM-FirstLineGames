extends Resource
class_name DayData

@export var day_name: String = "Day 1"
@export var total_turns: int = 5
@export var money_target: int = 100

@export var day_modifiers: Array[BaseDayModifier] = []

# Optional future expansion
@export var sell_price_multiplier: float = 1.0
