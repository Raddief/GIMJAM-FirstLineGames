extends Area2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			for alien in get_overlapping_bodies():
				alien.kill()
