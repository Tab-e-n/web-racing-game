extends Line2D


@export var wheel_num : int = 1


@onready var car : Racecar = null
@onready var wheel : Node2D = null


var line_lenght : int = 60
var active : bool = true

func _ready():
	default_color = Palettes.PALETTES[Net.player_info["palette"]][0] * Color(1, 1, 1, 0.5)

func _process(_delta):
	if not car.state_sliding:
		active = false
	
	if active:
		add_point(wheel.global_position)
	
	if points.size() > line_lenght or (not active and points.size() > 0):
		remove_point(0)
