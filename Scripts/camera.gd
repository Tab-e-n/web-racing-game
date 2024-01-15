extends Camera2D

const COUNTDOWN_TEXTURES = [preload("res://Textures/ui/countdown/0.png"),
						preload("res://Textures/ui/countdown/1.png"),
						preload("res://Textures/ui/countdown/2.png"),
						preload("res://Textures/ui/countdown/3.png")]
	
const CHOOSE_BUTTONS_SIZE = 30

var fadeout_speed_countdown : float = 0.005
var fadeout_speed_finish : float = 0.01
var fadeout_buffer = 0
var reset_fadeout = func(): fadeout_buffer = 0

var race_finished : bool = false

var voting : bool = false


func _ready():
	$countdown.modulate.a = 0
	$on_finish_image.modulate.a = 0
	
	update_player_list()
	
	#player list update connection
	Net.recieved_time.connect(update_player_list_time)
	Net.player_connected.connect(update_player_list)
	Net.player_disconnected.connect(update_player_list)
	
	get_parent().race_finished.connect(_on_gameplay_race_finished)
	
	#crete vote buttons	
	for i in range(len($vote_buttons.get_children())):
		$vote_buttons.get_child(i).connect("button_down", vote_button_pressed.bind(i))
	
	#create choose buttons
	if Net.multiplayer.is_server():
		for map in Net.VOTE_POSSIBILITIES:
			var button = Button.new()
			button.text = map
			button.custom_minimum_size.y = CHOOSE_BUTTONS_SIZE
			button.connect("button_down", choose_button_pressed.bind(map))
		
			$choose_buttons.add_child(button)
		
		var start_button = Button.new()
		start_button.text = "start countdown"
		start_button.custom_minimum_size.y = CHOOSE_BUTTONS_SIZE
		start_button.modulate = Color(0.8, 0.8, 0.1)
		
		var start = func():
			Net.start_countdown.rpc()
			Net.temp_start_countdown = false
			$choose_buttons.queue_free()
			
		start_button.connect("button_down", start.bind())
		$choose_buttons.add_child(start_button)
	
	$"../Racecar".gear_shifting.connect(_on_gear_shifting)


func _physics_process(_delta):
	$speedometer.visible = !(Global.ui_hidden or Net.is_a_spectator)
	$minimap.visible = !(Global.ui_hidden or Net.is_a_spectator)
	$score.visible = !(Global.ui_hidden or Net.is_a_spectator)
	$car_stats.visible = Global.debug_mode
	
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
		var target : Node2D = get_parent().get_node("Racecar")
		position = (target as Node2D).position
	
	#countdown
	if (get_parent() as Gameplay).countdown_has_started && (get_parent() as Gameplay).countdown > 0:
		reset_fadeout.call()
		race_finished = false
		$countdown.modulate = Color(0, 0, 0, 1)
		$countdown.texture = COUNTDOWN_TEXTURES[int((get_parent() as Gameplay).countdown) + 1]
		
		if voting:
			$vote_buttons.visible = false
			voting = false
		
	elif $countdown.modulate.a > 0:
		$countdown.texture = COUNTDOWN_TEXTURES[0]
		fade_out($countdown, fadeout_speed_countdown)
	
	#timer a pocitani kol
	if !race_finished:
		$score/timer.text = format_time((get_parent() as Gameplay).race_timer)
	
	$score/lap_count.text = "lap: %d" % (get_parent() as Gameplay).current_lap + " / %d" %  (get_parent() as Gameplay).lap_count
	
	#finish obrazek
	if $on_finish_image.modulate.a > 0:
		fade_out($on_finish_image, fadeout_speed_finish)
	
	#player list
	$players.visible = Input.is_key_pressed(KEY_TAB)
	
	#car stats
	$"car_stats/gear".text = "gear: " + str($"../Racecar".gear)
	$"car_stats/speed".text = "speed: " + str(int($"../Racecar".curr_speed))
	
	$speedometer.pixel_speed = $"../Racecar".curr_speed
	$gearshift.animation_frame = $"../Racecar".switching_gears_timer / 2 - 1
	$gearshift.update()
	if $"../Racecar".curr_speed < 0 and $gearshift.end_gear != -1:
		$gearshift.new_gear_shift(-1, $gearshift.end_gear)
		$gearshift.self_update(30)
	if $"../Racecar".curr_speed >= 0 and $gearshift.end_gear == -1:
		$gearshift.new_gear_shift(0, -1)
		$gearshift.self_update(30)
	

func vote_button_pressed(vote):
	Net.vote_map(vote)
	
	
func choose_button_pressed(map):
	Net.change_map.rpc(map)


func update_player_list_time(_peer_id, _time, _laps):
	update_player_list(_peer_id)

func update_player_list(_peer_id = 1):
	#print(player_list)
	for i in Net.players.keys():
		if not $players.player_list.has(i):
			$players.add_player(i, Net.players[i]["name"])
	for i in $players.player_list.keys():
		if not Net.players.has(i):
			$players.remove_player(i)
	
	for player in Net.players.keys():
		$players.player_list[player][1].text = format_time(Net.players[player]["time"])
		$players.player_list[player][2].text = "lap: " + str(Net.players[player]["laps"])


func fade_out(node, fadeout_speed):
	fadeout_buffer += fadeout_speed
	node.modulate = node.modulate.lerp(Color(0, 0, 0, 0), fadeout_buffer)


func format_time(time):
	var format_zeros = func(x): return "0%d" % x if x / 10 < 1 else "%d" % x
	
	var text = "time: "
	text += format_zeros.call(int(int(time / 60) % 60)) #minuty
	text += ":" + format_zeros.call(int(int(time) % 60)) #sekundy
	text += ":" + format_zeros.call(int(int(time * 60) % 60)) #milisekundy
	return text
	

func start_vote():
	$vote_buttons.visible = true
	voting = true
	
	for i in range(len($vote_buttons.get_children())):
		$vote_buttons.get_child(i).text = Net.vote_options[i]


func _on_gameplay_race_finished(final_time, _lap):
	$on_finish_image.modulate.a = 1
	$score/timer.text = format_time(final_time)
	race_finished = true
	reset_fadeout.call()


func _on_gear_shifting(new_gear : int, old_gear : int):
	if $gearshift.end_gear == -1:
		$gearshift.new_gear_shift(new_gear, -1)
	else:
		$gearshift.new_gear_shift(new_gear, old_gear)
