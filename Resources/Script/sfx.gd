extends AudioStreamPlayer

signal streamChanged()

func _ready() -> void:
	AudioManager.connect("volumeGUIchanged", _on_volume_changed)
	connect("streamChanged", _on_stream_changed)
	self.set_volume_db(AudioManager.GUI)

func _on_stream_changed():
	self.play()

func _on_volume_changed(value:float):
	self.set_volume_db(value)
