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
		var check_cell : Vector2i = alien.cell + dir
		var other = grid.get_occupant(check_cell)

		if other and other.alien_type == required_type:
			return true

	return false
