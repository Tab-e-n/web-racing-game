extends Node2D

func get_car_data():
	var data = {}
	data["position"] = $Racecar.position
	data["rotation"] = $Racecar.rotation
	data["sliding"] = $Racecar.state_sliding
#	data["gear"] = $Racecar.gear
#	data["cur_speed"] = $Racecar.cur_speed
	return data

func player_did_a_lap():
	print("You did a lap :D")
