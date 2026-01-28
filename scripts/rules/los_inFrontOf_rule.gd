extends BaseAlienRule
class_name LOSinFrontOfRule

@export var los_range: int = 3
@export var omnidirectional: bool = false 

func is_condition_met(alien: Alien, grid: GridManager) -> bool:
	var directions: Array[Vector2i]
	if grid == null:
		return false

	for cell in alien.cells:
		if omnidirectional:
			# Check all four directions
			directions = [
				Vector2i.RIGHT,
				Vector2i.LEFT,
				Vector2i.UP,
				Vector2i.DOWN
			]
		else:
			# Check only the facing direction
			match alien.facing:
				Alien.Facing.RIGHT:
					directions = [Vector2i.RIGHT]
				Alien.Facing.LEFT:
					directions = [Vector2i.LEFT]
				_:
					directions = [Vector2i.RIGHT] # Default

		for direction_vec in directions:
			for dist in range(1, los_range + 1):
				var target_cell: Vector2i = cell + direction_vec * dist
				if not grid.is_cell_valid(target_cell) or alien.cells.has(target_cell):
					break

				var target_alien: Alien = grid.get_occupant(target_cell)
				if target_alien != null and target_alien != alien:
					# Found an alien in line of sight
					if not _is_target_hidden(cell, target_alien):
						target_alien.kill()
						return true # Condition met
	return false

# Helper to check if the target's invisibility rules block our sight
func _is_target_hidden(looker_pos: Vector2i, target_alien: Alien) -> bool:
	# 1. Check if they even have the Invisibility Attribute
	if not target_alien.memory.has("invisibility_type"):
		return false # They are visible.

	var type = target_alien.memory["invisibility_type"]
	
	for cell in target_alien.cells:
		if cell == looker_pos:
			continue
	# Vector Math Prep
	var vector_to_target = Vector2(target_alien.cells[0] - looker_pos)
	var target_facing_vec = Vector2.RIGHT
	if target_alien.facing == Alien.Facing.LEFT:
		target_facing_vec = Vector2.LEFT

	match type:
		InvisibilityAttributeRule.InvisibilityType.FROM_BACK_RELATIVE:
			# Dot Product > 0 means vectors point in same direction (We are behind them)
			return vector_to_target.dot(target_facing_vec) > 0

		InvisibilityAttributeRule.InvisibilityType.FROM_FRONT_RELATIVE:
			# Dot Product < 0 means vectors point opposite (We are face-to-face)
			return vector_to_target.dot(target_facing_vec) < 0

		InvisibilityAttributeRule.InvisibilityType.FROM_LEFT_ABSOLUTE:
			# If Looker is physically to the LEFT (smaller X) of the target
			return looker_pos.x < target_alien.cell.x

		InvisibilityAttributeRule.InvisibilityType.FROM_RIGHT_ABSOLUTE:
			# If Looker is physically to the RIGHT (larger X) of the target
			return looker_pos.x > target_alien.cell.x

	return false
