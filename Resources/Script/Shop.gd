extends Control
class_name Shop

#Scene Variable
var slots = preload("res://Resources/Scene/Button.tscn")
var Mainmenu = preload("res://Resources/Scene/Button.tscn") #Masih Placeholder ini Bang

#Node Variable
@onready var anim = $Animation

#Variable Status
var day = 6
@export var Database:GDScript

signal buyAlien(index:int, cost:int)

func showDesc(types:int, object:String):
	$BottomPanel.visible = true
	if types == 0 :
		var Data:Dictionary = Database.new().Alien
		$BottomPanel/Description/Icon.set_text(object)
		$BottomPanel/Description/Contain1.set_text(str(Data.get(object)[3]))
		$BottomPanel/Description/Contain2.set_text(Data.get(object)[0])
		$BottomPanel/Description/Contain3.set_text(Data.get(object)[1])

func addSlot(types:int):
	var Data:Dictionary
	var keys
	if types == 0:
		Data= Database.new().Alien
		keys = Data.keys()
	else :
		Data = Database.new().Item
		keys = Data.keys()
	for i in 4+day:
		var slot = slots.instantiate()
		slot.slot = true
		slot.type = types
		slot.root = self
		slot.object = keys[i]
		$SidePanel/Scroll/Scroll/Stock.add_child(slot)

func _on_open_close_pressed() -> void:
	if $BottomPanel.visible == false && $SidePanel.get_position().x != 1111:
		anim.play("OpenShop")
	elif $SidePanel.get_position().x == 1111 : 
		anim.play("CloseShop")

func _on_shop_pressed() -> void:
	var text = $SidePanel/Menu/MenuList/Shop.get_text()
	if text == "Shop" :
		$SidePanel/Menu/MenuList/Shop.set_text("Aliens")
		$SidePanel/Menu/MenuList/Shop.set_button_icon(load("res://Resources/Asset/UI/alien-stare.png"))
		$SidePanel/Menu/MenuList/UseItem.set_text("Items")
		$SidePanel/Menu/MenuList/Journal.set_text("Back")
		$SidePanel/Menu/MenuList/Journal.set_button_icon(null)
		$SidePanel/Menu/MenuList/Setting.visible = false
		$SidePanel/Menu/MenuList/Forfeit.visible = false
	elif text == "Aliens" :
		addSlot(0)
		$SidePanel/Menu.visible = false
		$SidePanel/Scroll.visible = true

func _on_use_item_pressed() -> void:
	pass # Replace with function body.

func _on_journal_pressed() -> void:
	var text = $SidePanel/Menu/MenuList/Journal.get_text()
	if text == "Back":
		$SidePanel/Menu/MenuList/Shop.set_text("Shop")
		$SidePanel/Menu/MenuList/Shop.set_button_icon(load("res://Resources/Asset/UI/shopping-cart.png"))
		$SidePanel/Menu/MenuList/UseItem.set_text("Use Item")
		$SidePanel/Menu/MenuList/Journal.set_text("Journal")
		$SidePanel/Menu/MenuList/Journal.set_button_icon(load("res://Resources/Asset/UI/secret-book.png"))
		$SidePanel/Menu/MenuList/Setting.visible = true
		$SidePanel/Menu/MenuList/Forfeit.visible = true
	elif text == "Journal" :
		pass

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "CloseShop" :
		anim.play("RESET")

func _on_setting_pressed() -> void:
	pass # Replace with function body.

func _on_forfeit_pressed() -> void:
	get_tree().set_pause(true)
	$Popup.set_text("Are you sure want to surrender?")
	$Popup.visible = true

func _on_buy_pressed() -> void:
	emit_signal("buyAlien", 0, 200) #Placeholder index and cost

func _on_popup_confirmed() -> void:
	get_tree().change_scene_to_packed(Mainmenu)

func _on_popup_canceled() -> void:
	get_tree().set_pause(false)
	$Popup.visible = false
