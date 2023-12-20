extends Area2D


var car : Node2D

var car_touched_timer : int = 0
var anim_timer : int = 0

func _physics_process(delta):
	if car != null:
		car.forced_accel = true
		car_touched_timer = 40
	
	anim_timer += 1
	if anim_timer > 30 or (anim_timer > 3 and car_touched_timer > 0):
		anim_timer = 0
		if $Booster.frame == 4:
			$Booster.frame = 0
		else:
			$Booster.frame += 1
	if car_touched_timer > 0:
		car_touched_timer -= 1
		


func _on_body_entered(body):
	if car == null:
		car = body
		car.forced_accel = true
		car.boost(250, 5, rotation)


func _on_body_exited(_body):
	car.forced_accel = false
	car = null
