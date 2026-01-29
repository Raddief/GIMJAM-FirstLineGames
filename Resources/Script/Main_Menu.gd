extends Control

func _ready() -> void:
	Music.play_menu()

func _on_play_pressed() -> void:
	SceneManager.change_scene_to_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_setting_pressed() -> void:
	$Popups.Setting()
