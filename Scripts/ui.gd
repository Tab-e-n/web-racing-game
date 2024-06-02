class_name Menu
extends Control


var palette_expanded : bool = false


@onready var palette_expanded_node : Control = $main/palette_expanded
@onready var palette_small_node : Control = $main/palette_small

@onready var ip_input : LineEdit = $main/ip_line
@onready var name_input : LineEdit = $main/name_line


func _ready():
	$main.visible = true
	$controls.visible = false
	Net.reset()


func _physics_process(_delta):
	palette_expanded_node.visible = palette_expanded
	palette_small_node.visible = not palette_expanded


func _on_create_button_pressed():
	if Net.create_game():
		Net.reset()
	else:
		load_game()


func _on_join_button_pressed():
	if Net.join_game(ip_input.text):
		Net.reset()
	else:
		load_game()


func load_game():
	if(name_input.text != ""):
		Net.player_info["name"] = name_input.text
	else:
		Net.player_info["name"] = "Guest"
	get_tree().change_scene_to_file("res://gameplay.tscn")


func _on_car_button_pressed():
	palette_expanded = not palette_expanded
	palette_expanded_node.update()
	palette_small_node.update()


func _on_controls_pressed():
	$main.visible = not $main.visible
	$controls.visible = not $controls.visible
