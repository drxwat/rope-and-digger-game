extends Node2D

signal level_requirement_changed

export var top_spikes_probability := 0.05
export var side_spikes_probability := 0.05
export var mooving_platform_probability := 0.4
export var platform_speed_range := Vector2(150, 350)
export var platform_spawn_distance := 450.0 
export var pattern_spawn_distance := 1500.0
export var bat_timeout := 10
export var small_platform_probability := 0.3
export var coin_vs_cristall_small_prb := 0.3
export var coin_vs_cristall_medium_prb := 0.8


onready var bg1 : Background = $Backgrounds/Background1
onready var bottom_bg : Background = $Backgrounds/Background3
onready var platforms_container := $Platforms
onready var player := $Player
onready var bat_timer := $Timers/BatTimer
onready var admob := $AdMob

var complexity_change = {
	"top_spikes_probability": 0.05,
	"side_spikes_probability": 0.05,
	"mooving_platform_probability": 0.05,
	"platform_speed_range": Vector2(25, 25),
	"platform_spawn_distance": -10,
	"bat_timeout": -1,
	"bat_start_level": 4,
	"two_bats_start_level": 7,
}

var is_addmob_loaded := false

var bg_height : float = 0
var bg_width : float = 0
var player_to_bottom_bg_normal_dist : float = 0
var rng = RandomNumberGenerator.new()
var next_platform_y: float
var next_pattern_y: float

var level := 1
var coins_level := 50
var next_coins_level := 100
var spawn_two_bats := false

enum PlatformTypes { SIMPLE, SIDE_SPIKES, TOP_SPIKES, TOP_SIDE_SPIKES }

var meduim_platforms = {
	PlatformTypes.SIMPLE: preload("res://core/platforms/platform-simple/PlatformSimple.tscn"),
	PlatformTypes.SIDE_SPIKES: preload("res://core/platforms/meduim/side-spikes/Platform-M-SS.tscn"),
	PlatformTypes.TOP_SPIKES: preload("res://core/platforms/meduim/top-spikes/Platform-M-TS.tscn"),
	PlatformTypes.TOP_SIDE_SPIKES: preload("res://core/platforms/meduim/top-side-spikes/Platform-M-TSS.tscn")
}

var small_platforms = {
	PlatformTypes.SIMPLE: preload("res://core/platforms/small/PlatformS.tscn"),
	PlatformTypes.SIDE_SPIKES: preload("res://core/platforms/small/side-spikes/PlatformS-SS.tscn"),
	PlatformTypes.TOP_SPIKES: preload("res://core/platforms/small/top-spikes/PlatformS-TS.tscn"),
	PlatformTypes.TOP_SIDE_SPIKES: preload("res://core/platforms/small/top-side-spikes/PlatformS-TSS.tscn")
}


var coin_scene = preload("res://core/coin/Coin.tscn")
var cristall_scene = preload("res://core/cristall/Cristall.tscn")
var spikes_scene = preload("res://core/spikes/Spikes.tscn")
var bat_sceene = preload("res://core/bat/Bat.tscn")

var coin_patterns = {
	0: preload("res://core/coin/pattern-1/CoinPattern1.tscn"),
	1: preload("res://core/coin/pattern-2/CoinPattern2.tscn"),
	2: preload("res://core/coin/pattern-3/CoinPattern3.tscn")
}

func _ready():
	Global.is_game_started = true
	rng.randomize()
	$Timers/BatTimer.wait_time = bat_timeout
	bg_height = $Backgrounds/Background1.texture.get_size().y * $Backgrounds/Background1.scale.y
	bg_width =  $Backgrounds/Background1.texture.get_size().x * $Backgrounds/Background1.scale.x
	player_to_bottom_bg_normal_dist = bottom_bg.position.y - player.position.y
	emit_signal("level_requirement_changed", coins_level)
	show_level_overlay()
	admob.load_interstitial()

func _physics_process(delta):
	if player.position.y >= next_platform_y:
		spawn_platform()
		next_platform_y = player.position.y + platform_spawn_distance
		
	if player.position.y >= next_pattern_y:
		spawn_coin_pattern()
		next_pattern_y = player.position.y + pattern_spawn_distance


func check_for_level_up(coins):
	if coins >= coins_level:
		level += 1
		update_level_req()
		level_up_player()
		increese_complexity()
		show_level_overlay()

func update_level_req():
	var next_fibonacci = coins_level + next_coins_level
	coins_level = next_coins_level
	next_coins_level = next_fibonacci
	emit_signal("level_requirement_changed", coins_level)

func increese_complexity():
	top_spikes_probability += complexity_change.top_spikes_probability
	side_spikes_probability += complexity_change.side_spikes_probability
	mooving_platform_probability += complexity_change.mooving_platform_probability
	platform_speed_range += complexity_change.platform_speed_range
	platform_spawn_distance += complexity_change.platform_spawn_distance
	if level >= complexity_change.bat_start_level:
		bat_timer.wait_time += complexity_change.bat_timeout
		bat_timer.start()
	if level >= complexity_change.two_bats_start_level:
		spawn_two_bats = true

func show_level_overlay():
	$CanvasLayer/LevelOverLay.show_level(level)

func level_up_player():
	player.heal()
	if level % 2 == 0:
		player.level_up()

func show_game_over():
	if is_addmob_loaded:
		admob.show_interstitial()
	else:
		show_dead_oberlay()

func on_interstitial_failed(error_code):
	is_addmob_loaded = false
	print("ADMOB ERR CODE ", error_code)
	
func on_interstitial_loaded():
	is_addmob_loaded = true

func show_dead_oberlay():
	$CanvasLayer/DeadOverlay.show()
	get_tree().paused = true

func restart_level():
	get_tree().paused = false
	Global.start_new_game()

func move_bg_to_bottom(background: Background):
	background.position.y += 3 * bg_height
	bottom_bg = background

func spawn_coin_pattern():
	var pattern_i = rng.randi_range(0, 2)
	var pattern = coin_patterns[pattern_i].instance()
	var distance_to_player = bottom_bg.position.y - player.position.y
	var margin_bottom = player_to_bottom_bg_normal_dist - distance_to_player
	var pattern_y_position = margin_bottom + bottom_bg.position.y
	pattern.position = Vector2(0, pattern_y_position)
	add_child(pattern)

func spawn_platform():
	var platform_config = _get_random_platform()
	var is_small = platform_config[0]
	var platform_type_id = platform_config[1]
	var platform = platform_config[2]
	_place_platform(platform)

	if is_small and rng.randf_range(0, 1) > coin_vs_cristall_small_prb:
		_place_cristall_on_platform(platform)
	elif not is_small and rng.randf_range(0, 1) > coin_vs_cristall_small_prb:
		_place_cristall_on_platform(platform)
	else:
		_place_coin_on_platform(platform)
	
func spawn_bat():
	_place_bat()
	if spawn_two_bats:
		_place_bat()
	
func _place_bat():
	var bat = bat_sceene.instance()
	var y_position = get_viewport().size.y
	bat.gravity = player.gravity - 100
	bat.position = Vector2(rng.randf_range(50, bg_width - 50), player.spawn_position.global_position.y)
	add_child(bat)

func _get_random_platform():
	var is_small = rng.randf_range(0, 1) > small_platform_probability
	var has_top_spikes = rng.randf_range(0, 1) <= top_spikes_probability
	var has_side_spikes = rng.randf_range(0, 1) <= side_spikes_probability
	var platform_type_id = 0
	if has_side_spikes:
		platform_type_id += 1
	if has_top_spikes:
		platform_type_id += 2
	var platform_scene = small_platforms[platform_type_id] if is_small else meduim_platforms[platform_type_id]
	return [is_small, platform_type_id, platform_scene.instance()]

func _place_platform(platform: Node2D) -> void:
	platform.move_amplitude = bg_width
	platform.move_speed = rng.randf_range(platform_speed_range.x, platform_speed_range.y)
	platform.is_mooving = rng.randf_range(0, 1) > mooving_platform_probability
	var distance_to_player = bottom_bg.position.y - player.position.y
	var margin_bottom = player_to_bottom_bg_normal_dist - distance_to_player
	var platform_spawn_deviation = platform_spawn_distance / 3.0
	var platform_y_deviation = rng.randf_range(-platform_spawn_deviation, platform_spawn_deviation)
	var platform_y_position = margin_bottom + bottom_bg.position.y + platform_y_deviation
	platform.position = Vector2(0, platform_y_position)
	platforms_container.add_child(platform)
	var margin_side = platform.width / 2
	platform.position.x = rng.randf_range(margin_side, bg_width - margin_side)

func _place_coin_on_platform(platform: Node2D):
	var coin = coin_scene.instance()
	platform.add_child(coin)
	coin.position = Vector2(0, -80)
	
func _place_cristall_on_platform(platform: Node2D):
	var cristall = cristall_scene.instance()
	platform.add_child(cristall)
	cristall.position = Vector2(0, -80)
