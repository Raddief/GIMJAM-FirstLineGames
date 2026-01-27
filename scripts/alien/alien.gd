extends Node2D
class_name Alien

# ===== CONFIG =====
@export var alien_name := "Alien"
@export var alien_type: GridManager.AlienType
@export var cost: int = 5
@export var production_per_turn: int = 1
@export var size: Vector2i
@export var spawn_audio: AudioStream

# CUSTOM SHAPE (Relative to 0,0). 
# Example L-Shape inside a 2x2 box: [(0,0), (0,1), (1,1)]
# If empty, we automatically generate a rectangle based on 'size'.
@export var custom_shape: Array[Vector2i] = []

# Rules attached to this alien
@export var rules: Array[BaseAlienRule] = []

@onready var area_2d: Area2D = $Area2D
@onready var sfx_player: AudioStreamPlayer = $SFX

# ===== STATE =====
var cell: Vector2i
var alive := true
var can_produce := true

# Breathing State
var breath_state := 0        # 0 = shrinking, 1 = growing
var breath_vel := 0.0        # Current velocity of the scale change
var breath_accel := 0.0      # Speed at which velocity changes
var breath_max_vel := 0.0    # The limit for velocity

# Facing (for direction-based rules)
enum Facing { LEFT, RIGHT }
var facing := Facing.RIGHT

var memory: Dictionary = {}

# Drag state
var dragging := false
var drag_offset := Vector2.ZERO
var original_cell: Vector2i

var grid: GridManager

var external_production_bonus := 0

# Shop Logic
var is_new_purchase := false
var price := 10 # You can get this from your AlienData

# ===== HELPER: GET SHAPE =====
# This is the magic function that bridges the gap.
func get_shape_offsets() -> Array[Vector2i]:
	# 1. If we defined a custom shape in the inspector, use it.
	if not custom_shape.is_empty():
		return custom_shape
	
	# 2. Otherwise, generate a standard rectangle based on 'size'
	var offsets: Array[Vector2i] = []
	for x in range(size.x):
		for y in range(size.y):
			offsets.append(Vector2i(x, y))
	return offsets

# ===== SETUP =====
func setup(start_cell: Vector2i, grid_manager: GridManager):
	grid = grid_manager
	cell = start_cell
	original_cell = cell
	position = grid.cell_to_world(cell)

	print("Setup called for: ", alien_name) # Debug 1
	
	if spawn_audio == null:
		print("Warning: spawn_audio is missing on ", alien_name) # Debug 2
	
	if sfx_player == null:
		print("Error: AudioStreamPlayer2D node not found!") # Debug 3

	if spawn_audio and sfx_player:
		print("Playing sound now!") # Debug 4
		sfx_player.stream = spawn_audio
		sfx_player.play()
		
	# UPDATED: Use get_shape_offsets()
	grid.occupy_cell(cell, get_shape_offsets(), self)

	for rule in rules:
		rule.on_added(self)
		
	# Initialize Breathing (RPG Maker Translation)
	var sprite_height = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, 0).get_height()
	
	# Logic: Smaller height = faster/larger relative pulse
	breath_accel = 0.00003 + (0.01 / sprite_height) + (randf() * 0.00001)
	breath_max_vel = 0.0006 + (0.25 / sprite_height)
	
	# Randomize start so they aren't all in sync
	breath_vel = randf_range(-breath_max_vel, breath_max_vel)

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
	var overlaps = area_2d.get_overlapping_areas()

	for area in overlaps:
		# 2. If we touched an area tagged as "trash"
		if area.is_in_group("trash"):
			kill() # Die immediately
	
	var target_cell := grid.world_to_cell(global_position)
	var shape = get_shape_offsets()

	# Check if placement is valid and player has enough money
	var is_valid_spot = grid.is_cell_valid(target_cell) and !grid.is_cell_occupied(target_cell, shape, self)

	if is_new_purchase:
		# SHOP LOGIC: Must be a valid spot AND you must have the money
		var can_afford = CurrencyManager.currency >= price
		
		if is_valid_spot and can_afford:
			CurrencyManager.spend(price)
			CurrencyManager.emit_signal("AlienPurchased")
			is_new_purchase = false
			setup(target_cell, grid)
		else:
			queue_free() # Delete if can't afford or spot is blocked
	else:
		# MOVEMENT LOGIC: Only check if the spot is valid (Moving is free!)
		if is_valid_spot:
			move_to_cell(target_cell)
		else:
			move_to_cell(original_cell)
	
	

# ===== MOVE =====
func move_to_cell(target_cell: Vector2i):
	var shape = get_shape_offsets()
	grid.free_cell(cell, shape)
	cell = target_cell
	grid.occupy_cell(cell, shape, self)

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
	grid.free_cell(cell, get_shape_offsets())

	for rule in rules:
		rule.on_removed(self)

	queue_free()

# ===== HIT TEST =====
func _is_mouse_on_self(mouse_pos: Vector2) -> bool:
	# 3. Dynamic Hitbox Size
	# Your old code hardcoded 64x64. This failed for 2x1 or 1x3 aliens.
	# We calculate the rect based on the 'size' variable you exported.
	
	# Assuming your sprite anchor is Top-Left based on your grid logic:
	var alien_width = size.x * 128 # Assuming 64 is tile size
	var alien_height = size.y * 128
	
	# If your sprites are centered, you need to offset the Rect. 
	# Based on your previous 'global_position - Vector2(32, 32)', 
	# it seems your pivot is the Center of the first tile. 
	
	# This creates a rect starting at top-left of the sprite
	var top_left = global_position - Vector2(alien_width / 2.0, alien_height / 2.0)
	var rect_size = Vector2(alien_width, alien_height)
	
	var rect := Rect2(top_left, rect_size)
	
	return rect.has_point(mouse_pos)

# ===== DEBUG VISUAL =====
func _process(delta):
	# 1. PURCHASE GHOSTING
	if is_new_purchase:
		modulate.a = 0.5 
		var target_cell = grid.world_to_cell(global_position)
		if !grid.is_cell_valid(target_cell) or grid.is_cell_occupied(target_cell, get_shape_offsets(), self):
			modulate = Color(1, 0, 0, 0.5)
		else:
			modulate = Color(0, 1, 0, 0.5)
	else:
		# 2. NORMAL VISUAL FEEDBACK (Only runs after placement)
		modulate.a = 1.0 # Ensure it returns to opaque
		if !can_produce:
			modulate = Color(1, 0.5, 0.5) 
		else:
			modulate = Color.WHITE
			
	# Multiply by delta (usually ~0.016) to normalize speed
	var speed_multiplier = delta * 60.0 
	
	if breath_state == 0:
		breath_vel -= breath_accel * speed_multiplier
		scale.y += breath_vel * speed_multiplier
		if breath_vel <= -breath_max_vel:
			breath_state = 1
	else:
		breath_vel += breath_accel * speed_multiplier
		scale.y += breath_vel * speed_multiplier
		if breath_vel >= breath_max_vel:
			breath_state = 0
			
	# 2. VISUAL FEEDBACK (Your existing logic)
	if !can_produce:
		modulate = Color(1, 0.5, 0.5) 
	else:
		modulate = Color.WHITE

	for rule in rules:
		rule.debug_visual(self)
