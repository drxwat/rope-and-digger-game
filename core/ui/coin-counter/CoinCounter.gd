extends HBoxContainer

onready var coins_amount_label = $CoinsAmount

func set_coins_amount(value: int):
	coins_amount_label.text = str(value)
