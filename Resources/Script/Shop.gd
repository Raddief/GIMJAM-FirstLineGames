extends Control
class_name Shop

#Scene Variable
var slots = preload("res://Resources/Scene/Button.tscn")
var Mainmenu = preload("res://Resources/Scene/Button.tscn") #Masih Placeholder ini Bang

#Node Variable
@onready var anim = $Animation

#Variable Status
var day = 6
@export var Alien : Array[AlienData]
@export var Item : Dictionary

var selected_alien : AlienData = null

signal buyAlien(alien_data: AlienData)

func showDesc(types:int, object):
	$BottomPanel.visible = true
	if types == 0 and object is AlienData:
		$BottomPanel/Description/Icon.set_text(object.name)
		$BottomPanel/Description/Contain1.set_text(str(object.price))
		$BottomPanel/Description/Contain2.set_text(object.origin)
		$BottomPanel/Description/Contain3.set_text(object.alien_trait)

func addSlot(types:int):
	if types == 0:
		var aliens: Array = Alien
		for i in 4 + day:
			if i >= aliens.size():
				break
			var slot = slots.instantiate()
			slot.slot = true
			slot.type = types
			slot.root = self
			slot.object = aliens[i]
			slot.select_slot.connect(select_slot)
			$SidePanel/Scroll/Scroll/Stock.add_child(slot)
	else:
		var items : Dictionary = Item
		var keys := items.keys()
		for i in 4 + day:
			if i >= keys.size():
				break
			var slot = slots.instantiate()
			slot.slot = true
			slot.type = types
			slot.root = self
			slot.object = keys[i]
			slot.select_slot.connect(select_slot)
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

func select_slot(types:int, object) -> void:
	selected_alien = object

func _on_buy_pressed() -> void:
	emit_signal("buyAlien", selected_alien)

func _on_popup_confirmed() -> void:
	get_tree().change_scene_to_packed(Mainmenu)

func _on_popup_canceled() -> void:
	get_tree().set_pause(false)
	$Popup.visible = false
