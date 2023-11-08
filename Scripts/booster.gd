extends Area2D


var car : Node2D


func _physics_process(_delta):
	if car != null:
		car.forced_accel = true


func _on_body_entered(body):
	if car == null:
		car = body
		car.forced_accel = true
		car.boost(250, 5, rotation)


func _on_body_exited(_body):
	car.forced_accel = false
	car = null
