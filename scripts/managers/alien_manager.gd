extends Node2D
class_name AlienManager

@export var alien_scenes : Array[PackedScene]
@export var grid_manager : GridManager

func _ready() -> void:
		TurnManager.turn_passed.connect(_on_turn_passed)
	
func spawn_alien(scene: PackedScene):
	var cell : Vector2i = _find_empty_cell()
	if cell == null:
		print("No empty cell!")
		return

	var alien = scene.instantiate()
	add_child(alien)
	alien.setup(cell, grid_manager)

func _find_empty_cell():
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var cell := Vector2i(x, y)
			if !grid_manager.is_cell_occupied(cell):
				return cell
	return null

func _on_turn_passed():
	for alien in get_children():
		if alien.has_method("on_turn_passed"):
			alien.on_turn_passed()
