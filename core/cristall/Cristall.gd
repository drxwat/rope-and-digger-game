extends StaticBody2D
class_name Cristall

func pick_up():
	$PickUpPlayer.play()
	yield($PickUpPlayer, "finished")
	queue_free()

