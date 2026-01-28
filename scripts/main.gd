extends Node2D

@export var ui : UI
@export var shop: Shop
@export var day_manager: DayManager
@export var alien_manager: AlienManager
@export var popups: CenterContainer
@onready var people_scene: PackedScene = preload("res://Resources/Scene/people.tscn")

func _ready():
	CurrencyManager.currency = 0
	CurrencyManager.TotalGold = 0
	shop.buyAlien.connect(buy_alien)
	
	CurrencyManager.currency_changed.connect(day_manager.on_money_changed)
	CurrencyManager.currency_changed.connect(ui.on_money_changed)
	CurrencyManager.connect("AlienPurchased", add_alien)

	day_manager.connect("day_started", ui.on_day_started)
	day_manager.connect("day_started", _on_day_change)
	day_manager.connect("day_started", shop.addSlot)
	day_manager.connect("day_ended", ui.on_day_ended)
	day_manager.connect("day_ended", _on_day_ended)
	day_manager.connect("day_fail", _on_day_fail)
	day_manager.connect("turn_changed", ui.on_turn_changed)
	day_manager.connect("turn_consumed", _on_turn_passed)
	ui.on_end_turn.connect(day_manager.consume_turn)
	shop.connect("Forfeit", _on_forfeit)
	shop.connect("Setting", _on_setting)

	
	day_manager.start_day(0)
	CurrencyManager.add(4000) # starting money

func buy_alien(alien_data: AlienData) -> void:
	if CurrencyManager.spend(alien_data.price):
		alien_manager.spawn_alien(alien_data)

func add_alien():
	shop.TotalAliens += 1

func _on_turn_passed(turn: int, max_turns: int):
	alien_manager.on_turn_passed()
	$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_end_turn1.mp3"))
	$Sfx.emit_signal("streamChanged")

func _on_day_ended(day: DayData):
	alien_manager.on_day_ended()

func _on_day_change(day:DayData):
	for i in $ForPeople.get_child_count(true) :
		$ForPeople.get_child($ForPeople.get_child_count(true)-(i+1)).queue_free()
	var index: int
	for i in day_manager.days.size() :
		if day_manager.days[i].day_name == day.day_name :
			index = i-1
	if day.day_name != "Monday":
		$GlassDome.visible = true
		$Sfx.set_stream(load("res://Resources/Asset/Sfx/ui_end_day1.mp3"))
		$Sfx.emit_signal("streamChanged")
		popups.EndDay(day_manager.days[index].day_name, CurrencyManager.currency+day_manager.days[index].money_target, day_manager.days[index].money_target, $GlassDome)

func _on_day_fail():
	$GlassDome.visible = true
	popups.GameOver(CurrencyManager.TotalGold, shop.TotalAliens)

func _on_forfeit():
	popups.Forfeit()

func _on_setting():
	popups.Setting()

func _on_spawn_people_timeout() -> void:
	$SpawnPeople.start(randf_range(1,5))
	var people = people_scene.instantiate()
	people.position.y = randf_range(10,DisplayServer.screen_get_size().y/4)
	people.direction = randi_range(0,1)
	$ForPeople.add_child(people)
