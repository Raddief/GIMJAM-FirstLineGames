extends BaseAlienRule
class_name AdjacentPlacementRule

@export var required_type: GridManager.AlienType

func can_be_placed(alien, target_cell, grid) -> bool:
	for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var cell = target_cell + dir
		var other = grid.get_occupant(cell)
		if other and other.alien_type == required_type:
			return true
	return false
