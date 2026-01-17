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
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var crot = deg_to_rad(event.relative.y*sensitivity)
		var brot = deg_to_rad(event.relative.x*sensitivity)
		#rotation_degrees.y -= brot
		#$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x-crot,-90,90)
		ideal_by = rotation.y-brot
		ideal_cx = clamp($Camera3D.rotation.x-crot,deg_to_rad(-90),deg_to_rad(90))
