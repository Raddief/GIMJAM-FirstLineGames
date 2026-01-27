extends Node

var GUI:float = 0
signal volumeGUIchanged(value:float)

func _ready() -> void:
	GUI = 0
	connect("volumeGUIchanged", _update_audio)

func _update_audio(value:float):
	GUI = value
