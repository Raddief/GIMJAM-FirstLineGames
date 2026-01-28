extends BaseAlienRule
class_name Rule_Legendary

func on_added(alien: Alien) -> void:
	if alien.grid == null:
		return

	# 1. SEARCH FOR DUPLICATES
	# We need a list of UNIQUE aliens (because one alien occupies multiple tiles)
	var unique_aliens = []
	
	# Iterate through all occupied slots in the grid
	for occupant in alien.grid.occupied.values():
		if occupant != null and is_instance_valid(occupant):
			# Deduplicate: Only add to list if not already there
			if not occupant in unique_aliens:
				unique_aliens.append(occupant)

	# 2. COUNT MATCHES
	var count = 0
	for other in unique_aliens:
		# Check name (Strict) or Type (Loose), usually Legendary is by Name.
		if other.alien_name == alien.alien_name:
			count += 1

	# 3. JUDGMENT
	# Count will be at least 1 (Myself). If it is > 1, there is a clone.
	if count > 1:
		print("Legendary Rule Violated: " + alien.alien_name + " already exists!")
		_reject_placement(alien)

func _reject_placement(alien: Alien):
	# A. Refund the money
	# We assume CurrencyManager is globally accessible
	if alien.cost > 0:
		CurrencyManager.add(alien.cost)
		print("Refunded ", alien.cost)

	# B. Remove the illegal alien
	alien.kill()
