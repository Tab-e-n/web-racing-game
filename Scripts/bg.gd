extends Sprite2D

var car : Racecar = null

var last_bunker_type : int = -1;

# Called when the node enters the scene tree for the first time.
func _ready():
	var game = get_tree().current_scene
	if game.has_node("Racecar"):
		car = game.get_node("Racecar")

func _physics_process(_delta):
	if car == null:
		return
	if car.bunker_type != last_bunker_type:
		last_bunker_type = car.bunker_type
		if car.bunker_type < Palettes.BG_COLORS.size() and car.bunker_type >= 0:
			material.set_shader_parameter("coloring", Palettes.BG_COLORS[car.bunker_type])
		
