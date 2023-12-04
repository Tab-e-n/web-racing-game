extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20
const END_OF_RACE_TIMEOUT : float = 60
const VOTE_TIME : float = 20
const NUMBER_OF_VOTE_OPTIONS : int = 4

const VOTE_POSSIBILITIES : Dictionary = {
	"Anti Testies" : "AntiTesties.tscn",
	"Funny Ice Physics" : "funny_ice_physics.tscn",
	"test_scene" : "test_scene.tscn",
	"Trees Trees Trees" : "test_scene_1.tscn",
	"DA WORLD" : "THEWORLD.tscn",
}


var TIME_TO_TIMEOUT : float = 360

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {
}
# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"name": "Guest",
	"palette" : 0,
	"time" : 0,
	"laps" : 0,
	"finished" : false,
	"car_data" : {},
}
var players_loaded = []
var is_a_player : bool = true
var is_a_spectator : bool = false

var current_track_name : String = "test_scene"

var time_till_timeout : float = 0
var vote_timer : float = 0

var votes : Dictionary = {}
var vote_options : Array = ["test_scene", "test_scene", "test_scene", "test_scene"]

var temp_start_countdown : bool = true
var gameplay_active : bool = false

func reset():
	players = {}
	players_loaded = []
	is_a_player = true
	is_a_spectator = false
	current_track_name = "test_scene"
	time_till_timeout = 0
	vote_timer = 0
	votes = {}
	vote_options = ["test_scene", "test_scene", "test_scene", "test_scene"]
	gameplay_active = false

func _ready():
	reset()
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _physics_process(delta):
	if multiplayer.multiplayer_peer != null:
		if multiplayer.is_server() and gameplay_active:
			get_car_data.rpc()
			
			if time_till_timeout > 0:
				time_till_timeout -= delta
				if time_till_timeout <= 0:
					end_race()
			
			if vote_timer > 0:
				vote_timer -= delta
				var players_amount = players.size()
				if not is_a_player:
					players_amount -= 1
				if votes.size() >= players.size():
					vote_timer -= delta * 2
				if vote_timer <= 0:
					do_a_new_round()
			
			if players_loaded.size() == players.size() and not temp_start_countdown:
				players_loaded = []
				start_countdown.rpc()
			
			if Input.is_action_just_pressed("F1") and temp_start_countdown:
				start_countdown.rpc()
				temp_start_countdown = false
#			print("server")


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	temp_start_countdown = false


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)
	
	temp_start_countdown = true
	print("default map: ", current_track_name)
#	call_deferred("start_countdown")


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	print("i disconnected myself")


# The server will call this ever so often to tell every peer
# to send information about where they are, their speed and their rotation.
@rpc("authority", "call_local", "unreliable")
func get_car_data():
	if is_a_spectator or not is_a_player:
		send_car_data.rpc({})
		return
	if get_tree().current_scene.has_method("get_car_data"):
		var car_data = get_tree().current_scene.get_car_data()
		send_car_data.rpc(car_data)
	else:
		send_car_data.rpc({})


@rpc("any_peer", "call_remote", "unreliable")
func send_car_data(car_data : Dictionary):
	var peer_id = multiplayer.get_remote_sender_id()
	if players.has(peer_id):
		players[peer_id]["car_data"] = car_data.duplicate()
#		print("data_recieved")


@rpc("authority", "call_remote", "reliable")
func send_game_info(game_info : Dictionary):
	print("i got sent game info")
	
	current_track_name = game_info["track_name"]
	if game_info["become_spectator"]:
		become_spectator()
	else:
		become_player()


func do_a_new_round():
	print("new round starting")
	vote_timer = 0
	players_loaded = [1]
	
	var top_vote = count_votes()
	change_map.rpc(vote_options[top_vote])


@rpc("authority", "call_local", "reliable")
func change_map(track_name : String):
	print("changing map: ", track_name)
	
	if track_name == current_track_name:
		call_deferred("set", "current_track_name", track_name)
		track_name = ""
	current_track_name = track_name
	send_time.rpc(0, false, 0)
	
	become_player()


@rpc("any_peer", "call_remote", "reliable")
func map_loaded():
	var peer_id = multiplayer.get_remote_sender_id()
	print("player ", peer_id, " loaded the map")
	if not players_loaded.has(peer_id):
		players_loaded.append(peer_id)


# This will start the race. Usually it gets called automatically,
# But it needs to get called manually when the lobby is created.
@rpc("authority", "call_local", "reliable")
func start_countdown():
	print("starting countdown")
	
	if get_tree().current_scene is Gameplay:
		get_tree().current_scene.start_race()
	if multiplayer.is_server():
		print("timeout in: ", TIME_TO_TIMEOUT, " seconds")
		time_till_timeout = TIME_TO_TIMEOUT
	
	become_player()


@rpc("any_peer", "call_local", "reliable")
func send_time(time : float, done : bool, laps : int = -1):
	print("my time: ", snapped(time,  0.01))
	var peer_id = multiplayer.get_remote_sender_id()
	if players.has(peer_id):
		players[peer_id]["time"] = time
		if laps != -1:
			players[peer_id]["laps"] = laps
		players[peer_id]["finished"] = done
	if multiplayer.is_server() and done:
		if time_till_timeout > END_OF_RACE_TIMEOUT:
			time_till_timeout = END_OF_RACE_TIMEOUT
			print("timeout in: ", END_OF_RACE_TIMEOUT, " seconds")
		check_player_finish()


func check_player_finish():
	for i in players:
		if not players[i]["finished"] and not players[i]["car_data"].is_empty():
			return
	print("everyone finished")
	end_race()


func _on_race_finished(race_timer):
	print("i finished")
	send_time.rpc(race_timer, true)


func _on_lap_finished(race_timer, lap):
	send_time.rpc(race_timer, false, lap)


# This is the function that the UI can call when the player
# chooses the vote option. It can be called multiple times,
# only the most recent vote will count.
func vote_map(vote):
	print("i voted for ", vote)
	send_map_vote.rpc_id(1, vote)


@rpc("any_peer", "call_local", "reliable")
func send_map_vote(vote):
	var peer_id = multiplayer.get_remote_sender_id()
	if vote < 0 or vote > NUMBER_OF_VOTE_OPTIONS:
		return
	print("player ", peer_id, " voted for ", vote)
	votes[peer_id] = vote


func count_votes() -> int:
	var vote_count = []
	for i in range(NUMBER_OF_VOTE_OPTIONS):
		vote_count.append(0)
	
	for i in votes.values():
		vote_count[i] += 1
	
	var highest = 0
	var top_vote = []
	for i in range(NUMBER_OF_VOTE_OPTIONS):
		if vote_count[i] > highest:
			highest = vote_count[i]
			top_vote = [i]
		if vote_count[i] == highest:
			top_vote.append(i)
	
	var rng = RandomNumberGenerator.new()
	var vote_winner = top_vote[rng.randi_range(0, top_vote.size() - 1)]
	print(vote_winner, ". map won with ", highest, " votes ", vote_count)
	return vote_winner


func generate_vote_options():
	var possibilities = VOTE_POSSIBILITIES.keys()
	var rng = RandomNumberGenerator.new()
	
	vote_options[NUMBER_OF_VOTE_OPTIONS - 1] = current_track_name
	if possibilities.find(current_track_name) != -1:
		possibilities.remove_at(possibilities.find(current_track_name))
	
	for i in range(NUMBER_OF_VOTE_OPTIONS - 1):
		var index = rng.randi_range(0, possibilities.size() - 1)
		var map : String = possibilities[index]
		possibilities.remove_at(index)
		vote_options[i] = map
		if possibilities.is_empty():
			break
	
	print(vote_options)


func end_race():
	print("race is over")
	if multiplayer.is_server():
		time_till_timeout = 0
		vote_timer = VOTE_TIME
		votes = {}
		generate_vote_options()
	racing_finished.rpc(vote_options)


@rpc("authority", "call_local", "reliable")
func racing_finished(_vote_options : Array):
	vote_options = _vote_options.duplicate()
	if get_tree().current_scene is Gameplay:
		get_tree().current_scene.stop_race()


func become_spectator():
	is_a_spectator = true


func become_player():
	is_a_spectator = false


func kick(id):
	print("kicked player ", id)
	multiplayer.multiplayer_peer.disconnect_peer(id)


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	if multiplayer.is_server():
		var game_info = {}
		game_info["track_name"] = current_track_name
		game_info["become_spectator"] = not temp_start_countdown
		send_game_info.rpc_id(id, game_info)
	
	print("player ", id, " connected")


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
	print("registered player ", new_player_id)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	if multiplayer.is_server():
		if players_loaded.find(id) != -1:
			players_loaded.remove_at(players_loaded.find(id))
		votes.erase(id)
	print("player ", id, " disconnected")


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	
	print("succesfuly connected")


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	if not multiplayer.is_server():
		get_tree().change_scene_to_file("res://menu.tscn")
		
	print("didn't connect")


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	
	print("lobby host disconnected")
