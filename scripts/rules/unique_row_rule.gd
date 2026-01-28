extends BaseAlienRule
class_name Rule_UniqueRow

# If true, it checks 'alien_name'. If false, it checks 'alien_type'.
@export var strict_name_check: bool = true

func on_turn_start(alien: Alien, grid: GridManager) -> void:
	if not is_instance_valid(alien) or not alien.alive:
		return

	# 1. IDENTIFY ALL ROWS I OCCUPY
	# We use a Dictionary as a "Set" to store unique Row numbers
	var my_rows = {}
	for cell in alien.cells:
		var abs_y = cell.y
		my_rows[abs_y] = true # Mark this row as "Mine"

	# 2. SCAN THOSE ROWS FOR RIVALS
	for row_y in my_rows.keys():
		
		# Iterate through the entire width of the grid for this specific row
		for x in range(grid.grid_size.x):
			var check_cell = Vector2i(x, row_y)
			
			# Optimization: Don't check my own cell(s)
			# (We rely on identity check later, so simple bounds check is fine)
			if alien.cells.has(check_cell):
				continue
			var rival = grid.get_occupant(check_cell)
			
			if rival != null and rival != alien:
				# 3. CHECK SPECIES MATCH
				var is_same_species = false
				
				if strict_name_check:
					is_same_species = (rival.alien_name == alien.alien_name)
				else:
					is_same_species = (rival.alien_type == alien.alien_type)
				
				if is_same_species:
					# 4. CONFLICT FOUND: EXECUTE JUDGMENT
					print("Conflict! ", alien.alien_name, " vs ", rival.alien_name, " in Row ", row_y)
					_resolve_conflict(alien, rival)
					
					# If I died in the conflict, stop checking rows.
					if not is_instance_valid(alien) or not alien.alive:
						return

func _resolve_conflict(me: Alien, other: Alien):
	# "Random one of them dies"
	if randf() > 0.5:
		print(me.alien_name, " lost the duel and died.")
		me.kill()
	else:
		print(other.alien_name, " lost the duel and died.")
		other.kill()
