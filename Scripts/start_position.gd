extends Marker2D


func _ready():
	var game = get_tree().current_scene
	if game.has_node("Racecar"):
		var car = game.get_node("Racecar")
		car.position = position
		car.rotation = rotation
		car.reset()
	queue_free()
