extends KinematicBody2D

export var speed := 300
export var gravity := 250

onready var char_sprite := $AnimatedSprite
onready var camera := $Camera2D

var top_direction = Vector2(0, -1)

func _physics_process(delta):
	var move_dir := Vector2(0, gravity)
	if Input.is_action_pressed("move_left"):
		move_dir += Vector2(-speed, 0)
		char_sprite.flip_h = false
	elif Input.is_action_pressed("move_right"):
		move_dir += Vector2(speed, 0)
		char_sprite.flip_h = true
	if is_on_floor() and move_dir.x == 0:
		char_sprite.play("idle")
	else:
		char_sprite.stop()
	
	if is_on_floor():
		camera.position += Vector2(0, gravity / 2 * delta)
	elif camera.position.y > 0:
		 camera.position += Vector2(0, - gravity / 4 * delta)
	
	move_and_slide(move_dir, top_direction)


