extends MarginContainer

onready var coin_counter := $Grid/Row1/CoinCounter
onready var hp_bar := $Grid/Row1/HPBar

func update_coins_counter(value: int):
	coin_counter.set_coins_amount(value)

func update_hp(value: int):
	print(value)
	hp_bar.update_health(value)
