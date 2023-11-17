class_name Gameplay
extends Node2D


signal lap_finished(lap)
signal race_started()
signal race_finished(final_time)
signal wrong_way()


var countdown_has_started : bool = true
var countdown : float = 3
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
	countdown_has_started = true


func player_did_a_lap():
	print("You did a lap :D")
	current_lap += 1
	if current_lap != lap_count:
		lap_finished.emit(current_lap)
	else:
		race_finished.emit(race_timer)
