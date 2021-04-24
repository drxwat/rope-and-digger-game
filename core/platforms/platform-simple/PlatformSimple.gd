extends KinematicBody2D


var width := 0.0

func _ready():
	width = $Sprite.texture.get_size().x * $Sprite.scale.x

func on_screen_exited():
	queue_free()
