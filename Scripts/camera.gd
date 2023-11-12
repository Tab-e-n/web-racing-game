extends Camera2D


func _physics_process(_delta):
	if Net.is_a_spectator:
		var speed_up = 1
		if Input.is_action_pressed("shift"):
			speed_up = 2.5
		if Input.is_action_pressed("left"):
			position.x -= 10 * speed_up
		if Input.is_action_pressed("right"):
			position.x += 10 * speed_up
		if Input.is_action_pressed("up"):
			position.y -= 10 * speed_up
		if Input.is_action_pressed("down"):
			position.y += 10 * speed_up
	else:
		var target = get_parent().get_node("Racecar")
		position = (target as Node2D).position
