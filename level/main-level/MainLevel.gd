extends Node2D

export var falling_speed := 300.0

onready var bg1 := $Backgrounds/Background1
onready var platforms := $Platforms

var bg_height : float = 0
var is_mooving := true

func _ready():
	bg_height = $Backgrounds/Background1.texture.get_size().y * $Backgrounds/Background1.scale.y


func move_bg_to_bottom(background: Node2D):
	background.position.y += 3 * bg_height

