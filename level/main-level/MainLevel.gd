extends Node2D

export var platform_spawn_time := 3

onready var bg1 : Background = $Backgrounds/Background1
onready var bottom_bg : Background = $Backgrounds/Background3
onready var platforms_container := $Platforms
onready var player := $Player

var bg_height : float = 0
var bg_width : float = 0
var player_to_bottom_bg_normal_dist : float = 0
var rng = RandomNumberGenerator.new()

enum PlatfromsTypes { SIMPLE }

var platforms = {
	PlatfromsTypes.SIMPLE: preload("res://core/platforms/platform-simple/PlatformSimple.tscn")
}

func _ready():
	rng.randomize()
	bg_height = $Backgrounds/Background1.texture.get_size().y * $Backgrounds/Background1.scale.y
	bg_width =  $Backgrounds/Background1.texture.get_size().x * $Backgrounds/Background1.scale.x
	player_to_bottom_bg_normal_dist = bottom_bg.position.y - player.position.y
	$Timers/PlatformTimer.wait_time = platform_spawn_time


func move_bg_to_bottom(background: Background):
	background.position.y += 3 * bg_height
	bottom_bg = background
	
func spawn_platform():
	var platform =  platforms[PlatfromsTypes.SIMPLE].instance()
	var distance_to_player = bottom_bg.position.y - player.position.y
	var margin_bottom = player_to_bottom_bg_normal_dist - distance_to_player
	var platform_y_position = margin_bottom + bottom_bg.position.y
	platform.position = Vector2(0, platform_y_position)
	platforms_container.add_child(platform)
	var margin_side = platform.width
	platform.position.x = rng.randf_range(0, bg_width - margin_side)
