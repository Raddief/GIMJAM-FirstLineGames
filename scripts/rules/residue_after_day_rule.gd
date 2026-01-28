extends BaseAlienRule
class_name ResidueAfterDayRule

@export var residue_type: GridManager.SpaceCondition = GridManager.SpaceCondition.TOXIC
@export var overwrite_existing := false

func on_day_end(alien, grid):
	if grid == null:
		return

	match tile_range:
		TileRange.NONE:
			return
		TileRange.CELL:
			for cell in alien.cells:
				var tile_state = grid.get_tile_state(cell)
				if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
					grid.set_tile_state(cell, residue_type)
		TileRange.ADJACENT:
			for cell in alien.cells:
				for x in range(-radius, radius + 1):
					for y in range(-radius, radius + 1):
						var target_cell : Vector2i = cell + Vector2i(x, y)
						if alien.cells.has(target_cell):
							continue

						var tile_state = grid.get_tile_state(target_cell)
						if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
							grid.set_tile_state(target_cell, residue_type)
		TileRange.AREA:
			for cell in alien.cells:
				for x in range(-radius, radius + 1):
					for y in range(-radius, radius + 1):
						var target_cell : Vector2i = cell + Vector2i(x, y)
						if alien.cells.has(target_cell):
							continue

						var tile_state = grid.get_tile_state(target_cell)
						if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
							grid.set_tile_state(target_cell, residue_type)
