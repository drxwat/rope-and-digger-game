extends StaticBody2D
class_name Cristall

func pick_up():
	$AnimatedSprite.hide()
	$PickUpPlayer.play()
	$AnimationPlayer.play("show_reward")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

