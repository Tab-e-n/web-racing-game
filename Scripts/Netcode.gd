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

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {
}
# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"name": "Name",
	"palette" : 0,
	"time" : -1,
}
var players_loaded = []
var is_a_player : bool = true
var is_a_spectator : bool = false

var current_track_name : String = "test_scene"

var rcp_delay : int = 0

var end_of_race_timeout : float = 0
var vote_timer : float = 0

var votes : Array = []
var vote_options : Array = ["test_scene","test_scene","test_scene","test_scene"]


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _physics_process(delta):
	if multiplayer.multiplayer_peer != null:
		if multiplayer.is_server() and get_tree().current_scene is Gameplay:
			# This is here to limit server and peer network load.
			# Mostlikely not neccesary
			rcp_delay += 1
			if rcp_delay >= 3:
				get_car_data.rpc()
				rcp_delay = 0
			
			if end_of_race_timeout > 0:
				end_of_race_timeout -= delta
				if end_of_race_timeout <= 0:
					racing_finished.rpc()
			
			if vote_timer > 0:
				vote_timer -= delta
				if vote_timer <= 0:
					start_new_round()
			
			if players_loaded.size() == players.size():
				players_loaded = []
				start_countdown.rpc()
			
#			print("server")


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)
	call_deferred("start_countdown")


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# The server will call this ever so often to tell every peer
# to send information about where they are, their speed and their rotation.
@rpc("authority", "call_local", "unreliable")
func get_car_data():
	if is_a_spectator or not is_a_player:
		return
	if get_tree().current_scene.has_method("get_car_data"):
		var car_data = get_tree().current_scene.get_car_data()
		send_car_data.rpc(car_data)


@rpc("any_peer", "call_remote", "unreliable")
func send_car_data(car_data : Dictionary):
	var peer_id = multiplayer.get_remote_sender_id()
	if players.has(peer_id):
		players[peer_id]["car_data"] = car_data.duplicate()
#		print("data_recieved")


@rpc("authority", "call_remote", "reliable")
func send_game_info(game_info : Dictionary):
	print("got game info")
	current_track_name = game_info["track_name"]
	become_spectator()


func start_new_round():
	print("new round")
	end_of_race_timeout = 0
	vote_timer = 0
	players_loaded = []
	
	var top_vote = count_votes()
	change_map.rpc(vote_options[top_vote])


@rpc("authority", "call_local", "reliable")
func change_map(track_name : String):
	print("changing map: ", track_name)
	if track_name == current_track_name:
		call_deferred("set", "current_track_name", track_name)
		track_name = ""
	current_track_name = track_name
	send_time.rpc(-1)
	if not multiplayer.is_server():
		map_loaded.rpc_id(1)
	else:
		map_loaded()


@rpc("any_peer", "call_remote", "reliable")
func map_loaded():
	var peer_id = multiplayer.get_remote_sender_id()
	print(peer_id, " loaded the map")
	if not players_loaded.has(peer_id):
		players_loaded.append(peer_id)


@rpc("authority", "call_local", "reliable")
func start_countdown():
	print("starting coundown")
	become_player()
	if get_tree().current_scene is Gameplay:
		get_tree().current_scene.start_race()


@rpc("any_peer", "call_remote", "reliable")
func send_time(time : float):
	print(time)
	var peer_id = multiplayer.get_remote_sender_id()
	if players.has(peer_id):
		players[peer_id]["time"] = time
	if multiplayer.is_server() and time != -1:
		end_of_race_timeout = END_OF_RACE_TIMEOUT
		check_player_times()


func check_player_times():
	for i in players:
		if players[i]["time"] == -1:
			print(players)
			return
	racing_finished()


func _on_race_finished(race_timer):
	print("i finished")
	send_time.rpc(race_timer)
	if multiplayer.is_server():
		print(race_timer)
		if players.has(1):
			players[1]["time"] = race_timer
		end_of_race_timeout = END_OF_RACE_TIMEOUT
		check_player_times()


# This is the function that the ui can call when the player
# chooses the vote option. It can be called multiple times,
# only the most recent vote will count.
func vote_map(vote):
	send_map_vote.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func send_map_vote(vote):
	var peer_id = multiplayer.get_remote_sender_id()
	if vote < 0 or vote > 3:
		return
	votes[peer_id] = vote


func count_votes() -> int:
	var vote_count = []
	for i in range(NUMBER_OF_VOTE_OPTIONS):
		vote_count.append(0)
	
	for i in votes:
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
	return top_vote[rng.randi_range(0, top_vote.size() - 1)]


func generate_vote_options():
	var dir : Array = DirAccess.get_files_at("res://Tracks/")
	var rng = RandomNumberGenerator.new()
	
	vote_options[NUMBER_OF_VOTE_OPTIONS - 1] = current_track_name
	if dir.find(current_track_name) > -1:
		dir.remove_at(dir.find(current_track_name))
	
	for i in range(NUMBER_OF_VOTE_OPTIONS - 1):
		var index = rng.randi_range(0, dir.size() - 1)
		var map : String = dir[index]
		dir.remove_at(index)
		vote_options[i] = map.trim_suffix(".tscn")
		if dir.is_empty():
			break
	
	print(vote_options)
	for child in (get_tree().current_scene as Gameplay).get_children(): #tohle je asi spatne
		if child.name == "camera":
			child.start_vote()


@rpc("authority", "call_local", "reliable")
func racing_finished():
	print("race over")
	(get_tree().current_scene as Gameplay).stop_race()
	if multiplayer.is_server():
		end_of_race_timeout = 0
		vote_timer = VOTE_TIME
		votes = []
		generate_vote_options()


func become_spectator():
	is_a_spectator = true


func become_player():
	is_a_spectator = false


func kick(id):
	multiplayer.multiplayer_peer.disconnect_peer(id)


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	if multiplayer.is_server():
		var game_info = {}
		game_info["track_name"] = current_track_name
		send_game_info.rpc_id(id, game_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
#	print("register")
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
