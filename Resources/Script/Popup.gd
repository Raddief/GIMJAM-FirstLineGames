extends CenterContainer

func GameOver(golds:int, aliens:int):
	self.visible = true
	$GameOver.visible = true
	$GameOver/VBoxContainer/Column/Number/TotalGold.set_text(str(golds))
	$GameOver/VBoxContainer/Column/Number/TotalAlien.set_text(str(aliens))
	get_tree().set_pause(true)

func _on_try_again_pressed() -> void:
	get_tree().set_pause(false)
	get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://Resources/Scene/Button.tscn")) #Placeholder

func Forfeit():
	$Forfeit.visible = true
	self.visible = true
	get_tree().set_pause(true)

func _on_sure_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://Resources/Scene/Button.tscn")) #Placeholder

func _on_refuse_pressed() -> void:
	$Forfeit.visible = false
	self.visible = false
	get_tree().set_pause(false)
