extends BaseAlienRule
class_name ResidueDependentRule

@export var required_residue: GridManager.SpaceCondition = GridManager.SpaceCondition.TOXIC
@export var die_if_missing := false

func is_condition_met(alien, grid) -> bool:
	match tile_range:
		TileRange.NONE:
			return true
		TileRange.CELL:
			return grid.get_tile_state(alien.cell) == required_residue
		TileRange.ADJACENT:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					if abs(x) + abs(y) > radius:
						continue
					var cell : Vector2i = alien.cell + Vector2i(x, y)
					if grid.is_cell_valid(cell) and grid.get_tile_state(cell) == required_residue:
						return true
			return false
		TileRange.AREA:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					var cell : Vector2i = alien.cell + Vector2i(x, y)
					if grid.is_cell_valid(cell) and grid.get_tile_state(cell) == required_residue:
						return true
			return false
	return true

func on_turn_end(alien, grid) -> void:
	if die_if_missing and !is_condition_met(alien, grid):
		alien.kill()
