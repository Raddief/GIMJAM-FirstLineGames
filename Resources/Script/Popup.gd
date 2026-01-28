extends CenterContainer

var GlassDome:Sprite2D

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
	get_tree().change_scene_to_packed(load("res://Resources/Scene/Main_Menu.tscn"))

func Forfeit():
	$Forfeit.visible = true
	self.visible = true
	get_tree().set_pause(true)

func _on_sure_pressed() -> void:
	get_tree().set_pause(false)
	get_tree().change_scene_to_packed(load("res://Resources/Scene/Main_Menu.tscn"))

func _on_refuse_pressed() -> void:
	$Forfeit.visible = false
	self.visible = false
	get_tree().set_pause(false)

func EndDay(Day:String, Gold:int, Quota:int, Dome:Sprite2D):
	$EndDay.visible = true
	GlassDome = Dome
	self.visible = true
	$EndDay/VBoxContainer/Congrats.set_text("Congratulation, you just pass the "+Day)
	$EndDay/VBoxContainer/Column/Number/CurrentGold.set_text(str(Gold))
	$EndDay/VBoxContainer/Column/Number/Quota.set_text(str(Quota))
	$EndDay/VBoxContainer/Column/Number/Credit.set_text(str(Gold-Quota))
	get_tree().set_pause(true)

func _on_continue_pressed() -> void:
	GlassDome.visible = false
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

func _on_gui_value_changed(value: float) -> void:
	AudioManager.emit_signal("volumeGUIchanged", $Setting/VBoxContainer/Column/Slider/GUI.get_value())
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_hover2.mp3"))
	$Sfx.play()

func _on_bgm_value_changed(value: float) -> void:
	AudioManager.emit_signal("volumeBGMchanged", $Setting/VBoxContainer/Column/Slider/BGM.get_value())
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_hover2.mp3"))
	$Sfx.play()
