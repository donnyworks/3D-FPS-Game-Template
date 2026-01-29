extends SpotLight3D

@export var delay := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_fire(parameter:int):
	await get_tree().create_timer(delay).timeout
	light_energy = parameter
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
