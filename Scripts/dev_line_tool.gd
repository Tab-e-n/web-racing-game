@tool
extends Line2D

class_name dev_line_tool

@export var reload : bool = false
@export_category("Car Simulation")
@export var enable_car_simulation_turn : bool = false
@export var car_simulation_curr_speed : float = 690
@export var car_simulation_turn_speed : float = 0.03
@export var car_simulation_end_rotation : float = PI/2

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
	else:
		var dot : Sprite2D = Sprite2D.new()
		dot.texture = preload("res://Textures/debug_point.png")
		add_child(dot)
		modulate = Color(1, 0, 1, 0.5)
		width = 2

func _physics_process(delta):
	if enable_car_simulation_turn:
		if reload:
			clear_points()
			var repetitions : int = 0
			var current_rot = 0
			var point = Vector2(0, 0)
			add_point(point)
			while abs(current_rot) < car_simulation_end_rotation:
				point.x += sin(current_rot) * car_simulation_curr_speed * delta
				point.y += -cos(current_rot) * car_simulation_curr_speed * delta
				add_point(point)
				current_rot += car_simulation_turn_speed
				repetitions += 1
				if repetitions >= 1024:
					break
	
	reload = false

