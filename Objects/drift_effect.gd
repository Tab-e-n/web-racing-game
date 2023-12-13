extends Node2D


@onready var car : Racecar = null
@onready var wheel : Node2D = null

enum {STATE_SLIDING, STATE_SLIPPING}

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
		wheel = car.get_node("wheel" + String.num(i + 1))
		var line = get_node("driftline" + String.num(i + 1))
		if wheel == null:
			line.queue_free()
			continue
		line.car = car
		line.wheel = wheel
		line.wheel_num = i + 1
		if state == STATE_SLIDING:
			line.line_lenght = 60
		if state == STATE_SLIPPING:
			line.line_lenght = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not car.state_sliding and get_children()[0].points.size() == 0:
		queue_free()
