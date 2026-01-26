extends Button

#Variable Slot
var type:int = 0 #0 = Alien 1 = Items
var object : AlienData = null
var slot:bool = false
var root = null
var volume:int

signal select_slot(type:int, object)

func _on_mouse_entered() -> void:
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_hover1.mp3"))
	$Sfx.play()

func _on_pressed() -> void:
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_click1.mp3"))
	$Sfx.play()
	if slot and root != null:
		emit_signal("select_slot", type, object)
		root.showDesc(type, object)
