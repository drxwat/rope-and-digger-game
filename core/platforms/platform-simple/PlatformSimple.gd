extends KinematicBody2D

var width := 0.0
var height := 0.0
var is_mooving := false
var move_amplitude : float
var move_target : Vector2
var rng = RandomNumberGenerator.new()
var move_speed := 150
var move_dir := 0 # 0 left, 1 right

func _ready():
	width = $Sprite.texture.get_size().x * $Sprite.scale.x
	height = $Sprite.texture.get_size().y * $Sprite.scale.y
	rng.randomize()
	
func _physics_process(delta):
	if not is_mooving:
		return
	if not move_target:
		init_randonm_move_target()
	if position.distance_to(move_target) <= 5:
		update_move_targer()
	move_and_slide(position.direction_to(move_target) * move_speed)
	if (is_on_wall()):
		update_move_targer()

func on_screen_exited():
	queue_free()

func update_move_targer():
	if move_dir == 0:
		set_right_move_target()
	else:
		set_left_move_target()

func init_randonm_move_target():
	if rng.randi_range(0, 1) == 1: # MOVE_LEFT
		set_left_move_target()
	else:
		set_right_move_target()
		

func set_right_move_target():
	move_dir = 1
	move_target = Vector2(move_amplitude - (width / 2), position.y)
	
func set_left_move_target():
	move_dir = 0
	move_target = Vector2(width / 2, position.y)
	
