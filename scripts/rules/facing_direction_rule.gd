extends BaseAlienRule
class_name FacingDirectionRule

enum Facing { LEFT, RIGHT }
@export var required_facing: Facing

func on_added(alien):
	if alien.facing != required_facing:
		alien.facing = required_facing
