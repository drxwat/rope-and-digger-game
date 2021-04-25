extends KinematicBody2D
class_name Player

signal coin_collected
signal hp_changed

export var speed := 300
export var gravity := 250
export var max_hp := 3

onready var char_sprite := $GFX/AnimatedSprite
onready var camera := $CamaraContainer/Camera2D
onready var gfx := $GFX
onready var gfx_scale = gfx.scale.x
onready var center_position := position.x
onready var audio_player := $AudioStreamPlayer2D
onready var animation_player := $AnimationPlayer

var top_direction = Vector2(0, -1)
var last_tap_action = null
var coins := 0
var hp := max_hp
var take_damage_sfx : AudioStream = preload("res://assets/sfx_and_music/player_Take_Damage.wav")
var is_invulnarable := false

func _ready():
	emit_signal("hp_changed", hp)

func _physics_process(delta):
	var move_dir := Vector2(0, gravity)
	if Input.is_action_pressed("move_left"):
		move_dir += Vector2(-speed, 0)
		gfx.scale.x = gfx_scale
#		char_sprite.flip_h = false
	elif Input.is_action_pressed("move_right"):
		move_dir += Vector2(speed, 0)
		gfx.scale.x = -gfx_scale
#		char_sprite.flip_h = true

	if is_on_floor() and move_dir.x != 0:
		char_sprite.play("run")
	else:
		char_sprite.play("idle")
	
	if is_on_floor():
		camera.position += Vector2(0, gravity / 2 * delta)
	elif camera.position.y > 0:
		 camera.position += Vector2(0, - gravity / 4 * delta)
	
	move_and_slide(move_dir, top_direction)
	
func take_damage():
	if is_invulnarable:
		return
	hp -= 1
	_play_sfx(take_damage_sfx)
	emit_signal("hp_changed", hp)
	is_invulnarable = true
	animation_player.play("take_damage")
	var animation_name = yield(animation_player, "animation_finished")
	if animation_name == "take_damage":
		is_invulnarable = false

func pick_up(body: Node2D):
	if body is Coin:
		body.pick_up()
		coins += 1
		emit_signal("coin_collected", coins)
		
func _play_sfx(stream: AudioStream):
	audio_player.stream = stream
	audio_player.play()

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
