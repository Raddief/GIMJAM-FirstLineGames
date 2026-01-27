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
			var tile_state = grid.get_tile_state(alien.cell)
			if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
				grid.set_tile_state(alien.cell, residue_type)
		TileRange.ADJACENT:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					if abs(x) + abs(y) > radius or (x == 0 and y == 0):
						continue
					var cell : Vector2i = alien.cell + Vector2i(x, y)
					var tile_state = grid.get_tile_state(cell)
					if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
						grid.set_tile_state(cell, residue_type)
		TileRange.AREA:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					var cell : Vector2i = alien.cell + Vector2i(x, y)
					var tile_state = grid.get_tile_state(cell)
					if overwrite_existing or tile_state == GridManager.SpaceCondition.CLEAN:
						grid.set_tile_state(cell, residue_type)
