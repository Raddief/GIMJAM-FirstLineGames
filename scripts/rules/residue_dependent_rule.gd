extends BaseAlienRule
class_name ResidueDependentRule

@export var required_residue: GridManager.SpaceCondition = GridManager.SpaceCondition.SLIME
@export var die_if_missing := false

func can_be_placed(alien, target_cell: Vector2i, grid) -> bool:
	return grid.get_tile_state(target_cell) == required_residue

func on_turn_start(alien):
	if die_if_missing:
		if alien.grid.get_tile_state(alien.cell) != required_residue:
			alien.kill()
