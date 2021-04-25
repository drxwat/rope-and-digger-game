extends KinematicBody2D


var width := 0.0
var height := 0.0
var is_mooving := false

func _ready():
	width = $Sprite.texture.get_size().x * $Sprite.scale.x
	height = $Sprite.texture.get_size().y * $Sprite.scale.y
	
func _physics_process(delta):
	pass
#	if is_mooving:
#		move_and_slide()

func on_screen_exited():
	queue_free()
