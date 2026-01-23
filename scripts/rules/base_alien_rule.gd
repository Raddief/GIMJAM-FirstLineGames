extends Resource
class_name BaseAlienRule

# ===== PLACEMENT =====
func can_be_placed(alien, target_cell: Vector2i, grid) -> bool:
	return true

# ===== MOVEMENT =====
func can_move(alien) -> bool:
	return true

func on_moved(alien) -> void:
	pass

# ===== SPACE =====
func occupy_space(alien) -> int:
	return 1

# ===== TURN FLOW =====
func on_added(alien) -> void:
	pass

func on_removed(alien) -> void:
	pass

func on_turn_start(alien) -> void:
	pass

func on_turn_end(alien) -> void:
	pass

# ===== ECONOMY =====
func allow_production(alien) -> bool:
	return true

# ===== DEBUG / VISUAL =====
func debug_visual(alien) -> void:
	pass
