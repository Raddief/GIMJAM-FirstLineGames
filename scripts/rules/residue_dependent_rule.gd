extends BaseAlienRule
class_name ResidueDependentRule

@export var required_residue: GridManager.SpaceCondition = GridManager.SpaceCondition.SLIME
@export var die_if_missing := false

func is_condition_met(alien, grid) -> bool:
	return grid.get_tile_state(alien.cell) == required_residue

func on_turn_start(alien, grid):
	if die_if_missing and !is_condition_met(alien, grid):
		alien.kill()
