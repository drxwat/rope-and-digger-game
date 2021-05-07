extends CenterContainer

onready var label := $VBoxContainer/Level

func show_level(level: int, with_reward = false):
	$VBoxContainer/Reward.visible = with_reward
	label.text = "Level " + str(level)
	$AnimationPlayer.play("show_level")

func show_message(message):
	$AudioStreamPlayer.play()
	label.text = message
	$AnimationPlayer.play("show_level")
