extends BaseAlienRule
class_name ResidueDependentRule

@export var required_residue: GridManager.SpaceCondition = GridManager.SpaceCondition.TOXIC
@export var die_if_missing := false

func is_condition_met(alien, grid) -> bool:
	match tile_range:
		TileRange.NONE:
			return true
		TileRange.CELL:
			for cell in alien.cells:
				if grid.get_tile_state(cell) == required_residue:
					return true
			return false
		TileRange.ADJACENT:
			for cell in alien.cells:
				for x in range(-radius, radius + 1):
					for y in range(-radius, radius + 1):
						var target_cell : Vector2i = cell + Vector2i(x, y)
						if alien.cells.has(target_cell):
							continue
					
						if grid.is_cell_valid(target_cell) and grid.get_tile_state(target_cell) == required_residue:
							return true
			return false
		TileRange.AREA:
			for cell in alien.cells:
				for x in range(-radius, radius + 1):
					for y in range(-radius, radius + 1):
						var target_cell : Vector2i = cell + Vector2i(x, y)
						if alien.cells.has(target_cell):
							continue

						if grid.is_cell_valid(target_cell) and grid.get_tile_state(target_cell) == required_residue:
							return true
			return false
	return true

func on_turn_end(alien, grid) -> void:
	if die_if_missing and !is_condition_met(alien, grid):
		alien.kill()
