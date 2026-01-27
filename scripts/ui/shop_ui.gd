extends Control
#
#@export var buy_buttons: Array[Button]
#
#@export var alien_manager : AlienManager
#
#func _ready():
	#for i in range(buy_buttons.size()):
		#buy_buttons[i].pressed.connect(_on_buy_alien_pressed.bind(i))
#
#func _on_buy_alien_pressed(index: int):
	#var alien_scene : PackedScene = alien_manager.alien_scenes[index]
	#var cost : int = alien_scene.instantiate().cost
	#if CurrencyManager.spend(cost):
		#alien_manager.spawn_alien(alien_manager.alien_scenes[index])
