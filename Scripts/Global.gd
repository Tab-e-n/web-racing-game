extends Node


var debug_mode = false


func _physics_process(_delta):
	if Input.is_action_just_pressed("debug"):
		debug_mode = !debug_mode

