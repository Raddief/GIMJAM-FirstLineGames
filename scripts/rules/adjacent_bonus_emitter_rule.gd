extends BaseAlienRule
class_name AdjacentBonusEmitterRule

@export var bonus := 1
@export var radius := 1
@export var required_type : GridManager.AlienType = GridManager.AlienType.NONE

func on_turn_start(alien, grid) -> void:
	if alien.grid == null:
		return

	var center : Vector2i = alien.cell

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if abs(x) + abs(y) > radius:
				continue

			var cell : Vector2i = center + Vector2i(x, y)
			if !alien.grid.is_cell_valid(cell):
				continue

			if cell == center:
				continue

			var other : Alien = alien.grid.get_occupant(cell)
			if other == null:
				continue

			if required_type != GridManager.AlienType.NONE \
			and other.alien_type != required_type:
				continue

			other.external_production_bonus += bonus
