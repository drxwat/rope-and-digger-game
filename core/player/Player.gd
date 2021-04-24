extends KinematicBody2D

export var speed := 300
export var gravity := 250

onready var char_sprite := $AnimatedSprite
onready var camera := $CamaraContainer/Camera2D
onready var center_position := position.x

var top_direction = Vector2(0, -1)
var last_tap_action = null
var coins := 0

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

func pick_up(body: Node2D):
	if body is Coin:
		body.pick_up()
		coins += 1
		print(coins)

func _input(event):
	if last_tap_action and event is InputEventMouseMotion:
		var action = _get_event_action(event)
		if action != last_tap_action: # Finger Changed Direction
			_cancel_last_tap_action()
			_emit_tap_action(action)
	
	if event is InputEventScreenTouch and event.is_pressed():
		var action = _get_event_action(event)
		if action == last_tap_action:
			return
		elif last_tap_action:
			_cancel_last_tap_action()
		_emit_tap_action(action)
	elif event is InputEventScreenTouch and last_tap_action:
		_cancel_last_tap_action()

func _emit_tap_action(action):
	last_tap_action = action
	_emit_tap_action_event(action, true)

func _cancel_last_tap_action():
	_emit_tap_action_event(last_tap_action, false)
	last_tap_action = null

func _emit_tap_action_event(action: String, pressed: bool):
	var event = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)

func _get_event_action(event: InputEvent):
	var is_right = center_position < event.position.x
	return "move_right" if is_right else "move_left"
