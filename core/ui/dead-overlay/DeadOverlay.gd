extends CenterContainer

signal restart_game

func on_restart_game():
	emit_signal("restart_game")
