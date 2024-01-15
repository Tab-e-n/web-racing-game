extends Area2D

const TEXT_STAND : Texture = preload("res://Textures/bumper.png")
const TEXT_ACTIVE : Texture = preload("res://Textures/bumper_active.png")

var car : Racecar

var boost_cooldown : int = 0


func _ready():
	pass


func _physics_process(_delta):
	$DebugVector.visible = Global.debug_mode
	
	if car != null and boost_cooldown == 0:
		boost_cooldown = 10
		
		var direction = Global.face_point(global_position, car.position)
		
		$DebugVector.rotation = direction
		
		car.start_sliding()
		
		car.boost(500 * global_scale.x, 1, direction, false)
		$sprite.texture = TEXT_ACTIVE
	
	if boost_cooldown > 0:
		boost_cooldown -= 1
		if boost_cooldown == 0:
			$sprite.texture = TEXT_STAND


func _on_body_entered(body):
	if car == null:
		car = body


func _on_body_exited(_body):
	car = null
