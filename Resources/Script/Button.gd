extends Button

@export var ui_hover_sound: AudioStream
@export var ui_click_sound: AudioStream

#Variable Slot
var type:int = 0 #0 = Alien 1 = Items
var object : AlienData = null
var slot:bool = false
var root = null

signal select_slot(type:int, object)

func _ready() -> void:
	call_deferred("_connect_audio_manager")

func _connect_audio_manager():
	if AudioManager:
		AudioManager.connect("volumeGUIchanged", _volume_changed)

func _volume_changed(value:float):
	$Sfx.set_volume_db(value)

func _on_mouse_entered() -> void:
	if ui_hover_sound:
		$Sfx.set_stream(ui_hover_sound)
		$Sfx.play()
	else:
		print("ui_hover_sound not found")

func _on_pressed() -> void:
	if ui_click_sound:
		$Sfx.set_stream(ui_click_sound)
		$Sfx.play()
		if CurrencyManager.Tutorial == 4 :
			CurrencyManager.emit_signal("TutorialNext")
		if slot and root != null:
			emit_signal("select_slot", type, object)
			root.showDesc(type, object)
	else:
		print("ui_click_sound not found")

# This function triggers when Godot detects a drag attempt on this button
func _get_drag_data(at_position):
	if object:
		root.spawn_ghost_alien(object) # Call the function in Shop.gd
	return null # Return null so Godot doesn't try to create its own drag preview
