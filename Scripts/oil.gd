extends Area2D

var car : Node2D
var oil_covered_timer : int

func _physics_process(_delta):
	if car != null:
		car.oil_covered = true
	if oil_covered_timer > 0:
		oil_covered_timer -= 1
		if oil_covered_timer == 0:
			car.oil_covered = false
			car = null


func _on_body_entered(body):
	oil_covered_timer = 0
	car = body


func _on_body_exited(_body):
	oil_covered_timer = 45
