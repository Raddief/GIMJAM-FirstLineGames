extends BaseAlienRule
class_name TopRowProductionRule

@export var show_warning := true

func is_condition_met(alien, grid) -> bool:
	if grid == null:
		return false

	for cell in alien.cells:
		if cell.y == 0:
			return true
	return false

func allow_production(alien) -> bool:
	return is_condition_met(alien, alien.grid)

func debug_visual(alien):
	if !show_warning:
		return

	if alien.grid == null:
		return

	if !is_condition_met(alien, alien.grid):
		alien.modulate = Color(1.0, 0.6, 0.6)
	else:
		alien.modulate = Color(1.0, 1.0, 1.0)