extends Node2D
class_name AlienManager

@export var alien_scenes : Array[PackedScene]
@export var grid_manager : GridManager
@export var day_manager : DayManager

func spawn_alien(alien_data: AlienData):
	# 1. Instantiate FIRST to get the data (size)
	var alien = alien_data.alien_scene.instantiate()
	
	var shape_offsets: Array[Vector2i] = alien.get_shape_offsets()

	# 3. CHANGE: Pass the shape list to the finder
	var cell = _find_empty_cell(shape_offsets)
	
	# 4. Check for null (Cell not found)
	if cell == null:
		print("No empty cell for alien shape")
		alien.queue_free() # Delete the unused instance
		return

	add_child(alien)
	alien.setup(cell, grid_manager)

# Updated to accept SIZE and use the NEW GridManager function
func _find_empty_cell(shape_offsets: Array[Vector2i]):
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var cell := Vector2i(x, y)
			
			# CHANGE: Pass the array to the GridManager
			# The GridManager now iterates through this list to check validity
			if !grid_manager.is_cell_occupied(cell, shape_offsets, null):
				return cell
				
	return null

func on_turn_passed():
	var production_triggers := 1

	for modifier in day_manager.active_modifiers:
		if modifier.has_method("on_turn_passed"):
			modifier.on_turn_passed()
		if modifier.has_method("extra_production_trigger"):
			production_triggers += modifier.extra_production_trigger()
	for i in range(production_triggers):
		for alien in get_children():
			if alien.has_method("on_turn_passed"):
				alien.on_turn_passed()

func on_day_ended():
	for alien in get_children():
		if alien.has_method("on_day_ended"):
			alien.on_day_ended()
