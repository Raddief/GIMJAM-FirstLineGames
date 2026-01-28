extends Node

@onready var level_music: AudioStreamPlayer = $Level
@onready var menu_music: AudioStreamPlayer = $Menu

@export var fade_time := 1.0
@export var duck_volume_db := -15.0  # How much to reduce music volume during spawn

var current_player: AudioStreamPlayer = null
var is_ducked := false

func _ready():
	AudioManager.connect("volumeBGMchanged", _on_volume_chnaged)
	stop_all()

func _on_volume_chnaged(value:float):
	$Menu.set_volume_db(value)
	$Level.set_volume_db(value)

# --------------------
# Public API
# --------------------

func play_menu():
	_switch_to(menu_music)

func play_level():
	_switch_to(level_music)

func stop_all():
	if level_music.playing:
		level_music.stop()
	if menu_music.playing:
		menu_music.stop()
	current_player = null

func duck_music():
	#"""Reduce music volume during spawn audio"""
	if is_ducked or !current_player:
		return
	is_ducked = true
	var tween := create_tween()
	tween.tween_property(
		current_player,
		"volume_db",
		duck_volume_db,
		0.1
	)

func unduck_music():
	#"""Restore music volume after spawn audio"""
	if !is_ducked or !current_player:
		return
	is_ducked = false
	var tween := create_tween()
	tween.tween_property(
		current_player,
		"volume_db",
		0.0,
		0.1
	)

# --------------------
# Internal helpers
# --------------------

func _switch_to(target: AudioStreamPlayer):
	if current_player == target:
		return

	if current_player:
		_fade_out(current_player)

	current_player = target
	_fade_in(target)

func _fade_in(player: AudioStreamPlayer):
	player.volume_db = -80.0
	player.play()

	var tween := create_tween()
	tween.tween_property(
		player,
		"volume_db",
		0.0,
		fade_time
	)

func _fade_out(player: AudioStreamPlayer):
	var tween := create_tween()
	tween.tween_property(
		player,
		"volume_db",
		-80.0,
		fade_time
	)
	tween.tween_callback(player.stop)
