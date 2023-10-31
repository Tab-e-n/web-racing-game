extends Node2D

func get_car_data():
	var data = {}
	data["position"] = $Racecar.position
	data["rotation"] = $Racecar.rotation
#	data["gear"] = $Racecar.gear
#	data["cur_speed"] = $Racecar.cur_speed
#	data["state_sliding"] = $Racecar.state_sliding
	return data

func player_did_a_lap():
	print("You did a lap :D")
