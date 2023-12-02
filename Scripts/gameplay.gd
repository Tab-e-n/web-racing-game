class_name Gameplay
extends Node2D


signal lap_finished(lap)
signal race_started()
signal race_finished(final_time)
signal wrong_way()


const COUNTDOWN : float = 3

var is_racing : bool = false

var countdown_has_started : bool = false
var countdown : float = COUNTDOWN
var timer_has_started : bool = false
var race_timer : float = 0 

var lap_count : int = 3
var current_lap : int = 0


func _ready():
	Net.gameplay_active = true
	Net.server_disconnected.connect(_on_server_disconnect)


func _physics_process(delta):
	if countdown_has_started and countdown > 0:
		countdown -= delta
		if countdown <= 0:
			timer_has_started = true
			race_started.emit()
	if timer_has_started:
		race_timer += delta


func get_car_data():
	var data = {}
	data["position"] = $Racecar.position
	data["rotation"] = $Racecar.rotation
	data["sliding"] = $Racecar.state_sliding
#	data["gear"] = $Racecar.gear
#	data["cur_speed"] = $Racecar.cur_speed
	return data


func start_race():
	race_timer = 0
	current_lap = 0
	is_racing = true
	countdown_has_started = true
	countdown = COUNTDOWN
	timer_has_started = false


func stop_race():
	is_racing = false
	timer_has_started = false
	$Racecar.is_taking_inputs = false
	$camera.start_vote() # premistil jsem ti funkci ha ha ha
	# Tam kde si to dal predtim to sice fungovalo, ale bylo to moc zamotane


func player_did_a_lap():
	if not is_racing:
		return
	print("you did a lap :D")
	current_lap += 1
	if current_lap != lap_count:
		lap_finished.emit(current_lap)
		Net._on_lap_finished(race_timer, current_lap)
	else:
		race_finished.emit(race_timer)
		Net._on_race_finished(race_timer)


func _on_server_disconnect():
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_new_track_loaded(_track):
	countdown_has_started = false
