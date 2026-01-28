extends Area3D

@export var crossMapName = "" ## Transition name to keep track of across maps.

@export var otherMapPath = "" ## Map name of the other map

@export var origin : Node3D ## Origin point of the transition

@export var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalScope.current_level_transition == crossMapName and crossMapName != "":
		player.position = GlobalScope.player_position + origin.global_position
	connect("body_entered", body_entered_call)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func body_entered_call(node: Node3D):
	if node.name == "Player":
		GlobalScope.player_position = node.position - origin.global_position
		GlobalScope.player_rotation = node.rotation
		GlobalScope.player_velocity = node.velocity
		GlobalScope.player_accel = node.accel_velocity
		GlobalScope.accel_status = node.accel_status
		GlobalScope.friction_status = node.friction_status
		GlobalScope.current_level_transition = crossMapName
		GlobalScope.player_by = node.ideal_by
		GlobalScope.player_cx = node.ideal_cx
		GlobalScope.player_speed = node.SPEED
		GlobalScope.player_camera_rotation = node.get_node("Camera3D").rotation
		get_tree().call_deferred("change_scene_to_file","res://devkit_game/maps/" + otherMapPath + ".tscn")
