extends BaseAlienRule
class_name ConditionalChainTrigger

# The Gatekeeper: This rule MUST be met for the others to happen.
@export var trigger_rule: BaseAlienRule

# The Payload: These rules only run if the trigger is met.
@export var chained_rules: Array[BaseAlienRule]

# CONFIGURATION
# If TRUE: When trigger fails, the alien STOPS producing entirely. (Strict Dependency)
# If FALSE: When trigger fails, the alien keeps working, but gets no bonuses from the chained rules. (Optional Bonus)
@export var stop_production_on_fail: bool = false

# ==================================================
# LOGIC GATING
# ==================================================

func is_condition_met(alien, grid) -> bool:
	# 1. Check the Trigger (e.g., "Can I see an enemy?")
	if trigger_rule and not trigger_rule.is_condition_met(alien, grid):
		# The trigger FAILED.
		
		# If strict, we report failure to the Alien (Alien stops producing).
		# If not strict, we report success (Alien continues, but skips chained rules below).
		return not stop_production_on_fail

	# 2. If Trigger Passed, check the chained rules
	for rule in chained_rules:
		if not rule.is_condition_met(alien, grid):
			return false # A chained rule failed
			
	return true

func get_production_modifier(alien, grid) -> int:
	# 1. Re-check Trigger (Gatekeeper)
	if trigger_rule and not trigger_rule.is_condition_met(alien, grid):
		return 0 # Trigger failed, so no bonuses from this chain.

	# 2. Sum up bonuses from chained rules
	var total_bonus = 0
	
	# Add the trigger's own bonus (if it has one)
	total_bonus += trigger_rule.get_production_modifier(alien, grid)
	
	# Add chained bonuses
	for rule in chained_rules:
		total_bonus += rule.get_production_modifier(alien, grid)
		
	return total_bonus

# ==================================================
# LIFECYCLE DELEGATION
# ==================================================
# We must forward all events to the children so they work correctly.

func on_added(alien) -> void:
	if trigger_rule: trigger_rule.on_added(alien)
	for rule in chained_rules:
		rule.on_added(alien)

func on_removed(alien) -> void:
	if trigger_rule: trigger_rule.on_removed(alien)
	for rule in chained_rules:
		rule.on_removed(alien)

func on_moved(alien) -> void:
	if trigger_rule: trigger_rule.on_moved(alien)
	for rule in chained_rules:
		rule.on_moved(alien)

func on_turn_start(alien, grid) -> void:
	# Only run turn logic if the trigger is currently valid
	if trigger_rule and not trigger_rule.is_condition_met(alien, grid):
		return
		
	if trigger_rule: trigger_rule.on_turn_start(alien, grid)
	for rule in chained_rules:
		rule.on_turn_start(alien, grid)

func on_turn_end(alien, grid) -> void:
	super.on_turn_end(alien, grid)
	
	if trigger_rule and not trigger_rule.is_condition_met(alien, grid):
		return

	if trigger_rule: trigger_rule.on_turn_end(alien, grid)
	for rule in chained_rules:
		rule.on_turn_end(alien, grid)
	
func debug_visual(alien) -> void:
	if trigger_rule: trigger_rule.debug_visual(alien)
	# We might want to see visuals even if it fails, or maybe not.
	# For now, let's show them all for debugging.
	for rule in chained_rules:
		rule.debug_visual(alien)
