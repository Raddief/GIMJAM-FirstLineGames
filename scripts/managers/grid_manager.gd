extends Node2D
class_name GridManager

# ===== CONFIG =====
@export var grid_size: Vector2i = Vector2i(10, 5)
@export var tilemap: TileMapLayer
@export var tileset_source_id: int = 0 # biasanya 0 kalau cuma 1 source

# ===== TILE STATE =====
enum SpaceCondition {
	CLEAN,
	TOXIC,
	HEAT,
	COLD
}

enum AlienType {
	NONE,
	TOXIC,
	SLIME,
	QUEEN,
	PREDATOR
}

# TileState -> Atlas Coordinate
var TILE_ATLAS := {
	SpaceCondition.CLEAN: Vector2i(0, 0),
	SpaceCondition.TOXIC: Vector2i(0, 0),
	SpaceCondition.HEAT: Vector2i(0, 0),
	SpaceCondition.COLD: Vector2i(0, 0)
}

# ===== DATA =====
var tiles: Dictionary = {}      # Dictionary<Vector2i, TileState>
var occupied: Dictionary = {}   # Dictionary<Vector2i, Alien>

# ===== LIFECYCLE =====
func _ready():
	if tilemap == null:
		push_error("GridManager: TileMapLayer not assigned!")
		return

	init_grid()
	draw_grid()

# ===== GRID INIT =====
func init_grid():
	tiles.clear()
	occupied.clear()

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			tiles[Vector2i(x, y)] = SpaceCondition.CLEAN

# ===== DRAW GRID =====
func draw_grid():
	tilemap.clear()

	for cell in tiles.keys():
		var state: int = tiles[cell]
		_draw_cell(cell, state)

func _draw_cell(cell: Vector2i, state: int):
	if !TILE_ATLAS.has(state):
		return

	tilemap.set_cell(
		cell,
		tileset_source_id,
		TILE_ATLAS[state]
	)

# ===== TILE STATE API =====
func set_tile_state(cell: Vector2i, state: int):
	if !tiles.has(cell):
		return

	tiles[cell] = state
	_draw_cell(cell, state)

func get_tile_state(cell: Vector2i) -> int:
	return tiles.get(cell, SpaceCondition.CLEAN)

# ===== VALIDATION =====
func is_cell_valid(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and cell.y >= 0 and
		cell.x < grid_size.x and
		cell.y < grid_size.y
	)

# ===== POSITION CONVERSION =====
func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local_pos := tilemap.to_local(world_pos)
	return tilemap.local_to_map(local_pos)

func cell_to_world(cell: Vector2i) -> Vector2:
	var local_pos := tilemap.map_to_local(cell)
	return tilemap.to_global(local_pos)

# ===== OCCUPATION AND VALIDATION =====

# NOW ACCEPTS 'offsets' (Array of Vector2i) instead of 'size'
func is_cell_occupied(origin: Vector2i, offsets: Array[Vector2i], ignore_occupant = null) -> bool:
	for offset in offsets:
		var cell = origin + offset

		# 1. Boundary Check
		if cell.x < 0 or cell.y < 0 or cell.x >= grid_size.x or cell.y >= grid_size.y:
			return true

		# 2. Occupancy Check
		if occupied.has(cell):
			var current_occupant = occupied[cell]
			
			# Clean Ghosts
			if current_occupant == null or not is_instance_valid(current_occupant):
				occupied.erase(cell)
				continue 

			# Collision
			if current_occupant != ignore_occupant:
				return true 
					
	return false 

func get_occupant(cell: Vector2i):
	return occupied.get(cell, null) if occupied.get(cell, null) != null else null

# Locks specific cells based on offsets
func occupy_cell(origin: Vector2i, offsets: Array[Vector2i], alien) -> Array[Vector2i]:
	var occupied_cells: Array[Vector2i] = []
	for offset in offsets:
		var cell = origin + offset
		occupied[cell] = alien
		occupied_cells.append(cell)
	return occupied_cells

# Frees specific cells
func free_cell(cells: Array[Vector2i]):
	for cell in cells:
		occupied.erase(cell)

# ===== DEBUG INPUT (OPTIONAL) =====
func _input(event):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_RIGHT:

		var cell := world_to_cell(event.position)
		var tile_state := get_tile_state(cell)
		if is_cell_valid(cell):
			match tile_state:
				SpaceCondition.CLEAN:
					set_tile_state(cell, SpaceCondition.TOXIC)
				SpaceCondition.TOXIC:
					set_tile_state(cell, SpaceCondition.HEAT)
				SpaceCondition.HEAT:
					set_tile_state(cell, SpaceCondition.COLD)
				SpaceCondition.COLD:
					set_tile_state(cell, SpaceCondition.CLEAN)
