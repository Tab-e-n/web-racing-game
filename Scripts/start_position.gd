extends Marker2D


@export_enum("Normal", "Snow") var bunker_type : int = Racecar.BUNKER_TYPE_NORMAL


func _ready():
	var game = get_tree().current_scene
	if game.has_node("Racecar"):
		var car = game.get_node("Racecar")
		car.position = position
		car.rotation = rotation
		car.bunker_type = bunker_type
		car.reset()
	queue_free()
