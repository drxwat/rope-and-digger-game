extends Node

var current_scene_ref: WeakRef
var pause_screen: Control

var show_pause_sceen = false
var is_game_started = false

onready var game_scene = preload("res://level/main-level/MainLevel.tscn")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var root = get_tree().get_root()
	var scene = root.get_child(root.get_child_count() - 1)
	current_scene_ref = weakref(scene)

func _process(delta):
	if is_game_started and Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func goto_scene(scene: PackedScene):
	call_deferred("_deferred_goto_scene", scene)

func toggle_pause():
	show_pause_sceen = !show_pause_sceen
	if pause_screen:
		if show_pause_sceen:
			pause_screen.show()
		else:
			pause_screen.hide()
	get_tree().paused = show_pause_sceen

func start_new_game():
	is_game_started = true
	goto_scene(game_scene)

func exit_game():
	get_tree().quit()

func _deferred_goto_scene(scene: PackedScene):
	# It is now safe to remove the current scene
	var current_scene = current_scene_ref.get_ref()
	if current_scene:
		current_scene.free()

	# Instance the new scene.
	var new_scene = scene.instance()
	current_scene_ref = weakref(new_scene)

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(new_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(new_scene)
