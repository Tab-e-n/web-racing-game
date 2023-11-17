extends Camera2D

var countdown_textures = [load("res://Textures/ui/countdown/0.png"),
	load("res://Textures/ui/countdown/1.png"),
	load("res://Textures/ui/countdown/2.png"),
	load("res://Textures/ui/countdown/3.png")]


var fadeout_speed : float = 0.07
var fadeout_buffer = 0



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
	
	if (get_parent() as Gameplay).countdown_has_started && (get_parent() as Gameplay).countdown > 0:
		$countdown.texture = countdown_textures[int((get_parent() as Gameplay).countdown) + 1]
	else:
		$countdown.texture = countdown_textures[0]
		fade_out(_delta)
	
	#timer
	var text = "time: "
		
	text += format_time(int(int((get_parent() as Gameplay).race_timer / 60) % 60)) #minuty
	text += ":" + format_time(int(int((get_parent() as Gameplay).race_timer) % 60)) #sekundy
	text += ":" + format_time(int(int((get_parent() as Gameplay).race_timer * 60) % 60)) #milisekundy
	$score/timer.text = text
	
	#pocitani kol
	$score/lap_count.text = "lap: %d" % (get_parent() as Gameplay).current_lap + " / %d" %  (get_parent() as Gameplay).lap_count


func fade_out(_delta):
	fadeout_buffer += _delta * fadeout_speed
	$countdown.modulate = $countdown.modulate.lerp(Color(0, 0, 0, 0), fadeout_buffer)
	
func format_time(time):
	return "0%d" % time if time / 10 < 1 else "%d" % time
