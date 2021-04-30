extends HBoxContainer

onready var coins_amount_label = $CoinsAmount

var req := 0
var val := 0

func set_coins_req(value: int):
	req = value
	update_ui()

func set_coins_amount(value: int):
	val = value
	update_ui()

func update_ui():
	coins_amount_label.text = str(val) + "/" + str(req)
