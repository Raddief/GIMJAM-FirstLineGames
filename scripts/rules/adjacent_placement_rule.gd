extends BaseAlienRule
class_name AdjacentPlacementRule

@export var required_type: GridManager.AlienType

func is_condition_met(alien, grid) -> bool:
	for dir in [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]:
		for cell in alien.cells:
			var check_cell : Vector2i = cell + dir
			var occupant = grid.get_occupant(check_cell)
			if occupant == null or occupant == alien:
				continue


			if occupant and occupant.alien_type == required_type:
				return true

	return false
