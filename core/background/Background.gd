extends Sprite
class_name Background

signal screen_exited

func on_screen_exited():
	emit_signal("screen_exited", self)
