extends BaseAlienRule
class_name GrowAfterDayRule

@export var max_growth := 3
var growth := 1

func on_turn_end(alien):
	if growth < max_growth:
		growth += 1

func occupy_space(alien) -> int:
	return growth
