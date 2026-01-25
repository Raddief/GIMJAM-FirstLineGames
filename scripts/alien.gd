extends Node2D
class_name Alien

# ===== CONFIG =====
@export var alien_name := "Alien"
@export var alien_type: GridManager.AlienType
@export var cost: int = 5
@export var production_per_turn: int = 1

# Rules attached to this alien
@export var rules: Array[BaseAlienRule] = []

# ===== STATE =====
var cell: Vector2i
var alive := true
var can_produce := true

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

	cell = start_cell
	original_cell = cell
	position = grid.cell_to_world(cell)

	grid.occupy_cell(cell, self)

	for rule in rules:
		rule.on_added(self)

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

	if grid.is_cell_valid(target_cell) and !grid.is_cell_occupied(target_cell):
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

# ===== RULE EVALUATION =====
func evaluate_rules():
	can_produce = true

	for rule in rules:
		if !rule.is_condition_met(self, grid):
			can_produce = false

# ===== TURN =====
func on_turn_passed():
	if !alive:
		return

	# Evaluate rule conditions FIRST
	evaluate_rules()

	# Rule hook before economy
	for rule in rules:
		rule.on_turn_start(self, grid)

	# Economy
	if can_produce:
		CurrencyManager.add(production_per_turn)

	# Rule hook after economy
	for rule in rules:
		rule.on_turn_end(self, grid)

func on_day_ended():
	if !alive:
		return

	for rule in rules:
		rule.on_day_end(self, grid)

# ===== MOVE PERMISSION =====
func can_move() -> bool:
	for rule in rules:
		if !rule.can_move(self):
			return false
	return true

# ===== LIFECYCLE =====
func kill():
	if !alive:
		return

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
	if !can_produce:
		modulate = Color(1, 0.5, 0.5) # merah = tidak produksi
	else:
		modulate = Color.WHITE

	for rule in rules:
		rule.debug_visual(self)
