extends Camera2D


func _physics_process(delta):
	position = get_parent().get_node("Racecar").position
