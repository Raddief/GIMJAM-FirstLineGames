extends BaseAlienRule
class_name InvisibilityAttributeRule

enum InvisibilityType {
	NONE,
	FROM_BACK_RELATIVE,   # Invisible if you sneak up behind them
	FROM_FRONT_RELATIVE,  # Invisible if you stand right in front of them
	FROM_LEFT_ABSOLUTE,   # Invisible to anyone standing on the West side of the map
	FROM_RIGHT_ABSOLUTE   # Invisible to anyone standing on the East side of the map
}

@export var type: InvisibilityType = InvisibilityType.FROM_BACK_RELATIVE

# When added to an alien, we simply TAG them in memory.
# This acts like a passive "Buff" or "Component".
func on_added(alien) -> void:
	alien.memory["invisibility_type"] = type

func on_removed(alien) -> void:
	alien.memory.erase("invisibility_type")
