extends MarginContainer

onready var coin_counter := $Grid/Row1/CoinCounter
onready var hp_bar := $Grid/Row1/HPBar
onready var left_arrow := $VBoxContainer/Controlls/Left
onready var right_arrow := $VBoxContainer/Controlls/Right

var active_color = Color(1, 1, 1, 1)
var default_color = Color(1, 1, 1, .5)

func update_coins_requirements(value: int):
	coin_counter.set_coins_req(value)

func update_coins_counter(value: int):
	coin_counter.set_coins_amount(value)

func update_hp(value: int):
	hp_bar.update_health(value)

func update_move_dir(direction: Vector2):
	if direction.x > 0:
		right_arrow.modulate = active_color
		left_arrow.modulate = default_color
	elif direction.x < 0:
		right_arrow.modulate = default_color
		left_arrow.modulate = active_color
	else:
		right_arrow.modulate = default_color
		left_arrow.modulate = default_color
