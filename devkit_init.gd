extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("DevkitGD [current] - (C) 2023-2026 Donovan's Dimension of Art")
	print("Built on Godot Engine (current: 4.5.1) / Built on hopes and dreams")
	GlobalScope.connect("gameinfo_load_completed",OnGameinfoLoadComplete)
	if not GlobalScope.GameInfo.ShowLogos: get_tree().change_scene_to_file("res://DevkitGD_TitleScreen.tscn")
	pass # Replace with function body.

func OnGameinfoLoadComplete():
	print("Gameinfo ready!")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://DevkitGD_TitleScreen.tscn")
	pass # Replace with function body.
