extends CharacterBody3D

@export var sensitivity = 0.8
@export_category("Movement Control")
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var ideal_cx = 0.0
var ideal_by = 0.0
var interpolation_rate = 10

var accel_interpolation_rate = 5.0

var decel_interpolation_rate = 20.0

var accel_velocity = Vector3.ZERO

var accel_status = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.rotation.x = lerp_angle($Camera3D.rotation.x,ideal_cx,delta*interpolation_rate)
	rotation.y = lerp_angle(rotation.y,ideal_by,delta*interpolation_rate)
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
