extends Control

func _ready() -> void:
	Music.play_menu()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_setting_pressed() -> void:
	$Popups.Setting()
