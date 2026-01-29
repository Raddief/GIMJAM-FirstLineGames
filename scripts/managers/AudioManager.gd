extends Node

var GUI:float = 0
var BGM:float = 0

signal volumeBGMchanged(value:float)
signal volumeGUIchanged(value:float)

func _ready() -> void:
	GUI = 0
	BGM = 0
	connect("volumeGUIchanged", _update_audio)
	connect("volumeBGMchanged", _update_audio)

func _update_audio(value:float):
	GUI = value
	BGM = value
