extends CharacterBody2D

const DEBUG_NO_EXIT_SLIDING = false

const TURN_SPEED : float = 0.03
const ACCELERATION : float = 4
const DECCELERATION : float = 6
const FRICTION : float = 6
const TOP_SPEED : float = 690
const TOP_SPEED_BACK : float = 200
const GEAR_THRESHOLDS = [150, 275, 400, 500]
const GEAR_ACC_DECREASE = [0, 1.6, 2.1, 2.4, 2.7]
const TURN_SPEED_SLIDING : float = 0.05
const SLIDING_DRAG : float = 1.5

var gear = 0
var cur_speed = 0
var friction_reduction = 0

var switching_gears_timer = 0

var state_sliding = false

func _ready():
	motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta):
	
	if switching_gears_timer > 0:
		switching_gears_timer -= 1
		if switching_gears_timer == 0:
			gear = 0
			for i in GEAR_THRESHOLDS:
				if cur_speed > i:
					gear += 1
	
	var last_coll_rot = $last_coll_rot.global_rotation
	
	if state_sliding:
		physics_sliding()
	else:
		physics_normal()
	move_and_slide()
	
	$last_coll_rot.global_rotation = last_coll_rot
	
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		$last_coll_rot.global_rotation = coll.get_normal().angle() + PI/2
#		print($last_coll_rot.global_rotation)
	
	$Label.text = String.num(gear) + "\n" + String.num(round(cur_speed))
	
	if state_sliding:
		$placeholder.modulate = Color(0.5, 0.5, 0.5)
	else:
		$placeholder.modulate = Color(1, 1, 1)
		
	
	$normal_rot.visible = Global.debug_mode
	$last_coll_rot.visible = Global.debug_mode
	$sliding_rot_cos.visible = Global.debug_mode and state_sliding and not velocity == Vector2(0, 0)

func physics_normal():
	
	if Input.is_action_pressed("left"):
		rotation -= TURN_SPEED
	if Input.is_action_pressed("right"):
		rotation += TURN_SPEED
	
	if switching_gears_timer == 0:
		if Input.is_action_pressed("up"):
			if cur_speed < TOP_SPEED:
				cur_speed += ACCELERATION - GEAR_ACC_DECREASE[gear]
				if cur_speed > TOP_SPEED:
					cur_speed = TOP_SPEED
			if friction_reduction < FRICTION:
				friction_reduction += 1
		
		if Input.is_action_pressed("down"):
			if cur_speed > -TOP_SPEED_BACK:
				cur_speed -= DECCELERATION
				if cur_speed < -TOP_SPEED_BACK:
					cur_speed = -TOP_SPEED_BACK
			if friction_reduction < FRICTION:
				friction_reduction += 1
			if gear > 0:
				state_sliding = true
		
	
	if switching_gears_timer == 0:
		var expected_gear = 0
		for i in GEAR_THRESHOLDS:
			if cur_speed > i:
				expected_gear += 1
		if expected_gear != gear:
			gear = expected_gear
			switching_gears_timer = 30
	
	if !Input.is_action_pressed("up") and !Input.is_action_pressed("down") and friction_reduction > 0:
		friction_reduction -= 1
	
	if cur_speed != 0:
		var speed_sign = sign(cur_speed)
		cur_speed -= speed_sign * (FRICTION - friction_reduction)
		if speed_sign != sign(cur_speed):
			cur_speed = 0
	
#		velocity.x += sin(rotation) * ACCELERATION
#		velocity.y -= cos(rotation) * ACCELERATION
	
	velocity.x = sin(rotation) * cur_speed
	velocity.y = -cos(rotation) * cur_speed

func physics_sliding():
	
	if Input.is_action_pressed("left"):
		rotation -= TURN_SPEED_SLIDING
	if Input.is_action_pressed("right"):
		rotation += TURN_SPEED_SLIDING
	
	var pythagoras = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
	var velocity_sin = null
	var velocity_cos = null
	if pythagoras > 0:
		velocity_sin = (velocity.x / pythagoras)
		velocity_cos = (velocity.y / pythagoras)
	
	if switching_gears_timer == 0:
		if Input.is_action_pressed("up"):
			velocity.x += sin(rotation) * ACCELERATION
			velocity.y -= cos(rotation) * ACCELERATION
		
		if Input.is_action_pressed("down") and pythagoras > 10:
			velocity.x -= velocity_sin * DECCELERATION
			velocity.y -= velocity_cos * DECCELERATION
	
	
	if !Input.is_action_pressed("up") and !Input.is_action_pressed("down"):
		if friction_reduction > 0:
			friction_reduction -= 1
	
	if velocity_sin != null or velocity_cos != null:
		if velocity.x != 0:
			var speed_sign = sign(velocity.x)
			velocity.x -= velocity_sin * (FRICTION / 3 + pythagoras / 1000 * SLIDING_DRAG)
			if speed_sign != sign(velocity.x) and speed_sign != 0:
				velocity.x = 0
		
		if velocity.y != 0:
			var speed_sign = sign(velocity.y)
			velocity.y -= velocity_cos * (FRICTION / 3 + pythagoras / 1000 * SLIDING_DRAG)
			if speed_sign != sign(velocity.y) and speed_sign != 0:
				velocity.y = 0
		
		if Global.debug_mode:
			$sliding_rot_cos.global_rotation = incos(velocity_cos, velocity.x)
		
		if not DEBUG_NO_EXIT_SLIDING:
			if rotation_distance(incos(velocity_cos, velocity.x), rotation) < 0.1 and !Input.is_action_pressed("down"):
				state_sliding = false
	
	if not DEBUG_NO_EXIT_SLIDING:
		if abs(velocity.x) < 25 and abs(velocity.y) < 25:
			state_sliding = false
	
	cur_speed = pythagoras
	
#	velocity.x = sin(rotation) * cur_speed
#	velocity.y = -cos(rotation) * cur_speed

func rotation_distance(r1, r2):
	var dist = abs(r1 - r2)
	r1 -= PI
	if r1 < 0:
		r1 += 2*PI
	r2 -= PI
	if r2 < 0:
		r2 += 2*PI
	if abs(r1 - r2) < dist:
		dist = abs(r1 - r2)
	return dist

func flip_angle(angle : float):
	if angle > PI:
		angle -= PI
	else:
		angle += PI
	return angle

func incos(n : float, velx : float):
	var angle = acos(n)
	if velx > 0:
		angle = PI - angle
	if velx < 0:
		angle += PI
	return angle
