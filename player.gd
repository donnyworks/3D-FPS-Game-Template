extends CharacterBody3D

@export var sensitivity = 0.8
@export_category("Movement Control")
@export var DEFAULT_SPEED = 5.0
@export var MIDAIR_SPEED = 1.0
@export var JUMP_VELOCITY = 4.5
@export var MAX_FRAMETIME = 10 ## Maximum amount of frames needed before the next slow-down deceleration step.

var SPEED = DEFAULT_SPEED

func _ready():
	if GlobalScope.player_position != Vector3.ZERO:
		rotation = GlobalScope.player_rotation
		velocity = GlobalScope.player_velocity
		accel_velocity = GlobalScope.player_accel
		accel_status = GlobalScope.accel_status
		friction_status = GlobalScope.friction_status
		ideal_by = GlobalScope.player_by
		ideal_cx = GlobalScope.player_cx
		SPEED = GlobalScope.player_speed
		$Camera3D.rotation = GlobalScope.player_camera_rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var ideal_cx = 0.0
var ideal_by = 0.0
var interpolation_rate = 10

var accel_interpolation_rate = 5.0

var decel_interpolation_rate = 20.0

var accel_velocity = Vector3.ZERO

var accel_status = 0.0

var friction_status = 0.0

func _process(delta: float) -> void:
	$cvel.text = str(accel_velocity)
	$speed.text = str(SPEED)
	$mvel.text = str(clamp(accel_velocity,Vector3(-MIDAIR_SPEED - DEFAULT_SPEED,-JUMP_VELOCITY,-MIDAIR_SPEED - DEFAULT_SPEED),Vector3(MIDAIR_SPEED + DEFAULT_SPEED,JUMP_VELOCITY,MIDAIR_SPEED + DEFAULT_SPEED)))
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.rotation.x = lerp_angle($Camera3D.rotation.x,ideal_cx,delta*interpolation_rate)
	rotation.y = lerp_angle(rotation.y,ideal_by,delta*interpolation_rate)
	
var frametime_elapsed = 0
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		SPEED += MIDAIR_SPEED
		friction_status = 0.0
		velocity.y = JUMP_VELOCITY # Scratch that, the reason bhopping is so elegant is BECAUSE the jumps mean larger strides
		#velocity.y = (JUMP_VELOCITY + 1.0) - SPEED/5 # the reason for the +1 is because jump_velocity is normal while you're at normal speed, and then...
	elif is_on_floor() and (not Input.is_action_just_pressed("jump")):
		if frametime_elapsed > MAX_FRAMETIME:
			if SPEED > DEFAULT_SPEED:
				SPEED = lerp(SPEED,DEFAULT_SPEED,friction_status) # friction???
			if SPEED < DEFAULT_SPEED:
				SPEED = DEFAULT_SPEED
			friction_status += delta
			if friction_status > 1.0:
				friction_status = 0.0
			frametime_elapsed = 0
		else:
			frametime_elapsed += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = accel_velocity.x
	velocity.z = accel_velocity.z
	if direction:
		accel_velocity.x = lerp(accel_velocity.x,direction.x * SPEED,accel_status)
		accel_velocity.z = lerp(accel_velocity.z,direction.z * SPEED,accel_status)
		if accel_status < 1.0: accel_status += 1.0/accel_interpolation_rate
		else: accel_status = 1.0 # Cap for lerp
	else:
		accel_velocity.x = lerp(accel_velocity.x,0.0,1.0 - accel_status)
		accel_velocity.z = lerp(accel_velocity.z,0.0,1.0 - accel_status)
		if accel_status > 0.0: accel_status -= 1.0/decel_interpolation_rate
		else: accel_status = 0.0 # Cap for lerp
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var crot = deg_to_rad(event.relative.y*sensitivity)
		var brot = deg_to_rad(event.relative.x*sensitivity)
		#rotation_degrees.y -= brot
		#$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x-crot,-90,90)
		ideal_by = rotation.y-brot
		ideal_cx = clamp($Camera3D.rotation.x-crot,deg_to_rad(-90),deg_to_rad(90))
