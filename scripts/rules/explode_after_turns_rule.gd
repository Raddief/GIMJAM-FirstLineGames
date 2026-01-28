extends BaseAlienRule
class_name ExplodeAfterTurnsRule

@export var explode_after: int = 3
@export var explosion_radius: int = 1

var turns := 0

func on_turn_end(alien, grid) -> void:
	super.on_turn_end(alien, grid)
	
	turns += 1

	if turns >= explode_after:
		explode(alien, grid)

func explode(alien, grid) -> void:
	# Contoh efek: merusak alien lain di sekitar
	for dx in range(-explosion_radius, explosion_radius + 1):
		for dy in range(-explosion_radius, explosion_radius + 1):
			for cell in alien.cells:
				var target_cell : Vector2i = cell + Vector2i(dx, dy)
				if alien.cells.has(target_cell):
					continue

				if !grid.is_cell_valid(target_cell):
					continue

				var other = grid.get_alien_at(target_cell)
				if other and other != alien:
					other.kill()

	# Hancurkan diri sendiri
	alien.kill()
