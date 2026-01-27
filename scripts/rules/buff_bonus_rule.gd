extends BaseAlienRule
class_name ModifyTargetBonusRule

@export var production_bonus: int = 1   # Set to negative for Debuff (e.g. -1)
@export var apply_to_self: bool = false # Should I buff myself too?

func on_turn_start(alien: Alien, grid: GridManager) -> void:
	# 1. CHECK MEMORY
	# If the trigger didn't find anyone, this list might be empty or missing.
	if not alien.memory.has("targets"):
		return
	
	var targets = alien.memory["targets"]
	
	# 2. APPLY STATS
	for target in targets:
		if is_instance_valid(target) and target.alive:
			target.external_production_bonus += production_bonus
			# print(alien.name, " gives ", production_bonus, " to ", target.name)
			
	# 3. OPTIONAL: SELF BUFF
	# Sometimes detecting an ally makes YOU work harder too
	if apply_to_self:
		alien.external_production_bonus += production_bonus
