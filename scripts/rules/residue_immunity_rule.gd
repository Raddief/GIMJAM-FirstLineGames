extends BaseAlienRule
class_name ResidueImmunityRule

@export var immune_residue: GridManager.SpaceCondition = GridManager.SpaceCondition.TOXIC

func on_turn_end(alien, grid) -> void:
	for cell in alien.cells:
		if grid.get_tile_state(cell) == immune_residue:
			# Alien is immune to residue, do nothing
			return
		else:
			# If not on immune residue, apply normal rules
			super.on_turn_end(alien, grid)
