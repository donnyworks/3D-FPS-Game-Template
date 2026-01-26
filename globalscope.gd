extends Node

var player_position = Vector3.ZERO
var player_camera_rotation = Vector3.ZERO
var player_rotation = Vector3.ZERO
var player_velocity = Vector3.ZERO
var player_accel = Vector3.ZERO
var player_speed = 5.0
var player_cx = 0.0
var player_by = 0.0
var accel_status = 0.0
var friction_status = 0.0
var current_level_transition = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
