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
	is_racing = true
	countdown_has_started = true
	countdown = COUNTDOWN
	timer_has_started = false


func stop_race():
	is_racing = false
	countdown_has_started = false
	timer_has_started = false
	$Racecar.is_taking_inputs = false


func player_did_a_lap():
	if not is_racing:
		return
	print("You did a lap :D")
	current_lap += 1
	if current_lap != lap_count:
		lap_finished.emit(current_lap)
	else:
		race_finished.emit(race_timer)
		Net._on_race_finished(race_timer)
