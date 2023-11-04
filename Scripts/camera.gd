extends Camera2D

func _physics_process(delta):
	var target = get_parent().get_node("Racecar")
	if target != null:
		position = target.position
