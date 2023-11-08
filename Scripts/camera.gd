extends Camera2D


func _physics_process(_delta):
	var target = get_parent().get_node("Racecar")
	position = (target as Node2D).position
