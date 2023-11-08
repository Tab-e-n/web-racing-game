extends Area2D


var car : Node2D


func _physics_process(_delta):
	if car != null:
		car.on_asphalt = true


func _on_body_entered(body):
	car = body


func _on_body_exited(_body):
	car.on_asphalt = false
	car = null
