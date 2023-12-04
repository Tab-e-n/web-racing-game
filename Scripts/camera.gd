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

var player_list : Dictionary = {}



func _ready():
	$countdown.modulate.a = 0
	$on_finish_image.modulate.a = 0
	
	player_list[Net.multiplayer.get_unique_id()] = [Net.players[Net.multiplayer.get_unique_id()]["name"], 0, 0]
	update_visual_player_list()
	
	#player list update connection
	Net.recieved_time.connect(update_player_list)
	Net.player_connected.connect(update_player_list)
	Net.player_disconnected.connect(delete_player_from_player_list)
	
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
	if Input.is_key_pressed(KEY_TAB):
		$player_list.visible = true
	elif $player_list.visible == true:
		$player_list.visible = false
	
	#car stats
	$"car_stats/gear".text = "gear: " + str($"../Racecar".gear)
	$"car_stats/speed".text = "speed: " + str(int($"../Racecar".curr_speed))
	

func vote_button_pressed(vote):
	Net.vote_map(vote)
	
	
func choose_button_pressed(map):
	Net.current_track_name = map 


func delete_player_from_player_list(peer_id):
	player_list.erase(peer_id)

func update_player_list(peer_id, time = null, lap = null):
	print(peer_id, " ", time, " ", lap)
	if time is float:
		player_list[peer_id] = [Net.players[peer_id]["name"], time, lap]
	else:
		player_list[peer_id] = [Net.players[peer_id]["name"], 0, 0]
	update_visual_player_list()


func update_visual_player_list():
	print(player_list)
	$player_list.clear()
	for player in player_list.values():
		$player_list.add_item(player[0] + " / "+ format_time(player[1]) + " / lap: " + str(player[2]))
	

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


func _on_gameplay_race_finished(final_time):
	$on_finish_image.modulate = Color(0, 0, 0, 1)
	$score/timer.text = format_time(final_time)
	race_finished = true
	reset_fadeout.call()
