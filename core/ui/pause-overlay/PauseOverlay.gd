extends CenterContainer

signal restart_game

func _ready():
	Global.pause_screen = self

func on_continue_game():
	Global.toggle_pause()
	
func on_restart_game():
	emit_signal("restart_game")
	
func on_exit_game():
	Global.exit_game()
