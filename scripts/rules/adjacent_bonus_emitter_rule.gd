extends BaseAlienRule
class_name AdjacentBonusEmitterRule

@export var bonus := 1
@export var required_type : GridManager.AlienType = GridManager.AlienType.NONE

# ==============================================================================
# PHASE 1: APPLY BUFFS (Turn Start)
# ==============================================================================
func on_turn_start(alien: Alien, grid: GridManager) -> void:
	if alien.grid == null:
		return
 
	for cell in alien.cells:
		var center : Vector2i = cell

		# Scan the radius
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				if abs(x) + abs(y) > radius: continue # Manhattan shape (Diamond)
				
				var target_cell : Vector2i = center + Vector2i(x, y)
				if !grid.is_cell_valid(target_cell): continue
				if target_cell == center: continue # Don't buff self

				var target : Alien = grid.get_occupant(target_cell)
				if target == null: continue
				if required_type != GridManager.AlienType.NONE and target.alien_type != required_type:
					continue

				# --- THE LOGIC ---
				
				# 1. CHECK THE SIGNATURE
				var current_source = target.memory.get("bard_source", null)
				
				# 2. RIVAL CHECK (Different Source = No Stack)
				# If someone signed it, and that someone is NOT me, I stop.
				if current_source != null and current_source != alien:
					continue 
				
				# 3. APPLY BONUS (Same Source = Stack)
				# If signature is null (New) or mine (Stacking), we proceed.
				target.external_production_bonus += bonus
				
				# 4. SIGN THE TARGET
				# We claim this alien so other Toads can't touch it this turn.
				target.memory["bard_source"] = alien

# ==============================================================================
# PHASE 2: CLEANUP (Turn End)
# ==============================================================================
func on_turn_end(alien: Alien, grid: GridManager) -> void:
	# We must erase our signatures so the target can be buffed again next turn.
	if alien.grid == null: return

	for cell in alien.cells:
		var occupant = grid.get_occupant(cell)
		if occupant == null or (required_type != GridManager.AlienType.NONE and occupant.alien_type != required_type) or occupant == alien:
			return  # Not the right type, do nothing

		var center : Vector2i = cell

		# Re-scan to find who we buffed
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				if abs(x) + abs(y) > radius: continue
				
				var target_cell : Vector2i = center + Vector2i(x, y)
				if !grid.is_cell_valid(target_cell): continue
				
				var target : Alien = grid.get_occupant(target_cell)
				if target == null: continue
				
				# Only erase MY signatures. Don't touch others.
				if target.memory.get("bard_source") == alien:
					target.memory.erase("bard_source")
