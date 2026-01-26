extends BaseAlienRule
class_name EatTargetRule

func on_turn_end(alien: Alien, grid: GridManager) -> void:
	# 1. Check for list
	if not alien.memory.has("targets"): return
	
	var victims = alien.memory["targets"]
	if victims.is_empty(): return

	# 2. Iterate backwards (safest way to remove items from a list while processing)
	for i in range(victims.size() - 1, -1, -1):
		var victim = victims[i]
		
		if is_instance_valid(victim) and victim.alive:
			print(alien.name, " eats ", victim.name)
			victim.kill()
	
	# 3. Clear memory
	alien.memory.erase("targets")