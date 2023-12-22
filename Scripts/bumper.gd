extends Area2D

var text_stand : Texture = preload("res://Textures/bumper.png")
var text_active : Texture = preload("res://Textures/bumper_active.png")

var car : Racecar

var boost_cooldown : int = 0


func _ready():
	pass


func _physics_process(_delta):
	if car != null and boost_cooldown == 0:
		boost_cooldown = 10
		
		var distance = car.position - position
		var pyth = car.pythagoras(distance.x, distance.y)
		var cosine = distance.y / pyth
		var direction = car.incos(cosine, distance.x)
		
		$DebugVector.rotation = direction
		
		car.start_sliding()
		
		car.boost(500, 1, direction)
		$sprite.texture = text_active
	
	if boost_cooldown > 0:
		boost_cooldown -= 1
		if boost_cooldown == 0:
			$sprite.texture = text_stand


func _on_body_entered(body):
	if car == null:
		car = body


func _on_body_exited(_body):
	car = null
