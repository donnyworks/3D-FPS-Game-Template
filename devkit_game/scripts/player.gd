extends CharacterBody3D

@export var sensitivity = 0.8
@export var look_tilt = 5 ## Number of degrees to tilt the player's roll in while wallrunning
@export_category("Movement Control")
var WALLRUN_ENABLED := true
@export var DEFAULT_SPEED := 5.0
@export var MIDAIR_SPEED := 1.0
@export var JUMP_VELOCITY := 4.5
@export var MAX_FRAMETIME := 10 ## Maximum amount of frames needed before the next slow-down deceleration step.

var SPEED := DEFAULT_SPEED

var SOUP := 0 # Soup :)

func _ready():
	print("LOADING PLAYER...")
	WALLRUN_ENABLED = GlobalScope.game_wallrun_enabled
	if GlobalScope.player_position != Vector3.ZERO:
		print("NEW GAMESTATE FOUND!")
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

var ideal_cx := 0.0
var ideal_by := 0.0
var interpolation_rate := 10

var accel_interpolation_rate := 5.0

var decel_interpolation_rate := 20.0

var accel_velocity := Vector3.ZERO

var accel_status := 0.0

var friction_status := 0.0

var s_pressed = 0

var o_pressed = 0

var u_pressed = 0

var p_pressed = 0

func _process(delta: float) -> void:
	$cvel.text = str(accel_velocity)
	$speed.text = str(SPEED)
	$suitMeter/suit.text = str(SOUP)
	$mvel.text = str(clamp(accel_velocity,Vector3(-MIDAIR_SPEED - DEFAULT_SPEED,-JUMP_VELOCITY,-MIDAIR_SPEED - DEFAULT_SPEED),Vector3(MIDAIR_SPEED + DEFAULT_SPEED,JUMP_VELOCITY,MIDAIR_SPEED + DEFAULT_SPEED)))
	if Input.is_key_pressed(KEY_S): s_pressed = 1
	if Input.is_key_pressed(KEY_O) and s_pressed == 1: o_pressed = 1
	if Input.is_key_pressed(KEY_U) and o_pressed == 1: u_pressed = 1
	if Input.is_key_pressed(KEY_P) and u_pressed == 1: p_pressed = 1
	if p_pressed == 1:
		s_pressed = 0
		o_pressed = 0
		u_pressed = 0
		p_pressed = 0
		SOUP += 1
	if Input.is_action_just_pressed("use"): $cantuse.play()
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.rotation.x = lerp_angle($Camera3D.rotation.x,ideal_cx,delta*interpolation_rate)
	rotation.y = lerp_angle(rotation.y,ideal_by,delta*interpolation_rate)
	
var frametime_elapsed := 0

var wallrun_elapsed := 0.0

func wallrunning_enabled(delta):
	if WALLRUN_ENABLED:
		wallrun_elapsed += delta
		
		return is_on_wall_only() and wallrun_elapsed < 10.0
	else:
		return false

@onready var movementTween = null

var bonusWalljumpJump = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if wallrunning_enabled(delta):
		if self.rotation_degrees.z == 0:
			if SPEED < 18:
				SPEED = 18.0
			bonusWalljumpJump = true
			movementTween = create_tween()
			movementTween.tween_property(self, "rotation_degrees:z", (get_wall_normal().x + get_wall_normal().z)*look_tilt, 0.5)
	else:
		if movementTween != null: movementTween.stop()
		self.rotation_degrees.z = 0
		bonusWalljumpJump = GlobalScope.GameInfo.AllowInfiniteDoubleJumps
	if not is_on_floor() and not wallrunning_enabled(0):
		velocity += get_gravity() * delta
		bonusWalljumpJump = GlobalScope.GameInfo.AllowInfiniteDoubleJumps
	else:
		wallrun_elapsed = 0.0
	if wallrunning_enabled(0) and not is_on_floor():
		velocity += get_gravity() / 5 * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or bonusWalljumpJump):
		if not is_on_floor(): bonusWalljumpJump = GlobalScope.GameInfo.AllowInfiniteDoubleJumps
		SPEED += MIDAIR_SPEED
		friction_status = 0.0
		wallrun_elapsed = 0.0
		velocity.y = JUMP_VELOCITY # Scratch that, the reason bhopping is so elegant is BECAUSE the jumps mean larger strides
		#velocity.y = (JUMP_VELOCITY + 1.0) - SPEED/5 # the reason for the +1 is because jump_velocity is normal while you're at normal speed, and then...
	elif is_on_floor() and (not Input.is_action_just_pressed("jump")):
		bonusWalljumpJump = GlobalScope.GameInfo.AllowInfiniteDoubleJumps
		wallrun_elapsed = 0.0
		if frametime_elapsed > MAX_FRAMETIME:
			if SPEED > DEFAULT_SPEED:
				SPEED = lerp(float(SPEED),float(DEFAULT_SPEED),float(friction_status)) # friction???
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
		if is_on_floor():
			if not $floorcast.is_colliding():
				if not $footsteps_generic.playing: $footsteps_generic.play()
			else:
				if not $floorcast.get_collider().is_in_group("TileFloor"):
					if not $footsteps_generic.playing: $footsteps_generic.play()
				else:
					if not $footsteps_tile.playing: $footsteps_tile.play()
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
