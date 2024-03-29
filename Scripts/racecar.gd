class_name Racecar
extends CharacterBody2D


signal gear_shifting(new_gear, old_gear)


const DEBUG_NO_EXIT_SLIDING = false

const TURN_SPEED : float = 0.03
const ACCELERATION : float = 4
const DECCELERATION : float = 6
const FRICTION : float = 6
const TOP_SPEED : float = 690
const TOP_SPEED_BACK : float = 200
const GEAR_THRESHOLDS = [150, 275, 400, 500]
const GEAR_ACC_DECREASE = [0, 1.6, 2.1, 2.4, 2.7]
const GEAR_SWITCH_FRAMES : int = 30
const BUNKER_DRAG : float = 4

const TURN_SPEED_SLIDING : float = 0.04
const SLIDING_DRAG : float = 1.2
const MAX_ICESLIDE_TURN_SPEED : float = 0.0125

const TURN_SPEED_DRIFTING : float = 0.04
const DRIFTING_SLIP_ANGLE : float = 60
const DRIFTING_SLIP_INCREASE : float = 30
const DRIFTING_MIN_SLIP_ANGLE : float = 15
const DRIFTING_TURN_REDUCTION : float = 150


var is_taking_inputs = true

var curr_speed = 0
var friction_reduction : float = 0
var gear = 0
var switching_gears_timer = 0
var drifting_real_direction : float = 0

var state_sliding : bool = false
var state_drifting : bool = false

var forced_accel : bool = false
var forced_brake : bool = false
var extra_friction : float = 0
var extra_drag : float = 0
var extra_accel : float = 0
var extra_slip_angle : float = 0
var extra_turn_reduction : float = 0

var on_road : bool = false
var on_ice : bool = false
var on_dirt : bool = false
var on_bunker : bool = false

var oil_covered : bool = false
var iceslide : bool = false

enum {BUNKER_TYPE_NORMAL, BUNKER_TYPE_SNOW, BUNKER_TYPE_DIRT, BUNKER_TYPE_ROCK}
var bunker_type = BUNKER_TYPE_NORMAL

var input_left : bool = false
var input_right : bool = false
var input_up : bool = false
var input_down : bool = false



func _ready():
	(get_parent() as Gameplay).race_finished.connect(_on_race_finished)
	(get_parent() as Gameplay).race_started.connect(_on_race_started)
	if not get_parent() is Gameplay:
		_on_race_started()
	motion_mode = MOTION_MODE_FLOATING
	
	$car.texture = Palettes.CAR_MODELS[Net.player_info["car_model"]]
	$car.material.set_shader_parameter("palette", Palettes.PALETTES[Net.player_info["palette"]])


func reset():
	is_taking_inputs = false
	
	curr_speed = 0
	friction_reduction = 0
	gear = 0
	switching_gears_timer = 0
	
	state_sliding = false
	forced_accel = false
	forced_brake = false
	
	on_road = false
	on_ice = false
	on_dirt = false
	
	oil_covered = false


func _physics_process(_delta):
#	print(position)
	
	if Net.is_a_spectator:
		visible = false
		return
	else:
		visible = true
	
	input_right = Input.is_action_pressed("right") and not Input.is_action_pressed("left") and is_taking_inputs
	input_left = Input.is_action_pressed("left") and not Input.is_action_pressed("right") and is_taking_inputs
	input_down = (Input.is_action_pressed("down") or Input.is_action_pressed("shift")) and is_taking_inputs
	input_up = Input.is_action_pressed("up") and not input_down and is_taking_inputs
	
	var last_bunker = on_bunker
	on_bunker = not on_road
	
	if bunker_type == BUNKER_TYPE_ROCK:
		on_bunker = false
	if on_bunker:
		if bunker_type == BUNKER_TYPE_SNOW:
			on_ice = true
		if bunker_type == BUNKER_TYPE_DIRT:
			on_dirt = true
	if on_bunker != last_bunker and not on_bunker:
		if bunker_type == BUNKER_TYPE_SNOW:
			on_ice = false
		if bunker_type == BUNKER_TYPE_DIRT:
			on_dirt = false
#	print(on_road)
#	print(on_bunker)
	
	extra_friction = 0
	extra_drag = 0
	extra_accel = 0
	extra_slip_angle = 0
	extra_turn_reduction = 0
	
	if on_ice:
		start_sliding()
		extra_friction -= FRICTION * 0.9
		extra_accel -= ACCELERATION * 0.65
#		extra_drag += SLIDING_DRAG / 4
		if input_left or input_right:
			extra_accel += ACCELERATION * 0.1
	
	if on_dirt:
		start_drifting()
		extra_slip_angle = DRIFTING_SLIP_ANGLE / 4
		extra_turn_reduction = DRIFTING_TURN_REDUCTION / 5
	
	if on_bunker:
		extra_drag += BUNKER_DRAG
	
	if oil_covered:
		start_sliding()
		extra_friction += FRICTION * 0.75
	
	if switching_gears_timer > 0:
		if input_left or input_right:
			switching_gears_timer -= 1
		else:
			switching_gears_timer -= 2
#		switching_gears_timer -= 1
		
		if switching_gears_timer <= 0:
			switching_gears_timer = 0
			gear = 0
			for i in GEAR_THRESHOLDS:
				if curr_speed > i:
					gear += 1
	
	var last_coll_rot = $last_coll_rot.global_rotation
	
	if state_sliding:
		physics_sliding()
	elif state_drifting:
		physics_drifting()
	else:
		physics_normal()
	
	if switching_gears_timer == 0:
		var expected_gear = 0
		for i in GEAR_THRESHOLDS:
			if curr_speed > i:
				expected_gear += 1
		if expected_gear != gear:
			gear_shifting.emit(expected_gear, gear)
			switching_gears_timer = GEAR_SWITCH_FRAMES * 2
	
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
			
			$new_rot.global_rotation = new_angle
			
			var angle_dist = rotation_distance(new_angle, rotation)
			var angle_sign = rotation_sign(rotation, new_angle)
			rotation += angle_dist * angle_sign * 0.05
			drifting_real_direction = rotation
	#		print(rotation_apply_percent)
	#		print($last_coll_rot.global_rotation)
		
		velocity = get_real_velocity()
		if Global.pythagoras(velocity.x, velocity.y) < curr_speed:
			curr_speed = Global.pythagoras(velocity.x, velocity.y)
		curr_speed -= FRICTION * sign(curr_speed)
	
	if oil_covered or state_sliding: 
		$car.material.set_shader_parameter("dim", Vector3(0.5, 0.5, 0.5))
	elif state_drifting:
		$car.material.set_shader_parameter("dim", Vector3(0.75, 0.75, 0.75))
	else:
		$car.material.set_shader_parameter("dim", Vector3(1, 1, 1))
	
	$normal_rot.visible = Global.debug_mode
	$last_coll_rot.visible = Global.debug_mode
	$drifting_rot.visible = Global.debug_mode and state_drifting and not velocity == Vector2(0, 0)
	$sliding_rot_cos.visible = Global.debug_mode and state_sliding and not velocity == Vector2(0, 0)
	$new_rot.visible = Global.debug_mode


func physics_normal():
	if input_left:
		rotation -= TURN_SPEED
	if input_right:
		rotation += TURN_SPEED
	
	if switching_gears_timer == 0:
		if input_up or forced_accel:
			curr_speed = normal_change_speed(curr_speed, TOP_SPEED, ACCELERATION - GEAR_ACC_DECREASE[gear] + extra_accel)
			if friction_reduction < FRICTION + extra_friction:
				friction_reduction += 1
		
	if input_down or (forced_brake and curr_speed > 10):
		curr_speed = normal_change_speed(curr_speed, -TOP_SPEED_BACK, -DECCELERATION)
		if friction_reduction < FRICTION + extra_friction:
			friction_reduction += 1
		if gear > 0 and curr_speed > 0:
			start_drifting()
	
	if ((not input_up and not input_down) or not is_taking_inputs) and friction_reduction > 0:
		friction_reduction -= 1
	
	if friction_reduction > FRICTION + extra_friction:
		friction_reduction = FRICTION + extra_friction
	
	curr_speed = apply_reductive_forces(curr_speed, sign(curr_speed), FRICTION + extra_friction - friction_reduction , abs(curr_speed), extra_drag)
	
	velocity.x = sin(rotation) * curr_speed
	velocity.y = -cos(rotation) * curr_speed


func normal_change_speed(speed : float, top_speed : float, acceleration : float):
	if top_speed > 0:
		if speed < top_speed:
			speed += acceleration
			if speed > top_speed:
				speed = top_speed
	if top_speed < 0:
		if speed > top_speed:
			speed += acceleration
			if speed < top_speed:
				speed = top_speed
	return speed


func start_drifting():
	if state_sliding:
		return
	if not state_drifting:
		drifting_real_direction = rotation
		var effect_packed : PackedScene = preload("res://Objects/drifting_effect.tscn")
		var effect = effect_packed.instantiate()
		effect.state = effect.STATE_DRIFTING
		add_sibling(effect)
	state_drifting = true

func physics_drifting():
	if input_left:
		rotation -= TURN_SPEED_DRIFTING
	if input_right:
		rotation += TURN_SPEED_DRIFTING
	
	var rot_sign_before = rotation_sign(drifting_real_direction, rotation)
	drifting_real_direction += rotation_sign(drifting_real_direction, rotation) * TURN_SPEED_DRIFTING * clamp((DRIFTING_TURN_REDUCTION + extra_turn_reduction) / max(abs(curr_speed), 1), 0, 1)
	# * (3.14 / rotation_distance(rotation, drifting_real_direction))
	if rot_sign_before != rotation_sign(drifting_real_direction, rotation):
		drifting_real_direction = rotation
	
	if Global.debug_mode:
		$drifting_rot.global_rotation = drifting_real_direction
	
	if switching_gears_timer == 0:
		if input_up or forced_accel:
			curr_speed = normal_change_speed(curr_speed, TOP_SPEED, (ACCELERATION - GEAR_ACC_DECREASE[gear] + extra_accel) * cos(rotation - drifting_real_direction))
			if friction_reduction < FRICTION + extra_friction:
				friction_reduction += 1
		
	if input_down or (forced_brake and curr_speed > 10):
		curr_speed = normal_change_speed(curr_speed, -TOP_SPEED_BACK, -DECCELERATION)
		if friction_reduction < FRICTION + extra_friction:
			friction_reduction += 1
	
	if ((not input_up and not input_down) or not is_taking_inputs) and friction_reduction > 0:
		friction_reduction -= 1
	
	if friction_reduction > FRICTION + extra_friction:
		friction_reduction = FRICTION + extra_friction
	
	var rot_dist = rotation_distance(drifting_real_direction, rotation)
	
	if not (DEBUG_NO_EXIT_SLIDING or on_dirt):
		if (rot_dist < PI * 0.035 and not input_down and not forced_brake):
			state_drifting = false
	
	if not DEBUG_NO_EXIT_SLIDING:
		var slip_angle = DRIFTING_SLIP_ANGLE - DRIFTING_SLIP_INCREASE * (curr_speed / 1000) + extra_slip_angle
		if slip_angle < DRIFTING_MIN_SLIP_ANGLE:
			slip_angle = DRIFTING_MIN_SLIP_ANGLE
		if (rot_dist / PI) * 180 > slip_angle:
			state_drifting = false
			start_sliding()
		
		if abs(velocity.x) < 25 and abs(velocity.y) < 25:
			state_drifting = false
	
	curr_speed = apply_reductive_forces(curr_speed, sign(curr_speed), FRICTION + extra_friction - friction_reduction , abs(curr_speed), extra_drag)
	
	velocity.x = sin(drifting_real_direction) * curr_speed
	velocity.y = -cos(drifting_real_direction) * curr_speed


func start_sliding():
	if not state_sliding:
		var effect_packed : PackedScene = preload("res://Objects/drifting_effect.tscn")
		var effect = effect_packed.instantiate()
		effect.state = effect.STATE_SLIDING
		add_sibling(effect)
		iceslide = false
	state_sliding = true
	state_drifting = false


func physics_sliding():
	if input_left:
		rotation -= TURN_SPEED_SLIDING
	if input_right:
		rotation += TURN_SPEED_SLIDING
	
	var pyth = Global.pythagoras(velocity.x, velocity.y)
	var velocity_sin = null
	var velocity_cos = null
	if pyth > 0:
		velocity_sin = (velocity.x / pyth)
		velocity_cos = (velocity.y / pyth)
	
	if (input_down or input_up) and on_ice and pyth >= GEAR_THRESHOLDS[0]:
		iceslide = true
	
	if iceslide:
		var rot_dist = rotation_distance(rotation, Global.incos(velocity_cos, velocity.x))
		if rot_dist < PI*0.5 + TURN_SPEED_SLIDING * 6 and rot_dist > PI*0.5 - TURN_SPEED_SLIDING:
			var iceslide_rotation : float = rotation
			if rot_dist > PI * 0.5 + MAX_ICESLIDE_TURN_SPEED:
				iceslide_rotation += (rot_dist - (PI * 0.5 + MAX_ICESLIDE_TURN_SPEED)) * rotation_sign(rotation, Global.incos(velocity_cos, velocity.x))
			redirect_velocity(iceslide_rotation + PI * 0.5 * rotation_sign(rotation, Global.incos(velocity_cos, velocity.x)))
		else:
			iceslide = false
	
	if input_up or forced_accel:
		if switching_gears_timer == 0:
			velocity.x += sin(rotation) * (ACCELERATION + extra_accel)
			velocity.y -= cos(rotation) * (ACCELERATION + extra_accel)
		else:
			velocity.x += sin(rotation) * (ACCELERATION + extra_accel) * 0.6
			velocity.y -= cos(rotation) * (ACCELERATION + extra_accel) * 0.6

	if forced_brake and pyth > 10:
		velocity.x -= velocity_sin * DECCELERATION
		velocity.y -= velocity_cos * DECCELERATION
	
	if input_down:
		velocity.x -= sin(rotation) * (DECCELERATION + extra_accel)
		velocity.y += cos(rotation) * (DECCELERATION + extra_accel)
		
		extra_drag += 6
	
	
	if (not input_up and not input_down) or not is_taking_inputs:
		if friction_reduction > 0:
			friction_reduction -= 1
	
	if velocity_sin != null or velocity_cos != null:
		velocity.x = apply_reductive_forces(velocity.x, velocity_sin, FRICTION + extra_friction, pyth, SLIDING_DRAG + extra_drag)
		velocity.y = apply_reductive_forces(velocity.y, velocity_cos, FRICTION + extra_friction, pyth, SLIDING_DRAG + extra_drag)
		
		if Global.debug_mode:
			$sliding_rot_cos.global_rotation = Global.incos(velocity_cos, velocity.x)
		
		if not (DEBUG_NO_EXIT_SLIDING or on_ice):
			var rot_dist = rotation_distance(Global.incos(velocity_cos, velocity.x), rotation)
			if (rot_dist < PI * 0.03 and not input_down and not forced_brake):
				state_sliding = false
			if rot_dist > PI * 0.97:
				state_sliding = false
				pyth = -pyth
	
	if not (DEBUG_NO_EXIT_SLIDING or on_ice):
		if abs(velocity.x) < 25 and abs(velocity.y) < 25:
			state_sliding = false
	
	curr_speed = pyth


func apply_reductive_forces(vel : float, portion : float, friction : float, speed : float, drag : float):
	if vel == 0:
		return vel
	var speed_sign = sign(vel)
	vel -= portion * (friction / 3 + speed / 1000 * drag)
	if speed_sign != sign(vel) and speed_sign != 0:
		vel = 0
	return vel


func boost(magnitude : float, drag : float, direction : float, redirect_drift : bool = true):
	if state_sliding:
		var pyth = Global.pythagoras(velocity.x, velocity.y)
		velocity.x += sin(direction) * magnitude / (1 + pyth / 1000 * drag)
		velocity.y += -cos(direction) * magnitude / (1 + pyth / 1000 * drag)
	else:
		#print("b: ", direction, " r: ", rotation, " d: ", rotation_distance(direction, rotation))
		curr_speed += ((PI/2) - rotation_distance(direction, rotation)) / (PI/2) * magnitude / (1 + abs(curr_speed) / 1000 * drag)
	if state_drifting and redirect_drift:
		redirect_velocity(rotation)


func redirect_velocity(direction : float):
	if state_sliding:
		var pyth = Global.pythagoras(velocity.x, velocity.y)
		velocity.x = sin(direction) * pyth
		velocity.y = -cos(direction) * pyth
	if state_drifting:
		drifting_real_direction = direction


func wall_rotation_change(curr_rot : float, wall_rot : float):
	var bang_angle = flip_angle(curr_rot)
	bang_angle = mirror_angle(bang_angle, wall_rot)
	return bang_angle


func rotation_distance(r1, r2):
	while r1 < 0:
		r1 += 2*PI
	while r2 < 0:
		r2 += 2*PI
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


# This function figures out which way is most efficient 
# to spin to get from r1 to r2, so you rotate the least.
# Probs exist a better way than this that i don't want to figure out.
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
	var s = sign(r2 - r1)
#	print("b: ", sign, " ", dist, " ", r1, " ", r2)
	r1 -= PI
	while r1 < 0:
		r1 += 2*PI
	r2 -= PI
	while r2 < 0:
		r2 += 2*PI
	if abs(r1 - r2) < dist:
		dist = abs(r1 - r2)
		s = sign(r2 - r1)
#	print("a: ", sign, " ", dist, " ", r1, " ", r2)
	return s


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


func _on_race_started():
	is_taking_inputs = true


func _on_race_finished(_race_timer, _lap):
	is_taking_inputs = false
	forced_brake = true
