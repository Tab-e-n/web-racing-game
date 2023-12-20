class_name Menu
extends Control


var palette_expanded : bool = false


func _ready():
	Net.reset()


func _physics_process(_delta):
	$palette_expanded.visible = $car_button.button_pressed
	$palette_small.visible = not $car_button.button_pressed


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


func _on_car_button_toggled(_button_pressed):
	$palette_expanded.update()
	$palette_small.update()
