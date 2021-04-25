extends MarginContainer

onready var coin_counter := $Grid/Row1/CoinCounter

func update_coins_counter(value: int):
	coin_counter.set_coins_amount(value)
