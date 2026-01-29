extends Area3D
class_name trigger_generic

@export var runonce := false ## Trigger only runs once
@export var delay := 0.0 ## Delay until the trigger does something
@export_enum("TRIGGER_ENTRY","TRIGGER_EXIT","TRIGGER_DISABLED") var run_mode = "TRIGGER_ENTRY"
@export var valid_names : Array[String] = ["Player"]
@export var parameter_id := 0

var material_invisible := StandardMaterial3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is CSGShape3D:
		pass
	else:
		print("trigger_generic : Failed to load trigger_generic - attempted to spawn brush entity as point entity.")
		queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent() is CSGShape3D:
		if get_parent().get_meshes() != [] and $CollisionShape3D.shape == null:
			var parent_mesh : Mesh = get_parent().get_meshes()[1]
			$MeshInstance3D.mesh = parent_mesh
			$CollisionShape3D.shape = parent_mesh.create_convex_shape()
			material_invisible.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material_invisible.albedo_color = Color(0,0,0,0)
			get_parent().material_override = material_invisible
	pass

func on_fire(param):
	match param:
		0: run_mode = "TRIGGER_ENTRY"
		1: run_mode = "TRIGGER_EXIT"
		2: run_mode = "TRIGGER_DISABLED"

func dothetrigger():
	await get_tree().create_timer(delay).timeout
	for i in get_children():
		if i.is_in_group("Runnable"):
			i.on_fire(parameter_id)
		else:
			print("Warning: Node " + i.name + " is not a Runnable!")
	if runonce: run_mode = "TRIGGER_DISABLED"

func _on_body_entered(body: Node3D) -> void:
	if body.name in valid_names and run_mode == "TRIGGER_ENTRY":
		dothetrigger()
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	if body.name in valid_names and run_mode == "TRIGGER_EXIT":
		dothetrigger()
	pass # Replace with function body.
