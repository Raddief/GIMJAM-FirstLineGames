extends BaseAlienRule
class_name Rule_PerimeterDeath

func on_turn_end(alien: Alien, grid: GridManager) -> void:
	if alien.grid == null or not alien.alive:
		return

	# 1. DEFINE PERIMETER (8 Directions for Omnidirectional)
	var directions = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]

	# 2. GET MY BODY PARTS
	# We need to calculate the world coordinate of every tile this alien occupies.
	for cell in alien.cells:
		# 3. SCAN PERIMETER
		var targets_to_kill = []
		for dir in directions:
			var target_cell = cell + dir
			
			# Don't check my own body (for L-shapes, or internal corners)
			if alien.cells.has(target_cell):
				continue
				
			if not grid.is_cell_valid(target_cell):
				continue
				
			var victim = grid.get_occupant(target_cell)
			
			# If there is someone there, and it's not me
			if victim != null and victim != alien:
				
				# 4. THE INVISIBILITY CHECK ("Unless...")
				# We pass 'body_part' as the looker_pos. 
				# This simulates "Sight from where they stand outwards".
				if _is_target_hidden(cell, victim):
					# They are physically there, but invisible to us.
					continue
				
				# Deduplicate (Prevent killing same guy twice if he touches 2 tiles)
				if not victim in targets_to_kill:
					targets_to_kill.append(victim)

		# 5. EXECUTE
		for victim in targets_to_kill:
			print(alien.alien_name, " sees and kills ", victim.alien_name)
			victim.kill()

# Helper to check if the target's invisibility rules block our sight
func _is_target_hidden(looker_pos: Vector2i, target_alien: Alien) -> bool:
	# 1. Check if they even have the Invisibility Attribute
	# (Assumes you are storing attributes in memory, or change to check rules)
	if not target_alien.memory.has("invisibility_type"):
		return false # They are visible.

	var type = target_alien.memory["invisibility_type"]
	
	# Vector Math Prep
	# Look Vector: From My specific Body Part -> To Their Pivot Cell
	# Note: For perfect accuracy on large targets, you might want to calculate 
	# vector to the specific tile touching you, but Pivot is usually sufficient.
	var vector_to_target = Vector2(target_alien.cells[0] - looker_pos)
	
	var target_facing_vec = Vector2.RIGHT
	if target_alien.facing == Alien.Facing.LEFT:
		target_facing_vec = Vector2.LEFT

	match type:
		InvisibilityAttributeRule.InvisibilityType.FROM_BACK_RELATIVE:
			# If we are looking at their back, dot product is > 0
			return vector_to_target.dot(target_facing_vec) > 0

		InvisibilityAttributeRule.InvisibilityType.FROM_FRONT_RELATIVE:
			# If we are looking at their face, dot product is < 0
			return vector_to_target.dot(target_facing_vec) < 0

		InvisibilityAttributeRule.InvisibilityType.FROM_LEFT_ABSOLUTE:
			# If Looker is physically to the LEFT (smaller X) of the target
			return looker_pos.x < target_alien.cells[0].x

		InvisibilityAttributeRule.InvisibilityType.FROM_RIGHT_ABSOLUTE:
			# If Looker is physically to the RIGHT (larger X) of the target
			return looker_pos.x > target_alien.cells[0].x

	return false
