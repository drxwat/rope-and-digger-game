extends Node2D

export var platform_spawn_time := 3
export var spikes_probability := 0.3
export var mooving_platform_probability := 0.4
export var platform_speed_range := Vector2(150, 350)

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
var coin_scene = preload("res://core/coin/Coin.tscn")
var spikes_scene = preload("res://core/spikes/Spikes.tscn")
var bat_sceene = preload("res://core/bat/Bat.tscn")

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
	var platform = _place_random_platrom()
	_place_coin_on_platform(platform)
	_place_spikes_on_platform(platform)
	
func spawn_bat():
	var bat = bat_sceene.instance()
	var y_position = get_viewport().size.y
	bat.gravity = player.gravity - 100
	bat.position = Vector2(rng.randf_range(50, bg_width - 50), player.spawn_position.global_position.y)
	add_child(bat)
	
func _place_random_platrom() -> Node2D:
	var platform =  platforms[PlatfromsTypes.SIMPLE].instance()
	platform.move_amplitude = bg_width
	platform.move_speed = rng.randf_range(platform_speed_range.x, platform_speed_range.y)
	platform.is_mooving = rng.randf_range(0, 1) > mooving_platform_probability
	var distance_to_player = bottom_bg.position.y - player.position.y
	var margin_bottom = player_to_bottom_bg_normal_dist - distance_to_player
	var platform_y_position = margin_bottom + bottom_bg.position.y
	platform.position = Vector2(0, platform_y_position)
	platforms_container.add_child(platform)
	var margin_side = platform.width / 2
	platform.position.x = rng.randf_range(margin_side, bg_width - margin_side)
	return platform

func _place_coin_on_platform(platform: Node2D):
	var coins_amount = rng.randi_range(0, 1)
	if coins_amount == 0:
		return
	var coin = coin_scene.instance()
	platform.add_child(coin)
	coin.position = Vector2(0, -80)
	
func _place_spikes_on_platform(platform: Node2D):
	var place_spikes = rng.randf_range(0, 1) <= spikes_probability
	if not place_spikes:
		return
	var spikes1 = spikes_scene.instance()
	var spikes2 = spikes_scene.instance()
	platform.add_child(spikes1)
	platform.add_child(spikes2)
	spikes1.position = Vector2(-platform.width / 4, -35)
	spikes2.position = Vector2(platform.width / 4, -35)
	
	
