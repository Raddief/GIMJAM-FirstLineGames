extends Node2D

@export var ui : UI
@export var shop: Shop
@export var day_manager: DayManager
@export var alien_manager: AlienManager
@export var popups: CenterContainer
@export var people_scene: PackedScene
@export_category("SOUND")
@export var end_turn_sound : AudioStream
@export var end_day_sound : AudioStream
@onready var tutorials = $TutorialPlayer

func _ready():
	CurrencyManager.currency = 0
	CurrencyManager.TotalGold = 0
	Music.play_level()
	shop.buyAlien.connect(buy_alien)
	

	CurrencyManager.currency_changed.connect(day_manager.on_money_changed)
	CurrencyManager.currency_changed.connect(ui.on_money_changed)
	CurrencyManager.currency_changed.connect(shop.on_money_changed)
	day_manager.day_started.connect(shop.on_money_target_changed)
	CurrencyManager.connect("AlienPurchased", add_alien)
	CurrencyManager.connect("TutorialNext", _on_tutorial)
	if CurrencyManager.Tutorial != 7 :
		CurrencyManager.Tutorial = 1
		$CanvasLayer/UI/Money.visible = false
		$"CanvasLayer/UI/Pen Lights/TextureProgressBar".visible = false
		$CanvasLayer/UI/EndTurnButton.visible = false
		$CanvasLayer/RemoveArea.visible = false
		$CanvasLayer/Marker.visible = true
		$CanvasLayer/DirectionalLight2D.visible = true
		$CanvasLayer/TextMarker.visible = true
	elif CurrencyManager.Tutorial == 7 :
		$CanvasLayer/DirectionalLight2D.queue_free()
		$CanvasLayer/Marker.queue_free()
		$CanvasLayer/TextMarker.queue_free()
		tutorials.queue_free()
		# This doesn't work??
		# $CanvasLayer/UI/Money.visible = true
		# $"CanvasLayer/UI/Pen Lights/TextureProgressBar".visible = true
		# print("Make money visible!")

	day_manager.connect("day_started", ui.on_day_started)
	day_manager.connect("day_started", _on_day_change)
	day_manager.connect("day_started", shop.addSlot)
	day_manager.connect("day_ended", ui.on_day_ended)
	day_manager.connect("day_ended", _on_day_ended)
	day_manager.connect("day_fail", _on_day_fail)
	day_manager.connect("turn_changed", ui.on_turn_changed)
	day_manager.connect("turn_consumed", _on_turn_passed)
	day_manager.connect("win", Winning)
	ui.on_end_turn.connect(day_manager.consume_turn)
	shop.connect("Forfeit", _on_forfeit)
	shop.connect("Setting", _on_setting)

	
	day_manager.start_day(0)
	CurrencyManager.add(500) # starting money

func buy_alien(alien_data: AlienData) -> void:
	if CurrencyManager.spend(alien_data.price):
		alien_manager.spawn_alien(alien_data)

func _on_tutorial():
	CurrencyManager.Tutorial += 1
	tutorials.play("Step"+str(CurrencyManager.Tutorial))

func add_alien():
	shop.TotalAliens += 1

func _on_turn_passed(turn: int, max_turns: int):
	alien_manager.on_turn_passed()
	$Sfx.set_stream(end_turn_sound)
	$Sfx.emit_signal("streamChanged")

func _on_day_ended(day: DayData):
	alien_manager.on_day_ended()

func _interval():
	if day_manager.current_day.day_name != "Monday":
		$Interval.start(1)

func _on_day_change(day:DayData):
	for i in $ForPeople.get_child_count(true) :
		$ForPeople.get_child($ForPeople.get_child_count(true)-(i+1)).queue_free()
	var index: int
	for i in day_manager.days.size() :
		if day_manager.days[i].day_name == day.day_name :
			index = i-1
	if day.day_name != "Monday":
		$GlassDome.visible = true
		$Sfx.set_stream(end_day_sound)
		$Sfx.emit_signal("streamChanged")
		popups.EndDay(day_manager.days[index].day_name, CurrencyManager.currency+day_manager.days[index].money_target, day_manager.days[index].money_target, $GlassDome)

func _on_day_fail():
	$GlassDome.visible = true
	popups.GameOver(CurrencyManager.TotalGold, shop.TotalAliens)

func Winning():
	popups.Winning(shop.TotalAliens)

func _on_forfeit():
	popups.Forfeit()

func _on_setting():
	popups.Setting()

func _on_spawn_people_timeout() -> void:
	$SpawnPeople.start(randf_range(1,5))
	var people = people_scene.instantiate()
	people.position.y = randf_range(10,180)
	people.direction = randi_range(0,1)
	$ForPeople.add_child(people)


func _on_tutorial_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Step5" :
		CurrencyManager.emit_signal("TutorialNext")
	elif anim_name == "Step7" :
		$CanvasLayer/UI/EndTurnButton.visible = true
		$CanvasLayer/RemoveArea.visible = true
		$CanvasLayer/UI/Money.visible = true
		$"CanvasLayer/UI/Pen Lights/TextureProgressBar".visible = true
		$CanvasLayer/DirectionalLight2D.queue_free()
		$CanvasLayer/Marker.queue_free()
		$CanvasLayer/TextMarker.queue_free()
		tutorials.queue_free()


func _on_interval_timeout() -> void:
	_on_day_change(day_manager.current_day)
