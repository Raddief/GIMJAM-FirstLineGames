extends BaseAlienRule
class_name CornerProductionRule

@export var bonus_production := 1
@export var require_clean_corner := false

func is_condition_met(alien, grid) -> bool:
	if grid == null:
		return false

	return _is_corner(alien.cell, grid)

func allow_production(alien) -> bool:
	# Always allow base production
	return true

func get_production_modifier(alien, grid) -> int:
	if is_condition_met(alien, grid):
		return bonus_production
	return 0

func _is_corner(cell: Vector2i, grid) -> bool:
	var max_x : int = grid.grid_size.x - 1
	var max_y : int = grid.grid_size.y - 1

	return (
		(cell.x == 0 and cell.y == 0) or
		(cell.x == max_x and cell.y == 0) or
		(cell.x == 0 and cell.y == max_y) or
		(cell.x == max_x and cell.y == max_y)
	)

func debug_visual(alien):
	if alien.grid and is_condition_met(alien, alien.grid):
		alien.modulate = Color(0.6, 1.0, 0.6)
