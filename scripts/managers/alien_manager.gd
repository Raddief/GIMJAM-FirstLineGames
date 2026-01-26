extends Node2D
class_name AlienManager

@export var alien_scenes : Array[PackedScene]
@export var grid_manager : GridManager

	
func spawn_alien(scene: PackedScene):
	# 1. Instantiate FIRST to get the data (size)
	var alien = scene.instantiate()
	
	# 2. Assume the alien has a 'size' property (Vector2i)
	# If your alien script doesn't have this yet, add: var size := Vector2i(1,1)
	var required_size = alien.get("size") if "size" in alien else Vector2i(1, 1)

	# 3. Pass that size to the finder
	var cell = _find_empty_cell(required_size)
	
	# 4. Check for null (Cell not found)
	if cell == null:
		print("No empty cell for alien of size ", required_size)
		alien.queue_free() # Delete the unused instance
		return

	add_child(alien)
	alien.setup(cell, grid_manager)

# Updated to accept SIZE and use the NEW GridManager function
func _find_empty_cell(alien_size: Vector2i):
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var cell := Vector2i(x, y)
			
			# USE THE NEW FUNCTION YOU WROTE
			# We pass 'null' for the 3rd arg because the alien isn't on the grid yet
			if !grid_manager.is_cell_occupied(cell, alien_size, null):
				return cell
				
	return null # This is valid now because we didn't force-type the variable above

func on_turn_passed():
	for alien in get_children():
		if alien.has_method("on_turn_passed"):
			alien.on_turn_passed()

func on_day_ended():
	for alien in get_children():
		if alien.has_method("on_day_ended"):
			alien.on_day_ended()
