extends Node2D
class_name Alien

# ===== CONFIG =====
@export var alien_name := "Alien"
@export var alien_type: GridManager.AlienType
@export var cost: int = 5
@export var production_per_turn: int = 1
@export var size: Vector2i

# Rules attached to this alien
@export var rules: Array[BaseAlienRule] = []

@onready var area_2d: Area2D = $Area2D

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

var external_production_bonus := 0

# ===== SETUP =====
func setup(start_cell: Vector2i, grid_manager: GridManager):
	grid = grid_manager

	cell = start_cell
	original_cell = cell
	position = grid.cell_to_world(cell)

	grid.occupy_cell(cell, size, self)

	for rule in rules:
		rule.on_added(self)

# ===== INPUT =====
# ===== INPUT =====
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 1. Use GLOBAL mouse position to match World Coordinates
				var mouse_world_pos = get_global_mouse_position()
				
				if _is_mouse_on_self(mouse_world_pos):
					start_drag(mouse_world_pos)
					
					# 2. CRITICAL: Consume the event!
					# This tells Godot: "I took this click. Don't send it to the other aliens."
					get_viewport().set_input_as_handled()
					
			elif !event.pressed and dragging:
				# Mouse Up logic remains the same
				end_drag()

	elif event is InputEventMouseMotion and dragging:
		# Use global position for smoother dragging with cameras
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

# === DEBUG PRINTS ===
	print("Attempting drop at: ", target_cell)
	if grid.is_cell_occupied(target_cell, size, self):
		print("FAIL: Cell ", target_cell, " is occupied by: ", grid.get_occupant(target_cell))
# ====================

	if grid.is_cell_valid(target_cell) and !grid.is_cell_occupied(target_cell, size, self):
		move_to_cell(target_cell)
	else:
		move_to_cell(original_cell)

# ===== MOVE =====
func move_to_cell(target_cell: Vector2i):
	grid.free_cell(cell, size)
	cell = target_cell
	grid.occupy_cell(cell, size, self)

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

	var bonus_production := 0
	for rule in rules:
		bonus_production += rule.get_production_modifier(self, grid)

	# Rule hook before economy
	for rule in rules:
		rule.on_turn_start(self, grid)

	# Economy
	if can_produce:
		CurrencyManager.add(production_per_turn + bonus_production + external_production_bonus)

	external_production_bonus = 0
	
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
	grid.free_cell(cell, size)

	for rule in rules:
		rule.on_removed(self)

	queue_free()

# ===== HIT TEST =====
func _is_mouse_on_self(mouse_pos: Vector2) -> bool:
	# 3. Dynamic Hitbox Size
	# Your old code hardcoded 64x64. This failed for 2x1 or 1x3 aliens.
	# We calculate the rect based on the 'size' variable you exported.
	
	# Assuming your sprite anchor is Top-Left based on your grid logic:
	var alien_width = size.x * 64 # Assuming 64 is tile size
	var alien_height = size.y * 64
	
	# If your sprites are centered, you need to offset the Rect. 
	# Based on your previous 'global_position - Vector2(32, 32)', 
	# it seems your pivot is the Center of the first tile. 
	
	# This creates a rect starting at top-left of the sprite
	var top_left = global_position - Vector2(32, 32)
	var rect_size = Vector2(alien_width, alien_height)
	
	var rect := Rect2(top_left, rect_size)
	
	return rect.has_point(mouse_pos)

# ===== DEBUG VISUAL =====
func _process(_delta):
	if !can_produce:
		modulate = Color(1, 0.5, 0.5) # merah = tidak produksi
	else:
		modulate = Color.WHITE

	for rule in rules:
		rule.debug_visual(self)
