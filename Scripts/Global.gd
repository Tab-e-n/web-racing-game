extends Node


var debug_mode = false


func _physics_process(_delta):
	if Input.is_action_just_pressed("debug") and OS.has_feature("editor"):
		debug_mode = !debug_mode
	if Input.is_action_just_pressed("esc"):
		get_tree().change_scene_to_file("res://menu.tscn")

