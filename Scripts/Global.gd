extends Node


var debug_mode = false
var exiting : float = 0
var exit_vis : Label = null


func _physics_process(delta):
	if Input.is_action_just_pressed("debug") and OS.has_feature("editor"):
		debug_mode = !debug_mode
	
	if exiting > 0:
		if exit_vis == null:
			make_exit_vis()
		exit_vis.progress = exiting
	else:
		if exit_vis != null:
			exit_vis.queue_free()
	
	if exiting > 1:
		if get_tree().current_scene is Menu:
			get_tree().quit()
		else:
			get_tree().change_scene_to_file("res://menu.tscn")
		exiting = 0
	
	if Input.is_action_pressed("esc"):
		exiting += delta
	else:
		exiting = 0


func make_exit_vis():
	var packed : PackedScene = preload("res://Objects/exiting_bar.tscn")
	exit_vis = packed.instantiate()
	exit_vis.line = "Exiting"
	
	var curr_scene = get_tree().current_scene
	if get_viewport().get_camera_2d() != null:
		curr_scene = get_viewport().get_camera_2d()
		exit_vis.position = -get_viewport().get_window().size / Vector2i(2, 2)
	curr_scene.add_child(exit_vis)
	
