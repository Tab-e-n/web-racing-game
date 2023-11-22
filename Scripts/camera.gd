extends Camera2D

var countdown_textures = [load("res://Textures/ui/countdown/0.png"),
						load("res://Textures/ui/countdown/1.png"),
						load("res://Textures/ui/countdown/2.png"),
						load("res://Textures/ui/countdown/3.png")]
	
var vote_buttons;

var fadeout_speed_countdown : float = 0.005
var fadeout_speed_finish : float = 0.01
var fadeout_buffer = 0
var reset_fadeout = func(): fadeout_buffer = 0

var race_finished : bool = false

var voting : bool = false

var player_count_buffer = 0



func _ready():
	$on_finish_image.modulate = Color(0, 0, 0, 0)
	vote_buttons = [$vote_buttons/b1, $vote_buttons/b2, $vote_buttons/b3, $vote_buttons/b4]
	
	for i in range(len(vote_buttons)):
		vote_buttons[i].connect("button_down", vote_button_pressed.bind(i))

func _physics_process(_delta):
	#jenom pro debug
	if Input.is_key_pressed(KEY_DELETE):
		(get_parent() as Gameplay).player_did_a_lap()
		
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
	
	#countdown
	if (get_parent() as Gameplay).countdown_has_started && (get_parent() as Gameplay).countdown > 0:
		reset_fadeout.call()
		race_finished = false
		$countdown.modulate = Color(0, 0, 0, 1)
		$countdown.texture = countdown_textures[int((get_parent() as Gameplay).countdown) + 1]
		
		if voting:
			$vote_buttons.visible = false
			voting = false
		
	elif $countdown.modulate.a > 0:
		$countdown.texture = countdown_textures[0]
		fade_out($countdown, fadeout_speed_countdown)
	
	#timer a pocitani kol
	if !race_finished:
		$score/timer.text = format_time((get_parent() as Gameplay).race_timer)
	
	$score/lap_count.text = "lap: %d" % (get_parent() as Gameplay).current_lap + " / %d" %  (get_parent() as Gameplay).lap_count
	
	#finish obrazek
	if $on_finish_image.modulate.a > 0:
		fade_out($on_finish_image, fadeout_speed_finish)
	
	#player list
	if Input.is_key_pressed(KEY_TAB):
		$player_list.visible = true
	elif $player_list.visible == true:
		$player_list.visible = false
	
	if(player_count_buffer != len(Net.players)):
		update_player_list()
	player_count_buffer = len(Net.players)
	
	#car stats
	$"car_stats/gear".text = "gear: " + str($"../Racecar".gear)
	$"car_stats/speed".text = "speed: " + str(int($"../Racecar".curr_speed))


func vote_button_pressed(vote):
	Net.vote_map(vote)


func update_player_list():
	var text = ""
	for p in Net.players:
		text += Net.players[p]["name"] + "\n"
	$player_list.text = text


func fade_out(node, fadeout_speed):
	fadeout_buffer += fadeout_speed
	node.modulate = node.modulate.lerp(Color(0, 0, 0, 0), fadeout_buffer)


func format_time(time):
	var format_zeros = func(x): return "0%d" % x if x / 10 < 1 else "%d" % x
	
	var text = "time: "
	text += format_zeros.call(int(int((get_parent() as Gameplay).race_timer / 60) % 60)) #minuty
	text += ":" + format_zeros.call(int(int((get_parent() as Gameplay).race_timer) % 60)) #sekundy
	text += ":" + format_zeros.call(int(int((get_parent() as Gameplay).race_timer * 60) % 60)) #milisekundy
	return text
	

func start_vote():
	$vote_buttons.visible = true
	voting = true
	
	for i in range(len(vote_buttons)):
		vote_buttons[i].text = Net.vote_options[i]


func _on_gameplay_race_finished(final_time):
	$on_finish_image.modulate = Color(0, 0, 0, 1)
	$score/timer.text = format_time(final_time)
	race_finished = true
	reset_fadeout.call()
