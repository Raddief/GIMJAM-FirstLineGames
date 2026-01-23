extends BaseAlienRule
class_name ResidueAfterDayRule

@export var residue_type: GridManager.SpaceCondition = GridManager.SpaceCondition.SLIME
@export var affect_self_tile := true
@export var radius := 0
@export var overwrite_existing := false

func on_turn_end(alien):
	if alien.grid == null:
		return

	var center : Vector2i = alien.cell

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var cell : Vector2i = center + Vector2i(x, y)
			if !alien.grid.is_cell_valid(cell):
				continue

			if !affect_self_tile and cell == alien.cell:
				continue
			
			var current : GridManager.SpaceCondition = alien.grid.get_tile_state(cell)

			if current != GridManager.SpaceCondition.CLEAN and !overwrite_existing:
				continue

			alien.grid.set_tile_state(cell, residue_type)
