extends KinematicBody2D
class_name Player

signal coin_collected
signal hp_changed
signal dead
signal moving_to

export var speed := 300
export var gravity := 350
export var max_hp := 3

onready var char_sprite := $GFX/AnimatedSprite
onready var camera := $CamaraContainer/Camera2D
onready var gfx := $GFX
onready var gfx_scale = gfx.scale.x
onready var center_position := position.x
onready var audio_player := $AudioStreamPlayer2D
onready var animation_player := $AnimationPlayer
onready var spawn_position := $CamaraContainer/Camera2D/Position2D

var top_direction = Vector2(0, -1)
var last_tap_action = null
var last_tap_finger_idx = null
var coins := 0
var hp: int
var take_damage_sfx : AudioStream = preload("res://assets/sfx_and_music/player_Take_Damage.wav")
var level_up_sfx : AudioStream = preload("res://assets/sfx_and_music/player_Take_PowerUp.wav")
var is_invulnarable := false
var limit_hp := 7

func _ready():
	hp = max_hp
	emit_signal("hp_changed", hp)

func _physics_process(delta):
	if hp <= 0:
		return
	var move_dir := Vector2(0, gravity)
	if Input.is_action_pressed("move_left"):
		move_dir += Vector2(-speed, 0)
		gfx.scale.x = gfx_scale
	elif Input.is_action_pressed("move_right"):
		move_dir += Vector2(speed, 0)
		gfx.scale.x = -gfx_scale

	if is_on_floor() and move_dir.x != 0:
		char_sprite.play("run")
	else:
		char_sprite.play("idle")
	
	if is_on_floor():
		camera.position += Vector2(0, gravity / 1.5 * delta)
	elif camera.position.y > 0:
		 camera.position += Vector2(0, - gravity / 3 * delta)
	
	emit_signal("moving_to", move_dir)
	move_and_slide(move_dir, top_direction)
	
func die_from_screen():
	hp = 0
	emit_signal("hp_changed", 0)
	die()

func level_up():
	max_hp = clamp(max_hp + 1, max_hp, limit_hp)

func heal():
	hp = max_hp
	is_invulnarable = true
	_play_sfx(level_up_sfx)
	emit_signal("hp_changed", hp)
	yield($AudioStreamPlayer2D, "finished")
	is_invulnarable = false

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
	if hp <= 0:
		die()

func die():
	is_invulnarable = true
	animation_player.play("die")
	yield(animation_player, "animation_finished")
	emit_signal("dead")

func pick_up(body: Node2D):
	if body is Coin:
		body.pick_up()
		coins += 1
		emit_signal("coin_collected", coins)
	if body is Cristall:
		body.pick_up()
		coins += 10
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
		_emit_tap_action(action, event.index)
	elif event is InputEventScreenTouch and last_tap_action:
		_cancel_last_tap_action(event.index)

func _emit_tap_action(action, finger_idx = null):
	if finger_idx != null:
		last_tap_finger_idx = finger_idx
	last_tap_action = action
	_emit_tap_action_event(action, true)

func _cancel_last_tap_action(finger_idx = null):
	if finger_idx != null and last_tap_finger_idx != finger_idx:
		return
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
