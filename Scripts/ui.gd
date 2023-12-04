extends Control


func _ready():
	Net.reset()


func _on_create_button_pressed():
	if Net.create_game():
		Net.reset()
	else:
		load_game()


func _on_join_button_pressed():
	if Net.join_game($ip_line.text):
		Net.reset()
	else:
		load_game()


func load_game():
	if($name_line.text != ""):
		Net.player_info["name"] = $name_line.text
	else:
		Net.player_info["name"] = "Guest"
	get_tree().change_scene_to_file("res://gameplay.tscn")
	
