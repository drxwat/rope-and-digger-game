extends CenterContainer

func show_level(level: int, with_reward = false):
	$VBoxContainer/Reward.visible = with_reward
	$VBoxContainer/Level.text = "Level " + str(level)
	$AnimationPlayer.play("show_level")
