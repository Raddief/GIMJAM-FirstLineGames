extends Node2D
class_name AlienManager

@export var alien_scenes : Array[PackedScene]
@export var grid_manager : GridManager
@export var day_manager : DayManager

func spawn_alien(alien_data: AlienData):
	var cell : Vector2i = _find_empty_cell()
	if cell == null:
		print("No empty cell!")
		return

	var alien = alien_data.alien_scene.instantiate()
	add_child(alien)
	alien.setup(cell, grid_manager)

func _find_empty_cell():
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var cell := Vector2i(x, y)
			if !grid_manager.is_cell_occupied(cell):
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
