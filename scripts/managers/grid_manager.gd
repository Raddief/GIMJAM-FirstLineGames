extends Node2D
class_name GridManager

# ===== CONFIG =====
@export var grid_size: Vector2i = Vector2i(5, 5)
@export var tilemap: TileMapLayer
@export var tileset_source_id: int = 0 # biasanya 0 kalau cuma 1 source

# ===== TILE STATE =====
enum SpaceCondition {
	CLEAN,
	SLIME,
	RADIATION,
	HEAT,
	VACUUM
}

enum AlienType {
	NONE,
	FARMER,
	SLIME,
	QUEEN,
	PREDATOR
}

# TileState -> Atlas Coordinate
var TILE_ATLAS := {
	SpaceCondition.CLEAN: Vector2i(0, 0),
	SpaceCondition.SLIME: Vector2i(1, 0),
	SpaceCondition.RADIATION: Vector2i(2, 0),
	SpaceCondition.HEAT: Vector2i(3, 0),
	SpaceCondition.VACUUM: Vector2i(0, 1)
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

# ===== OCCUPATION =====
func is_cell_occupied(cell: Vector2i) -> bool:
	return occupied.has(cell)

func get_occupant(cell: Vector2i):
	return occupied.get(cell, null)

func occupy_cell(cell: Vector2i, alien):
	occupied[cell] = alien

func free_cell(cell: Vector2i):
	occupied.erase(cell)

# ===== DEBUG INPUT (OPTIONAL) =====
func _input(event):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		var cell := world_to_cell(event.position)
		if is_cell_valid(cell):
			#set_tile_state(cell, SpaceCondition.SLIME)
			pass
