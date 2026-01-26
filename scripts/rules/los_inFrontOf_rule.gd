extends BaseAlienRule
class_name LOSinFrontOfRule

@export var los_range: int = 3
@export var omnidirectional: bool = false 

func is_condition_met(alien: Alien, grid: GridManager) -> bool:
	if alien.grid == null: return false

	# 1. PREPARE MEMORY (Use an Array now!)
	alien.memory["targets"] = [] # Clear the list
	var found_any = false

	# 2. DETERMINE FACING & STARTING OFFSETS
	# We need to know where our "eyes" are.
	# If looking RIGHT, eyes are on the Right Edge (x + width).
	# If looking LEFT, eyes are on the Left Edge (x - 1).
	
	var direction = Vector2i.RIGHT
	var start_x_offset = alien.size.x # Default: Start checking from tile just outside right edge
	
	if alien.facing == Alien.Facing.LEFT:
		direction = Vector2i.LEFT
		start_x_offset = -1 # Start checking from tile just outside left edge

	# 3. MULTI-RAY LOOP (The "Tall Eyes" Logic)
	# We loop through the alien's HEIGHT so every vertical segment gets a look.
	for y_offset in range(alien.size.y):
		
		# For every row of height, we verify the LOS range
		for dist in range(los_range): # 0 to los_range-1
			# Wait! If start_x_offset is -1 (Left), we subtract dist. If Right, we add.
			# Let's simplify the math:
			
			# Calculate the exact tile to check
			# Base Y + current height offset
			var check_y = alien.cell.y + y_offset 
			
			# Base X + offset + (direction * distance)
			# Note: We use 'dist' (0, 1, 2) effectively as the step count
			var check_x = alien.cell.x
			if direction == Vector2i.RIGHT:
				check_x += alien.size.x + dist 
			else:
				check_x -= 1 + dist

			var target_cell = Vector2i(check_x, check_y)

			# A. Grid Bounds
			if not grid.is_cell_valid(target_cell): break

			# B. Check Content
			var target_alien = grid.get_occupant(target_cell)
			
			if target_alien != null and target_alien != alien:
				# FOUND ONE!
				
				# (Optional: Add InvisibleFromBehind Logic Here)
				if _is_target_hidden(alien.cell, target_alien):
						# We hit an alien, but we can't "see" it.
						# The LOS is blocked physically, but the condition fails.
						# We break the inner loop (can't see through them), 
						# but we don't return true.
						break
				
				# Avoid adding the same large alien twice if we hit its head AND legs
				if not target_alien in alien.memory["targets"]:
					alien.memory["targets"].append(target_alien)
					found_any = true
				
				# Do we stop this ray? Usually yes, X-ray vision is rare.
				break 

	return found_any

# Helper to check if the target's invisibility rules block our sight
func _is_target_hidden(looker_pos: Vector2i, target_alien: Alien) -> bool:
	# 1. Check if they even have the Invisibility Attribute
	if not target_alien.memory.has("invisibility_type"):
		return false # They are visible.

	var type = target_alien.memory["invisibility_type"]
	
	# Vector Math Prep
	var vector_to_target = Vector2(target_alien.cell - looker_pos)
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
