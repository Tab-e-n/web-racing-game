extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}
# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {
	"name": "Name",
	"palette" : 0,
}
var players_loaded = 0
var is_a_player : bool = true
var is_a_spectator : bool = false

var current_track_name : String = ""

var rcp_delay : int = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _physics_process(delta):
	if multiplayer.multiplayer_peer != null:
		if multiplayer.is_server():
			rcp_delay += 1
			if rcp_delay >= 3:
				get_car_data.rpc()
				rcp_delay = 0
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


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
#@rpc("call_local", "reliable")
#func load_game(game_scene_path):
#	get_tree().change_scene_to_file(game_scene_path)

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

@rpc("authority", "call_local", "reliable")
func send_game_info(game_info : Dictionary):
	current_track_name = game_info["track_name"]

# Every peer will call this when they have loaded the game scene.
#@rpc("any_peer", "call_local", "reliable")
#func player_loaded():
#	if multiplayer.is_server():
#		players_loaded += 1
#		if players_loaded == players.size():
#			$/root/Game.start_game()
#			players_loaded = 0


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
