extends CenterContainer

signal restart_game

func on_restart_game():
	$VBoxContainer/NewRecord.hide()
	emit_signal("restart_game")

func set_score(score: int, is_new_record = false):
	if is_new_record:
		$VBoxContainer/NewRecord.show()
	$VBoxContainer/Score/Label.text = str(score)
