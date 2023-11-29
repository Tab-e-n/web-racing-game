extends Area2D


var car : Node2D


func _physics_process(_delta):
	if car != null:
		car.on_road = true


func _on_body_entered(body):
	if body is Racecar:
		car = body


func _on_body_exited(_body):
	car.on_road = false
	car = null
