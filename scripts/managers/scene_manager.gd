extends Node

@export var main_menu_scene : PackedScene
@export var game_scene : PackedScene

var current_scene: Node = null

func _ready():
	# Get the scene that Godot already loaded at startup
	current_scene = get_tree().current_scene


func change_scene(scene_path: String) -> void:
	var new_scene := load(scene_path)
	if new_scene == null:
		push_error("Scene not found: " + scene_path)
		return

	var new_scene_instance = new_scene.instantiate()

	# Remove old scene
	if current_scene:
		current_scene.queue_free()

	# Add new scene
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance
	current_scene = new_scene_instance

func change_scene_to_main_menu() -> void:
	change_scene(main_menu_scene.resource_path)

func change_scene_to_game() -> void:
	change_scene(game_scene.resource_path)
