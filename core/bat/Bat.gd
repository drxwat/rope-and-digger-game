extends KinematicBody2D

onready var attack_timer := $AttackTimer 

var is_attacking := false
var velocity := Vector2(0, -200)
var gravity := 250
var attack_duration := 3

func _ready():
	$AttackTimer.wait_time = attack_duration
	$AttackTimer.start()

func damage_player(player: Player):
	player.take_damage()

func _physics_process(delta):
	if is_attacking:
		move_and_slide(velocity)
	else:
		move_and_slide(Vector2(0, gravity))

func remove():
	queue_free()
	
func start_attack():
	is_attacking = true
