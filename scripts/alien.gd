extends Node2D
class_name Alien

# ===== CONFIG =====
@export var alien_name := "Alien"
@export var alien_type : GridManager.AlienType
@export var cost : int = 5
@export var production_per_turn := 1

# Rules attached to this alien
@export var rules: Array[BaseAlienRule] = []

# ===== STATE =====
var cell: Vector2i
var current_turn := 0
var alive := true

# Facing (for direction-based rules)
enum Facing { LEFT, RIGHT }
var facing := Facing.RIGHT

# Drag state
var dragging := false
var drag_offset := Vector2.ZERO
var original_cell: Vector2i

var grid: GridManager

# ===== SETUP =====
func setup(start_cell: Vector2i, grid_manager: GridManager):
	grid = grid_manager

	if !can_be_placed(start_cell):
		queue_free()
		return

	cell = start_cell
	original_cell = cell
	position = grid.cell_to_world(cell)
	grid.occupy_cell(cell, self)

	for rule in rules:
		rule.on_added(self)

# ===== RULE QUERIES =====
func can_be_placed(target_cell: Vector2i) -> bool:
	for rule in rules:
		if !rule.can_be_placed(self, target_cell, grid):
			return false
	return true

func can_move() -> bool:
	for rule in rules:
		if !rule.can_move(self):
			return false
	return true

func get_space_usage() -> int:
	var space := 1
	for rule in rules:
		space = max(space, rule.occupy_space(self))
	return space

# ===== INPUT =====
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _is_mouse_on_self(event.position):
				start_drag(event.position)
			elif !event.pressed and dragging:
				end_drag()

	elif event is InputEventMouseMotion and dragging:
		position = get_global_mouse_position() - drag_offset

# ===== DRAG LOGIC =====
func start_drag(mouse_pos: Vector2):
	if !can_move():
		return

	dragging = true
	drag_offset = mouse_pos - global_position
	original_cell = cell
	z_index = 10

func end_drag():
	dragging = false
	z_index = 0

	var target_cell := grid.world_to_cell(global_position)

	if grid.is_cell_valid(target_cell) \
	and !grid.is_cell_occupied(target_cell) \
	and can_be_placed(target_cell):
		move_to_cell(target_cell)
	else:
		move_to_cell(original_cell)

# ===== MOVE =====
func move_to_cell(target_cell: Vector2i):
	grid.free_cell(cell)
	cell = target_cell
	grid.occupy_cell(cell, self)
	position = grid.cell_to_world(cell)

	for rule in rules:
		rule.on_moved(self)

# ===== TURN =====
func on_turn_passed():
	if !alive:
		return

	current_turn += 1

	# Rule hook BEFORE economy
	for rule in rules:
		rule.on_turn_start(self)

	# Economy (rule may block / modify this)
	if should_produce():
		CurrencyManager.add(production_per_turn)

	# Rule hook AFTER economy
	for rule in rules:
		rule.on_turn_end(self)

# ===== ECONOMY =====
func should_produce() -> bool:
	for rule in rules:
		if !rule.allow_production(self):
			return false
	return true

# ===== LIFECYCLE =====
func kill():
	alive = false
	grid.free_cell(cell)

	for rule in rules:
		rule.on_removed(self)

	queue_free()

# ===== HIT TEST =====
func _is_mouse_on_self(mouse_pos: Vector2) -> bool:
	var rect := Rect2(global_position - Vector2(32, 32), Vector2(64, 64))
	return rect.has_point(mouse_pos)

# ===== DEBUG VISUAL =====
func _process(_delta):
	for rule in rules:
		rule.debug_visual(self)
