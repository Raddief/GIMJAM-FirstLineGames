extends Node2D

var direction:bool #true = left, false = right
var jumping:bool = false
var state:bool = false #false = belum lihat, true = sudah lihat

func _ready() -> void:
	if direction:
		$AnimationSprite.flip_h = false
		self.position.x = 1960
		$See.start(randi_range(8,11))
	else :
		$AnimationSprite.flip_h = true
		self.position.x = 0
		$See.start(randi_range(3,7))

func _process(delta: float) -> void:
	if $AnimationSprite.get_animation() == "Walking":
		$AnimationPlayer.play("Walking")
		if direction:
			self.position.x -= delta*100
		else :
			self.position.x += delta*100
	if self.position.x > 1960 || self.position.x < 0:
				queue_free()

func _on_see_timeout() -> void:
	if !state:
		$AnimationPlayer.play("RESET")
		$AnimationSprite.play("Idle")
		$See.start(randi_range(2,5))
		state = true
	else :
		$AnimationSprite.play("Walking")
