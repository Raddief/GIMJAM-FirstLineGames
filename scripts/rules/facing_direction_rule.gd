extends BaseAlienRule
class_name FacingDirectionRule

enum Facing { LEFT, RIGHT }
@export var required_facing: Facing

func is_condition_met(alien, _grid) -> bool:
	return alien.facing == required_facing
