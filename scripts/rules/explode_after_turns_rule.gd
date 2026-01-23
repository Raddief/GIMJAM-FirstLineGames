extends BaseAlienRule
class_name ExplodeAfterTurnsRule

@export var explode_after := 3
var turns := 0

func on_turn_end(alien):
	turns += 1
	if turns >= explode_after:
		explode(alien)

func explode(alien):
	# efek contoh
	#GridManager.damage_area(alien.grid_pos, 1)
	alien.queue_free()
