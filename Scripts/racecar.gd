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
const BUNKER_DRAG : float = 4

var is_taking_inputs = true

var cur_speed = 0
var friction_reduction = 0
var gear = 0
var switching_gears_timer = 0

var state_sliding : bool = false
var forced_accel : bool = false
var extra_friction : float = 0
var extra_drag : float = 0

var on_asphalt : bool = false
var on_bunker : bool = false

var oil_covered : bool = false

func _ready():
	motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta):
	if Net.is_a_spectator:
		visible = false
		return
	
	if not on_asphalt:
		on_bunker = true
	else:
		on_bunker = false
#	print(on_asphalt)
#	print(on_bunker)
	
	extra_friction = 0
	extra_drag = 0
	
	if on_bunker:
		extra_drag += BUNKER_DRAG
	
	if oil_covered:
		state_sliding = true
		extra_friction += 1.5
	
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
	
	$last_coll_rot.global_rotation = last_coll_rot
	
	if move_and_slide():
		for i in get_slide_collision_count():
			var coll = get_slide_collision(i)
			var wall_angle = coll.get_normal().angle() + PI/2
			$last_coll_rot.global_rotation = wall_angle
			
			
			var new_angle
			if rotation_distance(wall_angle, flip_angle(rotation)) < PI/6:
				new_angle = flip_angle(wall_angle)
			elif rotation_distance(wall_angle, rotation) < PI/6:
				new_angle = wall_angle
			else:
				new_angle = wall_rotation_change(rotation, wall_angle)
	#		if cur_speed < 0:
	#			new_angle = flip_angle(new_angle)
			$new_rot.global_rotation = new_angle
			
			var angle_dist = rotation_distance(new_angle, rotation)
			var angle_sign = rotation_sign(rotation, new_angle)
			rotation += angle_dist * angle_sign * 0.05
	#		print(rotation_apply_percent)
	#		print($last_coll_rot.global_rotation)
		
		velocity = get_real_velocity()
		if pythagoras(velocity.x, velocity.y) < cur_speed:
			cur_speed = pythagoras(velocity.x, velocity.y)
		cur_speed -= FRICTION * sign(cur_speed)
	
	$Label.text = String.num(gear) + "\n" + String.num(round(cur_speed))
	
	if state_sliding or oil_covered:
		$placeholder.modulate = Color(0.5, 0.5, 0.5)
	else:
		$placeholder.modulate = Color(1, 1, 1)
		
	
	$normal_rot.visible = Global.debug_mode
	$last_coll_rot.visible = Global.debug_mode
	$sliding_rot_cos.visible = Global.debug_mode and state_sliding and not velocity == Vector2(0, 0)
	$new_rot.visible = Global.debug_mode

func physics_normal():
#	var turn_direction : int = 0
#	if Input.is_action_pressed("left"):
#		turn_direction = --1
#	if Input.is_action_pressed("right"):
#		turn_direction = 1
#
	if Input.is_action_pressed("left") and is_taking_inputs:
		rotation -= TURN_SPEED
	if Input.is_action_pressed("right") and is_taking_inputs:
		rotation += TURN_SPEED
	
	if switching_gears_timer == 0:
		if (Input.is_action_pressed("up") and is_taking_inputs) or forced_accel:
			if cur_speed < TOP_SPEED:
				cur_speed += ACCELERATION - GEAR_ACC_DECREASE[gear]
				if cur_speed > TOP_SPEED:
					cur_speed = TOP_SPEED
			if friction_reduction < FRICTION:
				friction_reduction += 1
		
		if Input.is_action_pressed("down") and is_taking_inputs:
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
	
	if ((!(Input.is_action_pressed("up") or forced_accel) and !Input.is_action_pressed("down")) or !is_taking_inputs) and friction_reduction > 0:
		friction_reduction -= 1
	
	if cur_speed != 0:
		var speed_sign = sign(cur_speed)
		cur_speed -= speed_sign * (FRICTION - friction_reduction + abs(cur_speed) / 1000 * extra_drag + extra_friction)
		if speed_sign != sign(cur_speed):
			cur_speed = 0
	
#		velocity.x += sin(rotation) * ACCELERATION
#		velocity.y -= cos(rotation) * ACCELERATION
	
	velocity.x = sin(rotation) * cur_speed
	velocity.y = -cos(rotation) * cur_speed

func physics_sliding():
	
	if Input.is_action_pressed("left") and is_taking_inputs:
		rotation -= TURN_SPEED_SLIDING
	if Input.is_action_pressed("right") and is_taking_inputs:
		rotation += TURN_SPEED_SLIDING
	
	var pyth = pythagoras(velocity.x, velocity.y)
	var velocity_sin = null
	var velocity_cos = null
	if pyth > 0:
		velocity_sin = (velocity.x / pyth)
		velocity_cos = (velocity.y / pyth)
	
	if switching_gears_timer == 0:
		if (Input.is_action_pressed("up") and is_taking_inputs) or forced_accel:
			velocity.x += sin(rotation) * ACCELERATION
			velocity.y -= cos(rotation) * ACCELERATION
		
		if Input.is_action_pressed("down") and is_taking_inputs and pyth > 10:
			velocity.x -= velocity_sin * DECCELERATION
			velocity.y -= velocity_cos * DECCELERATION
	
	
	if (!Input.is_action_pressed("up") and !Input.is_action_pressed("down")) or !is_taking_inputs:
		if friction_reduction > 0:
			friction_reduction -= 1
	
	if velocity_sin != null or velocity_cos != null:
		if velocity.x != 0:
			var speed_sign = sign(velocity.x)
			velocity.x -= velocity_sin * (FRICTION / 3 + pyth / 1000 * (SLIDING_DRAG + extra_drag) + extra_friction)
			if speed_sign != sign(velocity.x) and speed_sign != 0:
				velocity.x = 0
		
		if velocity.y != 0:
			var speed_sign = sign(velocity.y)
			velocity.y -= velocity_cos * (FRICTION / 3 + pyth / 1000 * (SLIDING_DRAG + extra_drag) + extra_friction)
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
	
	cur_speed = pyth
	
#	velocity.x = sin(rotation) * cur_speed
#	velocity.y = -cos(rotation) * cur_speed


func boost(magnitude : float, drag : float, direction : float):
	if state_sliding:
		var pyth = pythagoras(velocity.x, velocity.y)
		velocity.x += sin(direction) * magnitude / (1 + pyth / 1000 * drag)
		velocity.y += -cos(direction) * magnitude / (1 + pyth / 1000 * drag)
	else:
		cur_speed += (PI - rotation_distance(direction, rotation)) / PI * magnitude / (1 + abs(cur_speed) / 1000 * drag)


func wall_rotation_change(curr_rot : float, wall_rot : float):
	var bang_angle = flip_angle(curr_rot)
	bang_angle = mirror_angle(bang_angle, wall_rot)
	return bang_angle

func rotation_distance(r1, r2):
	var dist = abs(r1 - r2)
	r1 -= PI
	while r1 < 0:
		r1 += 2*PI
	r2 -= PI
	while r2 < 0:
		r2 += 2*PI
	if abs(r1 - r2) < dist:
		dist = abs(r1 - r2)
	return dist

func rotation_sign(r1, r2):
#	print("s: ", r1, " ", r2)
	while r1 < 0:
		r1 += 2*PI
	while r2 < 0:
		r2 += 2*PI
	while r1 > 2*PI:
		r1 -= 2*PI
	while r2 > 2*PI:
		r2 -= 2*PI
	var dist = abs(r1 - r2)
	var sign = sign(r2 - r1)
#	print("b: ", sign, " ", dist, " ", r1, " ", r2)
	r1 -= PI
	while r1 < 0:
		r1 += 2*PI
	r2 -= PI
	while r2 < 0:
		r2 += 2*PI
	if abs(r1 - r2) < dist:
		dist = abs(r1 - r2)
		sign = sign(r2 - r1)
#	print("a: ", sign, " ", dist, " ", r1, " ", r2)
	return sign
	

func flip_angle(angle : float):
	if angle > PI:
		angle -= PI
	else:
		angle += PI
	return angle

func mirror_angle(angle : float, mirror : float):
	var out = angle - mirror
	out = 2*PI - out
	out += mirror
	return out

func incos(n : float, velx : float):
	var angle = acos(n)
	if velx > 0:
		angle = PI - angle
	if velx < 0:
		angle += PI
	return angle

func pythagoras(a, b):
	return sqrt(a * a + b * b)
