extends Control



func _ready():
	pass


func _process(delta):
	pass


func _on_create_button_pressed():
	load_game()
	Net.create_game()


func _on_join_button_pressed():
	load_game()
	Net.join_game($ip_line.text)


func load_game():
	Net.player_info["name"] = $name_line.text
	get_tree().change_scene_to_file("res://gameplay.tscn")
	
