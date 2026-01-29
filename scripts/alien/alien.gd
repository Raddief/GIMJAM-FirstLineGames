extends Node2D
class_name Alien

# ===== CONFIG =====
@export var alien_name := "Alien"
@export var alien_type: GridManager.AlienType
@export var cost: int = 5
@export var production_per_turn: int = 1
@export var size: Vector2i
@export var spawn_audio: AudioStream
@export var face_agnostic: bool = false
@export var facecard: Texture2D
@export_category("SOUND")
@export var alien_move_sound : AudioStream
@export var alien_delete_sound : AudioStream

# CUSTOM SHAPE (Relative to 0,0). 
# Example L-Shape inside a 2x2 box: [(0,0), (0,1), (1,1)]
# If empty, we automatically generate a rectangle based on 'size'.
@export var custom_shape: Array[Vector2i] = []

# Rules attached to this alien
@export var rules: Array[BaseAlienRule] = []

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var sfx_player: AudioStreamPlayer = $SFX
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grass_particle: GPUParticles2D = $"Grass particle"
@onready var blood_particle: GPUParticles2D = $"Blood particle"

# ===== STATE =====
var cells: Array[Vector2i] = []   # Currently occupied cells
var alive := true
var can_produce := true

# Breathing State
var breath_state := 0        # 0 = shrinking, 1 = growing
var breath_vel := 0.0        # Current velocity of the scale change
var breath_accel := 0.0      # Speed at which velocity changes
var breath_max_vel := 0.0    # The limit for velocity

# Facing (for direction-based rules)
enum Facing { LEFT, RIGHT }
var facing := Facing.LEFT

var memory: Dictionary = {}

# Drag state
var dragging := false
var drag_offset := Vector2.ZERO
var original_cell: Vector2i

var grid: GridManager

var external_production_bonus := 0

# Shop Logic
var is_new_purchase := false

var mouse_over := false

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

func initialize_drag(grid_manager: GridManager):
	grid = grid_manager # 1. Fix the Null Crash
	if sprite:
		sprite.set_offset(Vector2(0, -64 * size.y))
		sprite.position += Vector2(0, 64 * size.y * sprite.scale.y)

func _ready() -> void:
	sfx_player.set_volume_db(AudioManager.GUI)
	AudioManager.connect("volumeGUIchanged", _on_gui_changed)

# ===== SETUP =====
func setup(start_cell: Vector2i, grid_manager: GridManager):
	self.set_z_index(2)
	grid = grid_manager
	cells = grid.occupy_cell(start_cell, get_shape_offsets(), self)
	original_cell = start_cell
	position = grid.cell_to_world(start_cell)

	for i in range(rules.size()):
		rules[i] = rules[i].duplicate(true)

	print("Setup called for: ", alien_name) # Debug 1
	
	grass_particle.emitting = true

	if spawn_audio == null:
		print("Warning: spawn_audio is missing on ", alien_name) # Debug 2
	
	if sfx_player == null:
		print("Error: AudioStreamPlayer2D node not found!") # Debug 3

	if spawn_audio and sfx_player:
		print("Playing sound now!") # Debug 4
		sfx_player.stream = spawn_audio
		sfx_player.play()

	for rule in rules:
		rule.on_added(self)
		
	# Initialize Breathing (RPG Maker Translation)
	var sprite_height = sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()
	
	# Logic: Smaller height = faster/larger relative pulse
	breath_accel = 0.00003 + (0.01 / sprite_height) + (randf() * 0.00001)
	breath_max_vel = 0.0006 + (0.25 / sprite_height)
	
	# Randomize start so they aren't all in sync
	breath_vel = randf_range(-breath_max_vel, breath_max_vel)

# ===== INPUT =====
func _input(event):
	if event is InputEventMouseButton:
		# 1. Use GLOBAL mouse position to match World Coordinates
		var mouse_world_pos = get_global_mouse_position()
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mouse_over:
					start_drag(mouse_world_pos)
					
					# 2. CRITICAL: Consume the event!
					# This tells Godot: "I took this click. Don't send it to the other aliens."
					get_viewport().set_input_as_handled()
					
			elif !event.pressed and dragging:
				# Mouse Up logic remains the same
				end_drag()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if mouse_over:
				toggle_flip_menu()
				get_viewport().set_input_as_handled()
		
	elif event is InputEventMouseMotion and dragging:
		# Use global position for smoother dragging with cameras
		position = get_global_mouse_position() - drag_offset

# ===== FLIP LOGIC =====
func toggle_flip_menu():
	# if face_agnostic or !flip_button:
	if face_agnostic:
		return
	
	# flip_button.visible = !flip_button.visible
	# Position the button slightly above the alien
	# flip_button.global_position = global_position
	flip_axis()

func _on_flip_button_pressed():
	if facing == Facing.LEFT:
		facing = Facing.RIGHT
		sprite.flip_h = true
	else:
		facing = Facing.LEFT
		sprite.flip_h = false
	
	# Notify rules that we flipped (useful for direction-based rules)
	for rule in rules:
		rule.on_moved(self)

func flip_axis():
	if facing == Facing.LEFT:
		facing = Facing.RIGHT
		sprite.flip_h = true
	else:
		facing = Facing.LEFT
		sprite.flip_h = false
	
	# Notify rules that we flipped (useful for direction-based rules)
	for rule in rules:
		rule.on_moved(self)

# ===== DRAG LOGIC =====
func start_drag(mouse_pos: Vector2):	
	if !can_move():
		return

	dragging = true
	drag_offset = mouse_pos - global_position
	original_cell = grid.world_to_cell(global_position)
	z_index = 10

func end_drag():
	dragging = false
	z_index = 2
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
		var can_afford = CurrencyManager.currency >= cost
		
		if is_valid_spot and can_afford:
			CurrencyManager.spend(cost)
			CurrencyManager.emit_signal("AlienPurchased")
			if CurrencyManager.Tutorial == 6 :
				CurrencyManager.emit_signal("TutorialNext")
			is_new_purchase = false
			setup(target_cell, grid)
		else:
			queue_free() # Delete if can't afford or spot is blocked
	else:
		# MOVEMENT LOGIC: Only check if the spot is valid (Moving is free!)
		if is_valid_spot:
			move_to_cell(target_cell)
			sfx_player.set_stream(alien_move_sound)
			sfx_player.play()
		else:
			move_to_cell(original_cell)
	
	

# ===== MOVE =====
func move_to_cell(target_cell: Vector2i):
	var shape = get_shape_offsets()
	grid.free_cell(cells)
	cells.clear()
	cells = grid.occupy_cell(target_cell, shape, self)

	position = grid.cell_to_world(target_cell)

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

	if !alive: 
		return
	
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
	grid.free_cell(cells)

	for rule in rules:
		rule.on_removed(self)
	$SFX.set_stream(alien_delete_sound)
	$SFX.play()
	blood_particle.emitting = true
	animated_sprite_2d.hide()
	area_2d.monitoring = false

	await get_tree().create_timer(1.0).timeout

	queue_free()

# ===== HIT TEST =====
func _on_area_2d_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false

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
		sprite.scale.y += breath_vel * speed_multiplier
		if breath_vel <= -breath_max_vel:
			breath_state = 1
	else:
		breath_vel += breath_accel * speed_multiplier
		sprite.scale.y += breath_vel * speed_multiplier
		if breath_vel >= breath_max_vel:
			breath_state = 0

	for rule in rules:
		rule.debug_visual(self)

func _on_gui_changed(value:float):
	$SFX.set_volume_db(value)
