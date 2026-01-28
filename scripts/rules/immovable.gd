extends BaseAlienRule
class_name Immovable

var is_locked := false

func can_move(alien) -> bool:
	return !is_locked

func on_turn_end(alien, grid) -> void:
	super.on_turn_end(alien, grid)
	is_locked = true
