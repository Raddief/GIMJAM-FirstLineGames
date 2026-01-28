extends Control
class_name Shop

#Scene Variable
var slots = preload("res://Resources/Scene/Button.tscn")
var Mainmenu = preload("res://Resources/Scene/Button.tscn") #Masih Placeholder ini Bang

#Node Variable
@onready var anim = $Animation

#Variable Status
var day = 6
var TotalAliens := 0

@export var Alien : Array[AlienData]
@export var Item : Dictionary
@export var grid_manager : GridManager
@export var alien_manager : AlienManager
@export var end_turn_button : Button

var selected_alien : AlienData = null
var avaliable_aliens : Array[AlienData] = []
var current_day_data : DayData = null

signal buyAlien(alien_data: AlienData)
signal Forfeit(condition:bool)
signal Setting(bool)

func resetPanel():
	$SidePanel/Menu/MenuList/Shop.set_text("Shop")
	$SidePanel/Menu/MenuList/Shop.set_button_icon(load("res://Resources/Asset/UI/shopping-cart.png"))
	$SidePanel/Menu/MenuList/UseItem.set_text("Use Item")
	$SidePanel/Menu/MenuList/Journal.set_text("Journal")
	$SidePanel/Menu/MenuList/Journal.set_button_icon(load("res://Resources/Asset/UI/secret-book.png"))
	$SidePanel/Menu/MenuList/Journal.visible = false
	$SidePanel/Menu/MenuList/Setting.visible = true
	$SidePanel/Menu/MenuList/Forfeit.visible = true
	$SidePanel/Menu.visible = true
	$BottomPanel.visible = false
	if end_turn_button:
		end_turn_button.visible = false
	$SidePanel/Scroll.visible = false

func showDesc(types:int, object):
	$BottomPanel.visible = true
	if end_turn_button:
		end_turn_button.visible = true
	if types == 0 and object is AlienData:
		var AlienScene = selected_alien.alien_scene.instantiate()
		# Check if the alien has a valid facecard texture assigned
		if "facecard" in AlienScene and AlienScene.facecard != null:
			$BottomPanel/Description/Grid/Icon.set_button_icon(AlienScene.facecard)
		else:
			# Fallback to the original SpriteFrames logic if no facecard exists
			$BottomPanel/Description/Grid/Icon.set_button_icon(AlienScene.get_child(0,true).get_sprite_frames().get_frame_texture("default",0))
		$BottomPanel/Description/Grid/Profile/Header.set_text(object.name)
		$BottomPanel/Description/Grid/PriceYield/Price/Contain.set_text(str(object.price))
		$BottomPanel/Description/Grid/Profile/Contain.set_text(object.alien_trait)
		$BottomPanel/Description/Grid/PriceYield/Yield/Contain.set_text(str(object.rate))

func addSlot(day_data: DayData = null) -> void:
	var aliens: Array = Alien
	for avaliable_alien in day_data.new_aliens:
		avaliable_aliens.append(avaliable_alien)
		var slot = slots.instantiate()
		var AlienScene = avaliable_alien.alien_scene.instantiate()
		slot.slot = true
		slot.root = self
		slot.set_button_icon(AlienScene.get_child(0,true).get_sprite_frames()
.get_frame_texture("default",0))
		slot.object = avaliable_alien
		slot.select_slot.connect(select_slot)
		$SidePanel/Scroll/Scroll/Stock.add_child(slot)

func _on_open_close_pressed() -> void:
	if $SidePanel.get_anchor(SIDE_LEFT) < 1 :
		resetPanel()
		anim.play("CloseShop")
	elif $SidePanel.get_anchor(SIDE_LEFT) > 1:
		anim.play("OpenShop")
		if CurrencyManager.Tutorial == 1 : 
			CurrencyManager.emit_signal("TutorialNext")

func _on_shop_pressed() -> void:
	var text = $SidePanel/Menu/MenuList/Shop.get_text()
	if text == "Shop" :
		if CurrencyManager.Tutorial == 2 : 
			CurrencyManager.emit_signal("TutorialNext")
		$SidePanel/Menu/MenuList/Shop.set_text("Aliens")
		$SidePanel/Menu/MenuList/Shop.set_button_icon(load("res://Resources/Asset/UI/alien-stare.png"))
		$SidePanel/Menu/MenuList/UseItem.set_text("Items")
		$SidePanel/Menu/MenuList/Journal.set_text("Back")
		$SidePanel/Menu/MenuList/Journal.set_button_icon(null)
		$SidePanel/Menu/MenuList/Journal.visible = true
		$SidePanel/Menu/MenuList/Setting.visible = false
		$SidePanel/Menu/MenuList/Forfeit.visible = false
	elif text == "Aliens" :
		if CurrencyManager.Tutorial == 3 : 
			CurrencyManager.emit_signal("TutorialNext")
		$SidePanel/Menu.visible = false
		$SidePanel/Scroll.visible = true

func _on_use_item_pressed() -> void:
	pass # Replace with function body.

func _on_journal_pressed() -> void:
	var text = $SidePanel/Menu/MenuList/Journal.get_text()
	if text == "Back":
		resetPanel()

func _on_setting_pressed() -> void:
	emit_signal("Setting")

func _on_forfeit_pressed() -> void:
	emit_signal("Forfeit")

func select_slot(types:int, object) -> void:
	selected_alien = object
	showDesc(types, object) # Keep information display on click

func spawn_ghost_alien(data: AlienData):
	var new_alien = data.alien_scene.instantiate()
	
	# 1. Add to scene tree
	alien_manager.add_child(new_alien)
	
	selected_alien = data
	new_alien.initialize_drag(grid_manager)
	new_alien.cost = data.price
	
	# 2. Position it immediately at the mouse
	new_alien.global_position = get_global_mouse_position()

	# 3. CRITICAL FIX: Initialize visuals and grid connection BEFORE dragging
	# This prevents the crash (null grid) and the visual glitch (wrong offset)
	new_alien.is_new_purchase = true

	# 4. Start the drag logic
	new_alien.start_drag(get_global_mouse_position())
	
	# 5. UI Stuff
	showDesc(0, selected_alien)

func _on_popup_confirmed() -> void:
	get_tree().change_scene_to_packed(Mainmenu)

func _on_popup_canceled() -> void:
	get_tree().set_pause(false)
	$Popup.visible = false
