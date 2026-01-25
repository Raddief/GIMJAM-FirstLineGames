extends BaseAlienRule
class_name ExplodeAfterTurnsRule

@export var explode_after: int = 3
@export var explosion_radius: int = 1

var turns := 0

func on_turn_end(alien, grid) -> void:
	turns += 1

	if turns >= explode_after:
		explode(alien, grid)

func explode(alien, grid) -> void:
	# Contoh efek: merusak alien lain di sekitar
	for dx in range(-explosion_radius, explosion_radius + 1):
		for dy in range(-explosion_radius, explosion_radius + 1):
			var cell : Vector2i = alien.cell + Vector2i(dx, dy)

			if !grid.is_cell_valid(cell):
				continue

			var other = grid.get_alien_at(cell)
			if other and other != alien:
				other.kill()

	# Hancurkan diri sendiri
	alien.kill()
