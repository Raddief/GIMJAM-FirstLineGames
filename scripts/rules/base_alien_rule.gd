extends Resource
class_name BaseAlienRule

enum TileRange{
	NONE,
	CELL,
	ADJACENT,
	AREA
}

@export var tile_range: TileRange = TileRange.NONE
@export var radius := 1

# ==================================================
# CORE RULE EVALUATION
# ==================================================
# Return false jika kondisi rule TIDAK terpenuhi
# Alien tetap hidup & ada, tapi TIDAK PRODUKSI
func is_condition_met(alien, grid) -> bool:
	return true


# ==================================================
# MOVEMENT
# ==================================================
# Return false jika alien tidak boleh dipindah
func can_move(alien) -> bool:
	return true

func on_moved(alien) -> void:
	pass


# ==================================================
# LIFECYCLE
# ==================================================
func on_added(alien) -> void:
	pass

func on_removed(alien) -> void:
	pass


# ==================================================
# TURN FLOW
# ==================================================
# Dipanggil SETIAP turn sebelum ekonomi
func on_turn_start(alien, grid) -> void:
	pass

# Dipanggil SETIAP turn setelah ekonomi
func on_turn_end(alien, grid) -> void:
	for cell in alien.cells:
		if !grid.get_tile_state(cell) == GridManager.SpaceCondition.CLEAN:
			alien.kill()

# Dipanggil SETIAP akhir day
func on_day_end(alien, grid) -> void:
	pass

# ==================================================
# PRODUCTION MODIFIER
# ==================================================

# Return nilai tambahan (positif/negatif) untuk produksi alien per turn
func get_production_modifier(alien, grid) -> int:
	return 0

# ==================================================
# DEBUG / VISUAL
# ==================================================
# Untuk tint, icon, atau gizmo editor
func debug_visual(alien) -> void:
	pass
