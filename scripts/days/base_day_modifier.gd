extends Resource
class_name BaseDayModifier

func on_day_start(day_manager): pass
func on_day_end(day_manager): pass

func on_turn_start(day_manager): pass
func on_turn_end(day_manager): pass

func extra_production_trigger() -> int:
	return 0
