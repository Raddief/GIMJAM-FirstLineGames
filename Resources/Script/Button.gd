extends Button

#Variable Slot
var type:int = 0 #0 = Alien 1 = Items
var object : AlienData = null
var slot:bool = false
var root = null

signal select_slot(type:int, object)

func _ready() -> void:
	AudioManager.connect("volumeGUIchanged", _volume_changed)

func _volume_changed(value:float):
	$Sfx.set_volume_db(value)

func _on_mouse_entered() -> void:
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_hover2.mp3"))
	$Sfx.play()

func _on_pressed() -> void:
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_click1.mp3"))
	$Sfx.play()
	if slot and root != null:
		emit_signal("select_slot", type, object)
		root.showDesc(type, object)

# This function triggers when Godot detects a drag attempt on this button
func _get_drag_data(at_position):
	# This is Godot's built-in Drag & Drop system
	# But since you are using a custom "Ghost" system:
	
	root.spawn_ghost_alien(object) # Call the function in Shop.gd
	return null # Return null so Godot doesn't try to create its own drag preview
