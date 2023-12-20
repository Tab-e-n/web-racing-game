extends Node2D


@onready var car : Racecar = null

enum {STATE_SLIDING, STATE_DRIFTING}

var state : int = STATE_SLIDING


func _ready():
	var gameplay = get_tree().current_scene
	if gameplay == null:
		queue_free()
		return
	
	car = gameplay.get_node("Racecar")
	if car == null:
		queue_free()
		return
	
	for i in range(4):
		var wheel = car.get_node("wheel" + String.num(i + 1))
		if wheel == null:
			continue
		
		var line = preload("res://Objects/drift_line_effect.tscn").instantiate()
		line.car = car
		line.wheel = wheel
		line.wheel_num = i + 1
		if state == STATE_SLIDING:
			line.line_lenght = 30
		if state == STATE_DRIFTING:
			line.line_lenght = 15
		
		add_child(line)


func _physics_process(_delta):
	if not (car.state_sliding or car.state_drifting) and get_children()[0].points.size() == 0:
		queue_free()
