extends BaseAlienRule
class_name CornerVisualRule

@export var bonus_production := 1
@export var offset_amount := 12 # Pixels to shift

# We use on_added to capture the "Default" state before we mess with it
func on_added(alien: Alien) -> void:
	_save_defaults(alien)
	_apply_corner_visuals(alien)

# We use on_moved to update (or reset) the visuals when dragged
func on_moved(alien: Alien) -> void:
	_save_defaults(alien) # Ensure defaults are saved if added late
	_apply_corner_visuals(alien)

func get_production_modifier(alien, grid) -> int:
	if _get_corner_type(alien.cell, grid) != -1:
		return bonus_production
	return 0

# ==============================================================================
# VISUAL LOGIC
# ==============================================================================
func _save_defaults(alien: Alien):
	# Only save if we haven't already. 
	# This ensures "base_sprite_pos" is the clean, original position.
	if not alien.memory.has("base_sprite_pos"):
		alien.memory["base_sprite_pos"] = alien.sprite.position
		alien.memory["base_flip"] = alien.sprite.flip_h

func _apply_corner_visuals(alien: Alien):
	if alien.grid == null: return
	
	var base_pos = alien.memory.get("base_sprite_pos", alien.sprite.position)
	var base_flip = alien.memory.get("base_flip", false)
	
	var corner_type = _get_corner_type(alien.cell, alien.grid)
	
	match corner_type:
		0: # TOP LEFT (0, 0) -> Offset (-12, 12) & FLIP
			alien.sprite.position = base_pos + Vector2(-offset_amount, -offset_amount)
			alien.sprite.flip_h = !base_flip # Invert flip status
			
		1: # TOP RIGHT (Max, 0) -> Offset (+12, 12)
			alien.sprite.position = base_pos + Vector2(offset_amount, -offset_amount)
			alien.sprite.flip_h = base_flip
			
		2: # BOTTOM LEFT (0, Max) -> Offset (-12, -12) & FLIP
			alien.sprite.position = base_pos + Vector2(-offset_amount, offset_amount)
			alien.sprite.flip_h = !base_flip
			
		3: # BOTTOM RIGHT (Max, Max) -> Offset (+12, -12)
			alien.sprite.position = base_pos + Vector2(offset_amount, offset_amount)
			alien.sprite.flip_h = base_flip
			
		_: # NOT A CORNER -> Reset
			alien.sprite.position = base_pos
			alien.sprite.flip_h = base_flip

# ==============================================================================
# HELPERS
# ==============================================================================
# Returns: 0=TL, 1=TR, 2=BL, 3=BR, -1=None
func _get_corner_type(cell: Vector2i, grid) -> int:
	var max_x : int = grid.grid_size.x - 1
	var max_y : int = grid.grid_size.y - 1

	if cell.x == 0 and cell.y == 0: return 0         # Top Left
	if cell.x == max_x and cell.y == 0: return 1     # Top Right
	if cell.x == 0 and cell.y == max_y: return 2     # Bottom Left
	if cell.x == max_x and cell.y == max_y: return 3 # Bottom Right
	
	return -1
