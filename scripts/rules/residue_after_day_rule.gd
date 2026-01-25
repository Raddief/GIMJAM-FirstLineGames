extends BaseAlienRule
class_name ResidueAfterDayRule

@export var residue_type: GridManager.SpaceCondition = GridManager.SpaceCondition.SLIME
@export var affect_self_tile := true
@export var radius := 0
@export var overwrite_existing := false

func on_day_end(alien, grid):
	if grid == null:
		return

	var center: Vector2i = alien.cell

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var cell := center + Vector2i(x, y)

			if !grid.is_cell_valid(cell):
				continue

			if !affect_self_tile and cell == alien.cell:
				continue

			var current : GridManager.SpaceCondition = grid.get_tile_state(cell)

			if current != GridManager.SpaceCondition.CLEAN and !overwrite_existing:
				continue

			grid.set_tile_state(cell, residue_type)
