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

func EndDay(Day:String, GoldGain:int, GoldSpend:int):
	$EndDay.visible = true
	self.visible = true
	$EndDay/VBoxContainer/Congrats.set_text("Congratulation, you just pass the "+Day)
	$EndDay/VBoxContainer/Column/Number/GoldGain.set_text(str(GoldGain))
	$EndDay/VBoxContainer/Column/Number/GoldSpend.set_text(str(GoldSpend))
	get_tree().set_pause(true)

func _on_continue_pressed() -> void:
	$EndDay.visible = false
	self.visible = false
	get_tree().set_pause(false)

func Setting():
	$Setting/VBoxContainer/Column/Slider/GUI.set_value(AudioManager.GUI)
	$Setting.visible = true
	self.visible = true
	get_tree().set_pause(true)

func _on_continues_pressed() -> void:
	$Setting.visible = false
	self.visible = false
	get_tree().set_pause(false)

func _on_gui_drag_ended(value_changed: bool) -> void:
	AudioManager.emit_signal("volumeGUIchanged", $Setting/VBoxContainer/Column/Slider/GUI.get_value())
