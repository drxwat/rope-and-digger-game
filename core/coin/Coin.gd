extends StaticBody2D
class_name Coin

func pick_up():
	$AnimatedSprite.play("pick_up")
	$AnimatedSprite.position.y -= 45
	yield($AnimatedSprite, "animation_finished")
	queue_free()
