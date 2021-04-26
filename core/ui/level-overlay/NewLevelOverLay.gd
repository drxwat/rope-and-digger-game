extends CenterContainer

func show_level(level: int):
	$Level.text = "Level " + str(level)
	$AnimationPlayer.play("show_level")
